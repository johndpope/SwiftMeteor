//
//  RVBaseDatasource4.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/21/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit

enum RVExpandCollapseOperationType {
    case collapseOnly
    case expandOnly
    case collapseAndZero
    case collapseZeroAndExpand
    case collapseZeroExpandAndLoad
    case sectionLoadOrUnload
    case toggle

}
protocol RVItemRetrieve: class {
    var item: RVBaseModel? { get set }
}
enum RVDatasourceType: String {
    case top        = "Top"
    case main       = "Main"
    case filter     = "Filter"
    case subscribe  = "Subscribe"
    case unknown    = "Unknown"
}
class RVBaseDatasource4<T:NSObject>: NSObject {
    let FAKESECTION = 1234567
    var sectionMode: Bool = false
    var sectionDatasourceMode: Bool = false
    var dynamicSections: Bool = false
    var sectionDatasourceType: RVDatasourceType = .main
    var zeroCellModeOn: Bool = false 
    var zeroCellIndex: Int = 1
    var zeroCellModel: T? {
        let model = RVBaseModel()
        model.title = "Zero Cell"
        model.createdAt = Date()
        if let model = model as? T { return model }
        return nil
    }
    let LAST_SORT_STRING = "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
    var instanceType: String { get { return String(describing: type(of: self)) } }
    let identifier = NSDate().timeIntervalSince1970
    var baseQuery: RVQuery? = nil
    let queue = RVOperationQueue()
    var rowAnimation: UITableViewRowAnimation = UITableViewRowAnimation.automatic
    var elements = [T]()
    var sections = [RVBaseDatasource4<T>]()
    var section: Int { get {
        if let manager = self.manager { return manager.sectionIndex(datasource: self)}
        return -1
        }
    }
    var backOperationActive: Bool = false
    var frontOperationActive: Bool = false
    var subscriptionActive: Bool = false
    var maxArraySize: Int = 300
    var collapsed: Bool = false
    var expanded: Bool { return !collapsed }
    var subscription: RVSubscription? = nil
    var notificationInstalled: Bool = false
    var elementsCount: Int { return elements.count}
    var sectionModel: T? = nil

    weak var scrollView: UIScrollView? {
        willSet {
            if (scrollView == nil) || (newValue == nil) { return }
            if let oldValue = scrollView { if let newValue = newValue { if oldValue == newValue { return }}}
            print("In \(self.classForCoder).scrollValue oldValue and newValue are different \(scrollView?.description ?? " no scrollView"), \(newValue?.description ?? " no newValue")")
        }
    }
    var offset: Int = 0 {
        willSet {
            if newValue < 0 { print("In \(self.classForCoder) ERROR. attemtp to set Offset to a negative number \(newValue)") }
            //print("In \(self.classForCoder).offset setting to \(newValue) and arraysize is \(elementsCount)")
        }
    }
    var datasourceType: RVDatasourceType = .unknown
    var manager: RVDSManager5<T>?

    fileprivate var lastItemIndex: Int = 0
    fileprivate let TargetBackBufferSize: Int = 20
    fileprivate let TargetFrontBufferSize: Int = 20
    var backBufferSize: Int {
        get {
            if TargetBackBufferSize < (self.maxArraySize / 2) { return TargetBackBufferSize }
            else if self.maxArraySize < 50 {
                print("In \(self.classForCoder) maxArraySize too small maxArraySize: \(self.maxArraySize)")
            }
            return self.maxArraySize / 2 - 1
        }
    }
    var frontBufferSize: Int {
        get {
            let remainder = self.maxArraySize - self.backBufferSize
            if remainder >= TargetFrontBufferSize { return TargetFrontBufferSize }
            else if remainder < 2 {
                print("In \(self.classForCoder) ERROR. insufficient size for both buffers. MaxArraySize = \(self.maxArraySize) and backBufferSize = \(self.backBufferSize)")
                return 1
            } else {
                return remainder - 1
            }
        }
    }
    func innerRetrieve(query: RVQuery, callback: @escaping RVCallback<T>) {
        DispatchQueue.main.async {
            self.retrieve(query: query, callback: callback)
        }
    }
    var subscriptionMaxCount: Int = 10
    fileprivate var _subscriptionMaxCount: Int = 0

    
    func retrieve(query: RVQuery, callback: @escaping RVCallback<T>) {
      //  print("In RVBaseDatasource4.retrieve, need to override")
        RVBaseModel.bulkQuery(query: query) { (models, error) in
            if let error = error {
                error.append(message: "In \(self.classForCoder).")
                callback([T](), error)
                return
            } else if let results = models as? [T] {
                callback(results, nil)
            } else {
                let error = RVError(message: "In \(self.classForCoder).retrieve, failed to cast models at \(type(of: T.self))")
                callback([T](), error)
            }
        }
    }
 
    init(manager: RVDSManager5<T>?, datasourceType: RVDatasourceType, maxSize: Int) {
        self.manager = manager
        self.datasourceType = datasourceType
        self.maxArraySize = ((maxSize < 500) && (maxSize > 50)) ? maxSize : 500
        super.init()
    }

    func cancelAllOperations() { self.queue.cancelAllOperations()}
    func unsubscribe(callback: @escaping () -> Void) {
      //  print("In \(self.classForCoder).unsubscribe")
            if let subscription = self.subscription {
                NotificationCenter.default.removeObserver(self, name: subscription.notificationName, object: nil)
                NotificationCenter.default.removeObserver(self, name: subscription.unsubscribeNotificationName, object: nil)
                notificationInstalled = false
    //            subscription.unsubscribe()
    //            self.subscriptionActive = false
     //           callback()
                
                subscription.unsubscribe(callback: {
                    //print("In \(self.classForCoder).unsubscribe callback") // Neil this is the Tender Area
                    self.subscriptionActive = false
                    callback()
                })
 
        } else {
            self.subscriptionActive = false
            callback()
        }
    }
    func listenToSubscriptionNotification(subscription: RVSubscription) {
       // print("In \(self.classForCoder).listenToSubscription")
        if !notificationInstalled {
            notificationInstalled = true
            NotificationCenter.default.addObserver(self, selector: #selector(RVBaseDatasource4<T>.receiveSubscriptionResponse(notification:)), name: subscription.notificationName, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(RVBaseDatasource4<T>.unsubscribeNotification(notification:)), name: subscription.unsubscribeNotificationName, object: nil)
        }
    }
    func unsubscribeNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let modelType = userInfo[RVBaseCollection.collectionNameKey] as? RVModelType {
                if let subscription = self.subscription {
                    if subscription.collection == modelType {
                      //  print("In \(self.classForCoder).unsubscribeNotification for \(modelType.rawValue)")
                        let operation = RVForcedUnsubscribe(datasource: self, scrollView: self.scrollView, callback: { (models, error) in
                            if let error = error {
                                error.printError()
                            }
                        })
                        queue.addOperation(operation)
                    }
                }
            }
        }
    }
    func subscribe(scrollView: UIScrollView?, front: Bool) {
        if !self.subscriptionActive {
          //  print("In \(self.classForCoder).subscribe, passed !subsciprtionActive --------------")
            //subscription.reference = self.items.first
            if let subscription = self.subscription {
             //    print("In \(self.classForCoder).subscribe, have subscription")
                if (subscription.isFront && front) || (!subscription.isFront && !front) {
               //     print("Neil check this \(self.classForCoder).subscribe, took out subscriptionOperation flag")
                    let operation = RVSubscribeOperation<T>(datasource: self, subscription: subscription, callback: { (models, error) in
                        if let error = error {
                            print("In \(self.classForCoder).subscribe, got error)")
                            error.printError()
                        }
                    })
                    /*
                    let operation = RVLoadOperation(title: "Subscribe", datasource: self , scrollView: scrollView, front: front, callback: { (models, error) in // NEIL
                        if let error = error {
                            print("In \(self.classForCoder).subscribe, got error)")
                            error.printError()
                        }
                    })
 */
                    self.queue.addOperation(operation)
                } else {
           //         print("In \(self.classForCoder).subscribe subscription.isFront: \(subscription.isFront), datasource.isFront \(front)")
                }
            } else {
                print("In \(self.classForCoder).subscribe, not subscription")
            }
        } else {
            print("In \(self.classForCoder).subscribe, passed subsciprtionActive")
        }
    }
    func receiveSubscriptionResponse(notification: NSNotification) {
      //  print("In \(self.classForCoder).receiveSubscription")
        if let userInfo = notification.userInfo {
            if let payload = userInfo[RVPayload.payloadInfoKey] as? RVPayload<T> {
              //  print("In \(self.classForCoder).receiveSubscription have payload \(payload.toString())")
                if let subscription = self.subscription {
                    if subscription.identifier == payload.subscription.identifier {
                     //   print("In \(self.classForCoder).receiveSubscription subscriptions match")
                        
                        let operation = RVSubcriptionResponseOperation<T>(datasource: self, subscription: subscription, incomingModels: payload.models, callback: { (models, error ) in
                            if let error = error {
                                error.printError()
                            }
                        })
                        self.queue.addOperation(operation)
                    } else {
                        print("In \(self.classForCoder).receiveSubscription payload identifier = \(payload.subscription.identifier) vs. subscriptionIdentifier: \(subscription.identifier)")
                    }
                } else {
                    print("In \(self.classForCoder).receiveSubscription but don't have a subscription")
                }
            } else {
                print("In \(self.classForCoder).receiveSubscription no payload \(String(describing: userInfo[RVPayload.payloadInfoKey]))\nT is: \(T.self)")
            }
        } else {
            print("In \(self.classForCoder).receivedSubscription, no userInfo")
        }
        
    }
    func zeroElements() {
        self.elements = [T]()
        self.offset = 0
    }

    deinit {
        //print("In \(self.classForCoder).deinit")
        self.unsubscribe {}
        self.cancelAllOperations()
    }
}

extension RVBaseDatasource4 {
    func stripCandidate(candidate: RVBaseModel? ) -> [RVKeys : AnyObject] {
        var strip = [RVKeys:AnyObject]()
        if let candidate = candidate {
            if let createdAt = candidate.createdAt { strip[.createdAt] = createdAt as AnyObject }
            if let updatedAt = candidate.updatedAt { strip[.updatedAt] = updatedAt as AnyObject }
            if let comment = candidate.comment {
                strip[.comment] = comment as AnyObject
                strip[.commentLowercase] = comment.lowercased() as AnyObject
            }
            if let handle = candidate.handle {
                strip[.handle] = handle as AnyObject
                strip[.handleLowercase] = handle.lowercased() as AnyObject
            }
            if let title = candidate.title { strip[.title] = title as AnyObject }
            if let fullName = candidate.fullName { strip[.fullName] = fullName as AnyObject }
        }
        return strip
    }
    func updateSortTerm(query: RVQuery, front: Bool = false, candidate: NSObject? = nil) -> RVQuery {
        if (query.sortTerms.count == 0) || (query.sortTerms.count > 1) {
            print("In \(self.classForCoder).updateSortTerms, erroneous number of sort Tersm: sortTerms are: \(query.sortTerms)")
        }
        if let sortTerm = query.sortTerms.first {
            let firstString: AnyObject = "" as AnyObject
            let lastString:  AnyObject = self.LAST_SORT_STRING as AnyObject
            var comparison = (sortTerm.order == .ascending) ?  RVComparison.gte : RVComparison.lte
            var sortString: AnyObject = (sortTerm.order == .descending) ? lastString : firstString
            if front {
                comparison = (sortTerm.order == .ascending) ?  RVComparison.lt : RVComparison.gt
                sortString = (sortTerm.order == .descending) ? firstString : lastString
            }
            var sortDate: Date  = (sortTerm.order == .ascending)  ? query.decadeAgo : Date()
            if front { sortDate = (sortTerm.order == .descending) ? query.decadeAgo : Date() }
            
            var finalValue: AnyObject = sortString as AnyObject

            var strip = [RVKeys : AnyObject]()
            if let candidate = candidate {
                if let candidate = candidate as? RVBaseModel {
                    //print("In \(self.classForCoder).updateSortTerm, have candidate \(candidate)")
                    strip = self.stripCandidate(candidate: candidate)
                } else if let datasource = candidate as? RVBaseDatasource4<RVBaseModel> {
               //     print("In \(self.classForCoder).updateSortTerm, candidate is a RVBaseDatasource4<T>")
                    if let sectionModel = datasource.sectionModel {
                    //    print("In \(self.classForCoder).updateSortTerm, have sectionModel")
                        strip = self.stripCandidate(candidate: sectionModel)
                    } else {
                        print("In \(self.classForCoder).updateSortTerm, do not have sectionModel")
                    }
                    
                } else {
                    print("In \(self.classForCoder).updateSortTerm, some unknown candidate \(candidate)")
                }
            } else {
               // print("In \(self.classForCoder).updateSortTerm, no candidate")
            }
            if let value = strip[sortTerm.field] { finalValue = value }
            else if let andTerm = query.findAndTerm(term: sortTerm.field) { finalValue = andTerm.value as AnyObject }
            switch (sortTerm.field) {
            case .createdAt, .updatedAt:
                if let date = strip[sortTerm.field] { finalValue = date }
                else if let andTerm = query.findAndTerm(term: sortTerm.field) { finalValue = andTerm.value as AnyObject }
                else { finalValue = sortDate as AnyObject }
             //   if (strip[sortTerm.field] == nil ) && (query.findAndTerm(term: sortTerm.field) == nil ) { finalValue = sortDate as AnyObject }
            case .commentLowercase, .comment, .handleLowercase, .handle, .title, .fullName:
                break
            default:
                print("In \(self.classForCoder).updateSortTerms, term: \(sortTerm.field.rawValue) not handled")
            }
            //print("In \(self.classForCoder).updateSortTerm, finalValue is: \(finalValue), Comparison: \(comparison.rawValue), sortField: \(sortField.rawValue)")
            if let queryTerm = query.findAndTerm(term: sortTerm.field) { queryTerm.value =  finalValue}
            else { query.addAnd(term: sortTerm.field, value: finalValue, comparison: comparison) }
        }
        return query
    }
    var numberOfElements: Int { get { return virtualCount } }
    var virtualCount: Int {
        get {
            if self.collapsed {
               // print("In \(self.classForCoder).virtualCount............ collapsed elementsCount = \(self.elementsCount)")
                if self.zeroCellModeOn { return self.zeroCellIndex }
                return 0
            } else {
                return virtualCountIndependentOfCollapse
            }
        }
    }
    var virtualCountIndependentOfCollapse: Int {
        get {
            if zeroCellModeOn {
                return self.elementsCount + self.offset + self.zeroCellIndex
            } else {
                // print("In virtualCount \(self.description) \(self.elements.description) count: \(self.elements.count) offset: \(self.offset)")
                return self.elementsCount + self.offset
            }
        }
    }
    func inFront(scrollView: UIScrollView?) {
        //print("In \(self.classForCoder).inFront. ........................................... #######")
        if self.datasourceType == .filter { return }
        DispatchQueue.main.async {
            if self.frontOperationActive { return }
            let operation = RVLoadOperation(datasource: self, scrollView: scrollView, front: true, callback: { (models, error) in
                if let error = error {
                    error.append(message: "In \(self.classForCoder).inFront RVBaseDatasource4 line \(#line) , got error")
                    error.printError()
                } else {
                    //print("In \(self.classForCoder).inFront, success")
                }
            })
            self.queue.addOperation(operation)
        }
    }
    func inBack(scrollView: UIScrollView?) {
        DispatchQueue.main.async {
            if self.backOperationActive {
               // print("In \(self.classForCoder).inBack, backOperationActive")
                return
            }
            let operation = RVLoadOperation(datasource: self, scrollView: scrollView, callback: { (models, error) in
                if let error = error {
                    error.append(message: "In \(self.classForCoder).inBack, got error")
                    error.printError()
                } else {
                    //print("In \(self.classForCoder).inBack, success")
                }
            })
            self.queue.addOperation(operation)
        }
    }
    
    func element(indexPath: IndexPath, scrollView: UIScrollView?, updateLast: Bool = true) -> T? {
        if type(of: RVBaseDatasource4<T>.self) == type(of: self) {
            print("IN \(self.instanceType).element, types matched")
        }
       // print("IN \(self.classForCoder).element \(indexPath)")
        let index = indexPath.row
        if updateLast { self.lastItemIndex = index }
        if index < 0 {
            print("In \(self.instanceType).item, got negative index \(index)")
            return nil
        } else if index >= self.virtualCount {
            print("In \(self.instanceType).item, index \(index) greater than virtualCount: \(self.virtualCount)")
            return nil
        }

        var OKtoRetrieve: Bool = !self.collapsed
        if self.subscription != nil {
            if self.subscriptionActive {
                if self.elementsCount >= self.maxArraySize {
                    OKtoRetrieve = false
                }
            }
        }
        var physicalIndex = index - offset
        if zeroCellModeOn {
            physicalIndex = physicalIndex - zeroCellIndex
        }
        if physicalIndex < 0 {
            //print("In \(self.instanceType).item got physical index less than 0 \(physicalIndex). Offset is \(offset)")
            //print("In \(self.classForCoder).item calling inBack: index = \(index), count: \(elementsCount), offset: \(self.offset), backBuffer: \(self.backBufferSize)")
            if OKtoRetrieve {inFront(scrollView: scrollView)}
            if zeroCellModeOn && (index < zeroCellIndex) {
                if let model = zeroCellModel as? RVBaseModel {
                    model.zeroCellModel = true
                    if let model = model as? T {
                        return model
                    }
                }
                return zeroCellModel
            }
            return nil
        } else if physicalIndex < elementsCount {
            if (physicalIndex + self.backBufferSize) > elementsCount {
                //print("In \(self.classForCoder).item calling inBack:  index = \(index), count: \(elementsCount), offset: \(self.offset), backBuffer: \(self.backBufferSize)")
                if OKtoRetrieve {inBack(scrollView: scrollView) }
            }
            if physicalIndex < self.frontBufferSize {
               // print("In \(self.classForCoder).item calling inFront: index = \(index), count: \(elementsCount), offset: \(self.offset), backBuffer: \(self.backBufferSize)")
                if OKtoRetrieve { inFront(scrollView: scrollView) }
            }
            if zeroCellModeOn && (index < zeroCellIndex) {
                return zeroCellModel
            }
            return elements[physicalIndex]
        } else {
            print("In \(self.instanceType).item physicalIndex of \(physicalIndex) exceeds or equals array size \(elementsCount). Offset is \(self.offset)")
            return nil
        }
    }
    func scroll(indexPath: IndexPath, scrollView: UIScrollView) {
        //print("in \(self.classForCoder).scroll \(index)")
        let _ = self.element(indexPath: indexPath, scrollView: scrollView, updateLast: false)
    }
 
    func cloneItems() -> [T] {
        var clone = [T]()
        for item in elements { clone.append(item) }
        return clone
    }
    var frontElement: T? {
        get {
            if elementsCount == 0 { return nil }
            else { return elements[0] }
        }
    }
    var backElement: T? {
        get {
            if elementsCount == 0 { return nil }
            else { return elements[elementsCount - 1] }
        }
    }
    func shutDown() {
       // print("In \(self.classForCoder)shutDown()")
        self.unsubscribe{}
        self.cancelAllOperations()
    }
    func sectionCollapse(scrollView: UIScrollView?, query: RVQuery, callback: @escaping RVCallback<T>) {
    //    print("In \(self.classForCoder).sectionCollapse")
        self.shutDown()
        self.queue.addOperation(RVExpandCollapseOperation(datasource: self, scrollView: scrollView, operationType: .collapseAndZero, query: query, callback: callback))
    }
    func sectionLoadOrUnload(scrollView: UIScrollView?, query: RVQuery, callback: @escaping RVCallback<T>) {
    //    print("In \(self.classForCoder).sectionCollapse")
        self.shutDown()
        self.queue.addOperation(RVExpandCollapseOperation(datasource: self, scrollView: scrollView, operationType: .sectionLoadOrUnload, query: query, callback: callback))
    }
    func restart(scrollView: UIScrollView?, query: RVQuery, sectionsDatasourceType: RVDatasourceType = .main, callback: @escaping RVCallback<T>) {
      //  print("In \(self.classForCoder).sectionCollapse")
        self.shutDown()
        self.queue.addOperation(RVExpandCollapseOperation(datasource: self, scrollView: scrollView, operationType: .collapseZeroExpandAndLoad, query: query, sectionsDatasourceType: sectionsDatasourceType, callback: callback))
    }
    func collapseZeroAndExpand(scrollView: UIScrollView?, query: RVQuery, callback: @escaping RVCallback<T>) {
     //   print("In \(self.classForCoder).sectionCollapse")
        self.shutDown()
        self.queue.addOperation(RVExpandCollapseOperation(datasource: self, scrollView: scrollView, operationType: .collapseZeroAndExpand, query: query, callback: callback))
    }
    func expand(scrollView: UIScrollView?, callback: @escaping RVCallback<T>) {
        self.queue.addOperation(RVExpandCollapseOperation(datasource: self, scrollView: scrollView, operationType: .expandOnly, callback: callback))
    }
    func collapse(scrollView: UIScrollView?, callback: @escaping RVCallback<T>) {
        self.queue.addOperation(RVExpandCollapseOperation(datasource: self, scrollView: scrollView, operationType: .collapseOnly, callback: callback))
    }
    func toggle(scrollView: UIScrollView?, callback: @escaping RVCallback<T>) {
        self.queue.addOperation(RVExpandCollapseOperation(datasource: self, scrollView: scrollView, operationType: .toggle, callback: callback))
    }

}


class RVForcedUnsubscribe<T: NSObject>: RVAsyncOperation<T> {
    weak var datasource: RVBaseDatasource4<T>? = nil
    weak var scrollView: UIScrollView? = nil
    var emptyModels = [T]()
    init(datasource: RVBaseDatasource4<T>, scrollView: UIScrollView? = nil, callback: @escaping RVCallback<T>) {
        self.datasource = datasource
        self.scrollView = scrollView
        super.init(title: "RVForcedUnsubscribe", callback: callback)
    }
    override func asyncMain() {
        if self.isCancelled {
            self.finishUp(models: self.emptyModels, error: nil)
        } else {
            if let manager = self.datasource {
                if let tableView = self.scrollView as? UITableView {
                    tableView.beginUpdates()
                    manager.unsubscribe {
                        tableView.endUpdates()
                        self.finishUp(models: self.emptyModels, error: nil)
                    }
                } else if let collectionView = self.scrollView as? UICollectionView {
                    collectionView.performBatchUpdates({
                        manager.unsubscribe {
                            
                        }
                    }, completion: { (success) in
                        self.finishUp(models: self.emptyModels, error: nil)
                    })
                } else {
                    manager.unsubscribe {
                        self.finishUp(models: self.emptyModels, error: nil)
                    }
                }
            } else {
                self.finishUp(models: self.emptyModels, error: nil)
            }
        }
    }
    func finishUp(models: [T], error: RVError?) {
        DispatchQueue.main.async {
            self.callback(models, error)
            self.completeOperation()
        }
    }
}
class RVExpandCollapseOperation<T:NSObject>: RVLoadOperation<T> {
    var operationType: RVExpandCollapseOperationType
    var query: RVQuery
    var emptyModels = [T]()
    var sectionsDatasourceType: RVDatasourceType = .main
    init(datasource: RVBaseDatasource4<T>, scrollView: UIScrollView?, operationType: RVExpandCollapseOperationType, query: RVQuery = RVQuery(), sectionsDatasourceType: RVDatasourceType = .main, callback: @escaping RVCallback<T>) {
        self.operationType  = operationType
        self.query = query
        self.sectionsDatasourceType = sectionsDatasourceType
        super.init(title: "RVExpandCollapseOperation", datasource: datasource, scrollView: scrollView, callback: callback)
     //   print("In \(self.instanceType).init query: \(query) and scrollView: \(String(describing: self.scrollView))")
    }
    func handleCollapse() -> (indexPaths: [IndexPath], sectionIndexes: IndexSet ){
        var indexPaths = [IndexPath]()
        var sectionIndexes = [Int]()
        let section =  !self.datasource.sectionDatasourceMode ? self.datasource.section : self.datasource.FAKESECTION
    //    let lastItem = self.datasource.offset + self.datasource.elementsCount
        let lastItem = self.datasource.virtualCountIndependentOfCollapse
        let firstItem = !self.datasource.zeroCellModeOn ? 0 : self.datasource.zeroCellIndex
        if (section >= 0) && (lastItem > 0) && (lastItem > firstItem) {
            for row in firstItem..<lastItem {
                indexPaths.append(IndexPath(row: row, section: section))
                sectionIndexes.append(row)
            }
        }
        if (self.operationType == .collapseAndZero) || (self.operationType == .collapseZeroAndExpand ) || (self.operationType == .collapseZeroExpandAndLoad){
            self.datasource.zeroElements()
        }
        if (operationType == .collapseZeroAndExpand) || (operationType == .collapseZeroExpandAndLoad) {
            self.datasource.collapsed = false
        } else {
            self.datasource.collapsed = true
        }
        return (indexPaths: indexPaths, sectionIndexes: IndexSet(sectionIndexes))
    }

    override func asyncMain() {
      //   print("In \(self.instanceType).asyncMain operationType: \(self.operationType), query: \(query)")
        var operationType = self.operationType
        if operationType == .toggle { operationType = (self.datasource.collapsed) ? .expandOnly : .collapseOnly }
        if operationType == .sectionLoadOrUnload {
          //  print("In \(self.classForCoder).asyncMain with operation \(operationType) and count \(self.datasource.virtualCount) collapsed: \(self.datasource.collapsed)")
            if self.datasource.collapsed {
      //      if self.datasource.virtualCount <= 0 {
                operationType = .collapseZeroExpandAndLoad
                self.operationType = operationType
            //    print("In \(self.classForCoder).asyncMain with operation \(operationType) and count \(self.datasource.virtualCount) collapsed: \(self.datasource.collapsed)")
            } else {
            //    print("In \(self.classForCoder).asyncMain with operation \(operationType) and count \(self.datasource.virtualCount) collapsed: \(self.datasource.collapsed)")
                operationType = .collapseAndZero
                self.operationType = operationType
            }
        }
        if self.isCancelled {
            self.finishUp(models: self.emptyModels, error: nil)
            return
        } else if (operationType != .expandOnly) {
           // print("In \(self.instanceType).asyncMain operationType: \(self.operationType), passed not expand only, query: \(query), scrollView: \(String(describing: self.scrollView))")
            self.datasource.scrollView = self.scrollView
            if self.datasource.collapsed {
             //   print("In \(self.instanceType).asyncMain operationType: \(self.operationType), thinks collapsed, query: \(query), scrollView: \(String(describing: self.scrollView))")
                if (operationType == .collapseAndZero) || (operationType == .collapseZeroAndExpand) || (operationType == .collapseZeroExpandAndLoad) {
           //         self.datasource.elements = [T]()
            //        self.datasource.offset = 0
                    self.datasource.zeroElements()
                }
                if (operationType == .collapseZeroAndExpand) || (operationType == .collapseZeroExpandAndLoad) { self.datasource.collapsed = false }
                if (operationType == .collapseZeroExpandAndLoad) {
                    // print("In \(self.classForCoder).main, about to do InnerMain, collapsed = \(self.datasource.collapsed)")
             //       print("In \(self.instanceType).asyncMain  \(#line) just before assigning query operationType: \(self.operationType), query: \(self.query)")
                    self.datasource.baseQuery = self.query
                    self.InnerMain()
                } else {
                    self.finishUp(models: self.emptyModels, error: nil)
                }
                return
            //    self.finishUp(models: self.emptyModels, error: nil)
            //    return
            } else {
              //  print("In \(self.instanceType).asyncMain operationType: \(self.operationType), thinks not collapsed, query: \(query), scrollView: \(String(describing: self.scrollView))")
                DispatchQueue.main.async {
                    if self.isCancelled {
                        self.finishUp(models: self.emptyModels, error: nil)
                        return
                    } else {
                        if self.datasource.dynamicSections {
                            //print("In \(self.classForCoder).asyncMain, have dynamicSections")
                            self.datasource.sectionDatasourceType = self.sectionsDatasourceType
                        }
                        if let tableView = self.scrollView as? UITableView {
                            tableView.beginUpdates()
                            if !self.isCancelled {
                                let paths = self.handleCollapse()
                                if paths.indexPaths.count > 0 {
                                    if !self.datasource.sectionDatasourceMode {
                                       tableView.deleteRows(at: paths.indexPaths, with: UITableViewRowAnimation.none)
                                    } else {
                                        tableView.deleteSections(paths.sectionIndexes, with: .none)
                                    }
                                    
                                }
                                tableView.endUpdates()
                            }
                            if (operationType == .collapseZeroExpandAndLoad) {
                               // print("In \(self.classForCoder).main, about to do InnerMain, collapsed = \(self.datasource.collapsed)")
                                //print("In \(self.instanceType).asyncMain line \(#line) just before assigning query operationType: \(self.operationType), query: \(self.query)")
                                self.datasource.baseQuery = self.query
                                self.InnerMain()
                            } else {
                                self.finishUp(models: self.emptyModels, error: nil)
                            }
                            return
                        } else if let collectionView = self.scrollView as? UICollectionView {
                            collectionView.performBatchUpdates({
                                if self.isCancelled { return }
                                let paths = self.handleCollapse()
                                if paths.indexPaths.count > 0 {
                                    if !self.datasource.sectionDatasourceMode {
                                        collectionView.deleteItems(at: paths.indexPaths)
                                    } else {
                                        collectionView.deleteSections(paths.sectionIndexes)
                                    }
                                    
                                }
                            }, completion: { (success) in
                                if (operationType == .collapseZeroExpandAndLoad) {
                                    self.datasource.baseQuery = self.query
                                    self.InnerMain()
                                } else {
                                    self.finishUp(models: self.emptyModels, error: nil)
                                }
                            })
                            return
                        } else if self.scrollView == nil {
                            if (operationType == .collapseAndZero) || (operationType == .collapseZeroAndExpand) || (self.operationType == .collapseZeroExpandAndLoad) {
                                self.datasource.zeroElements()
                           //     self.datasource.elements = [T]()
                          //      self.datasource.offset = 0
                            }
                            if (operationType == .collapseZeroAndExpand) || (operationType == .collapseZeroExpandAndLoad) {
                                self.datasource.collapsed = false
                            } else {
                                self.datasource.collapsed = true
                            }
                            if (operationType == .collapseZeroExpandAndLoad) {
                                self.datasource.baseQuery = self.query
                                self.InnerMain()
                            } else {
                                self.finishUp(models: self.emptyModels, error: nil)
                            }
                            return
                        } else {
                            let error = RVError(message: "In \(self.classForCoder).main, erroneous scrollVIew \(self.scrollView?.description ?? " no scrollView")")
                            self.finishUp(models: self.emptyModels, error: error)
                            return
                        }
                    }
                }
            }
        } else {
           // print("In \(self.classForCoder).main expand collapsed: \(datasource.collapsed)")
            self.datasource.scrollView = self.scrollView
            if self.datasource.collapsed {
                DispatchQueue.main.async {
                    if let tableView = self.scrollView as? UITableView {
                        tableView.beginUpdates()
                        if !self.isCancelled {
                            let paths = self.handleExpand()
                            if !self.datasource.sectionDatasourceMode {
                                tableView.insertRows(at: paths.indexPaths, with: self.datasource.rowAnimation)
                            } else {
                             //   print("In \(self.classForCoder).asyncMain \(#line), about to insertSections \(paths.sectionIndexes.count)")
                                tableView.insertSections(paths.sectionIndexes, with: self.datasource.rowAnimation)
                            }
                            
                        }
                        tableView.endUpdates()
                        self.finishUp(models: self.datasource.elements, error: nil)
                        return
                    } else if let collectionView = self.scrollView as? UICollectionView {
                        collectionView.performBatchUpdates({
                            if !self.isCancelled {
                                let paths = self.handleExpand()
                                if !self.datasource.sectionDatasourceMode {
                                    collectionView.insertItems(at: paths.indexPaths)
                                } else {
                                    collectionView.insertSections(paths.sectionIndexes)
                                }
                                
                            }
                        }, completion: { (success) in
                            self.finishUp(models: self.datasource.elements, error: nil)
                        })
                        return
                    } else if self.scrollView != nil {
                        let _ = self.handleExpand()
                        self.finishUp(models: self.datasource.elements, error: nil)
                        return
                    } else {
                        let error = RVError(message: "In \(self.classForCoder).main, invalid scrollView \(self.scrollView?.description ?? " no scroll view")")
                        self.finishUp(models: self.datasource.elements, error: error)
                        return
                    }
                }
            } else {
                self.finishUp(models: self.datasource.elements, error: nil)
                return
            }
        }
    }
    func handleExpand() -> (indexPaths: [IndexPath], sectionIndexes: IndexSet) {
        var indexPaths = [IndexPath]()
        var sectionIndexes = [Int]()
        let section = !self.datasource.sectionDatasourceMode ? self.datasource.section : self.datasource.FAKESECTION
      //  let lastItem = self.datasource.offset + self.datasource.elementsCount
        let lastItem = self.datasource.virtualCountIndependentOfCollapse
        let firstItem = !self.datasource.zeroCellModeOn ? 0 : self.datasource.zeroCellIndex
        if (section >= 0) && (lastItem > 0) && (lastItem > firstItem) {
   //     if (section >= 0) && (lastItem > 0) {
            for row in firstItem..<lastItem {
                indexPaths.append(IndexPath(row: row, section: section))
                sectionIndexes.append(row)
            }
        }
        self.datasource.collapsed = false
        return (indexPaths: indexPaths, sectionIndexes: IndexSet(sectionIndexes))
    }
    func finishUp(models: [T], error: RVError?) {
        DispatchQueue.main.async {
            self.callback(models, error)
            self.completeOperation()
        }
    }
}
class RVSubscribeOperation<T:NSObject>: RVLoadOperation<T> {
    init(datasource: RVBaseDatasource4<T>, subscription: RVSubscription, callback: @escaping RVCallback<T>) {
        super.init(title: "SubscriptionOperation", datasource: datasource, scrollView: datasource.scrollView, front: subscription.isFront, callback: callback)
        self.subscriptionOperation = .subscribe
    }
}
class RVSubcriptionResponseOperation<T:NSObject>: RVLoadOperation<T> {

    var incomingModels: [T]
    var responseType: RVEventType
    var sourceSubscription: RVSubscription
    init(datasource: RVBaseDatasource4<T>, subscription: RVSubscription, incomingModels: [T], responseType: RVEventType = .added, callback: @escaping RVCallback<T>) {
        self.incomingModels = incomingModels
        self.responseType = responseType
        self.sourceSubscription = subscription
        let scrollView: UIScrollView? = datasource.scrollView
        var front: Bool = sourceSubscription.isFront
        if let subscription = datasource.subscription {
           // scrollView = subscription.scrollView
            // Neil
            front = subscription.isFront
        }
        super.init(title: "RVSubscriptionResponseOperation", datasource: datasource, scrollView: scrollView, front: front, callback: callback)
        self.subscriptionOperation = .response
    }
    override func asyncMain() {
        if self.isCancelled {
            self.finishUp(items: self.incomingModels, error: nil)
            return
        } else if let subscription = self.datasource.subscription {
            self.scrollView = self.datasource.scrollView
            if subscription.identifier != self.sourceSubscription.identifier {
                let error = RVError(message: "In \(self.instanceType).asyncMain, sourceSubscription different than original subscription")
                self.finishUp(items: self.incomingModels, error: error)
                return
            }
            if self.responseType == .added {
                self.insert(models: self.incomingModels, callback: { (models, error) in
                    if let error = error {
                        error.append(message: "In \(self.classForCoder).asyncMain, got error inserting incomingModels.\nFront: (self.front), subscriptionOperation: \(self.subscriptionOperation), responseType: \(self.responseType)\nIncomingModels: \(self.incomingModels)")
                        self.finishUp(items: self.incomingModels, error: error)
                        return
                    } else {
                        self.cleanup(models: self.incomingModels, callback: { (models, error) in
                            self.refreshViews { self.finishUp(items: models, error: nil) }
                        })
                        return
                    }
                })
            } else {
                let error = RVError(message: "In \(self.classForCoder).asyncMain, responseType \(responseType) not handled")
                self.finishUp(items: self.incomingModels, error: error)
                return
            }
        } else {
            let error = RVError(message: "In \(self.instanceType).asyncMain, subscription no longer exists in datasource")
            self.finishUp(items: self.incomingModels, error: error)
            return
        }
    }
    func resubscribe(callback: @escaping () -> Void) {
        //print("In \(self.classForCoder).resubscribe")
        self.datasource.unsubscribe {
            let operation = RVLoadOperation(title: "Resubscribe", datasource: self.datasource, scrollView: self.scrollView, front: self.front, callback: { (models, error) in
                if let error = error {
                    error.append(message: "In \(self.classForCoder).resubscribe got error")
                }
                self.finishUp(items: models, error: error)
            })
            self.datasource.queue.addOperation(operation)
        }
    }
}
class RVLoadOperation<T:NSObject>: RVAsyncOperation<T> {
    enum SubscriptionOperation {
        case none
        case subscribe
        case response
    }


    var datasource: RVBaseDatasource4<T>
    weak var scrollView: UIScrollView?

    var reference: T? = nil
    var front: Bool
    var subscriptionOperation: SubscriptionOperation = .none
    var referenceMatch: Bool {
        get {
            let current = self.front ? self.datasource.frontElement : self.datasource.backElement
            if (reference == nil) && (current == nil) { return true }
            if let reference = self.reference {
                if let current = current {
                    if reference == current { return true }
                    else { return false }
                } else { return false}
            } else { return false }
        }
    }
    init(title: String = "RVLoadOperation", datasource: RVBaseDatasource4<T>, scrollView: UIScrollView?, front: Bool = false, callback: @escaping RVCallback<T>) {
        self.datasource             = datasource
        self.scrollView             = scrollView

        self.front                  = front
        super.init(title: "\(title) with front: \(front)", callback: callback, parent: nil)
    }
    override func asyncMain() {
       // print("In \(self.classForCoder).asyncMain line \(#line)")
        InnerMain()
    }
    func unsubscribeByArea() {
       // print("In \(self.classForCoder).unsubscribeByArea")
        if let subscription = self.datasource.subscription {
            if subscription.isFront && self.front {
                self.datasource.unsubscribe{}
            } else if !subscription.isFront && !self.front {
                self.datasource.unsubscribe{}
            }
        }
    }
    func subscriptionActive(front: Bool) -> Bool {
        if let subscription = self.datasource.subscription {
            if front && subscription.isFront { return subscription.active }
            if !front && !subscription.isFront { return subscription.active }
            return false
        }
        return false
    }
    func subscrtionArea(front: Bool) -> Bool {
        if let subscription = self.datasource.subscription {
            if front && subscription.isFront { return true }
            if !front && !subscription.isFront { return true }
            return false
        } else { return false}
    }
    func initiateSubscription(subscription: RVSubscription, query: RVQuery, reference: T?, callback: @escaping () -> Void) {
     //   print("In \(self.classForCoder).initiateSubscription \(String(describing: reference))")
        self.datasource.subscriptionActive = true
        DispatchQueue.main.async {
            self.datasource.listenToSubscriptionNotification(subscription: subscription)
            if let reference = reference as? RVBaseModel? {
             //   print("In \(self.classForCoder).initiateSubscripton with reference #\(#line)")
                subscription.subscribe(query: query, reference: reference, callback: callback)
            } else if let referenceDatasource = reference as? RVBaseDatasource4<RVBaseModel> {
               // print("In \(self.classForCoder).initiateSubscription, passed casting Reference: \(reference?.description ?? "No reference") for subscription \(subscription)")
                let model = subscription.isFront ? referenceDatasource.frontElement : referenceDatasource.backElement
             //   if let model = model as? RVBaseModel? {
               // print("In \(self.classForCoder).initiateSubscripton after model #\(#line)")
                    subscription.subscribe(query: query , reference: model , callback: callback)
             //   }
                
            
            } else {
                print("In \(self.classForCoder).initiateSubscription, failed casting reference to RVBaseModel. Reference: \(reference?.description ?? "No reference"), Generic Type is \(type(of: T.self))")
                callback()
            }
            
        }
    }
    func InnerMain() {
        //print("In \(self.classForCoder).InnerMain")
        if self.isCancelled {
            finishUp(items: itemsPlug, error: nil)
            return
        } else {
            self.datasource.scrollView = self.scrollView
            // Front loading is deactivated in .filter mode
            if self.front && (self.datasource.datasourceType == .filter) && (self.subscriptionOperation == .none) {
                finishUp(items: itemsPlug , error: nil)
                return
            } else if (self.subscriptionOperation != .none) && self.datasource.datasourceType == .filter {
                let error = RVError(message: "In \(self.classForCoder).InnerMain \(#line), have Subscription Operation \(self.subscriptionOperation), but Database is in Filter mode")
               finishUp(items: itemsPlug , error: error)
               return
            }
            if var query = self.datasource.baseQuery {
                 //print("In \(self.classForCoder).InnerMain, for front: \(self.front) haveQuery frontOperationActive: \(self.datasource.frontOperationActive), backOperationActive: \(self.datasource.backOperationActive)")
                if self.subscriptionOperation != .none {
                    // Neil believes that don't have to block anything when it's a subscription operation
                    /*
                    if self.datasource.subscriptionActive {
                        self.finishUp(items: self.itemsPlug, error: nil)
                        return
                    }
 */
                } else if self.front {
                    // Used for bulk queries. Avoids multiple bulk queries being issued
                    if self.datasource.frontOperationActive {
                        self.finishUp(items: self.itemsPlug, error: nil)
                        return
                    } else if subscriptionActive(front: true) {
                        self.finishUp(items: self.itemsPlug, error: nil)
                        return
                    } else {
                    //    print("In \(self.classForCoder).InnerMain, about to call unsubscribeByArea self.front = \(self.front)")
                        self.unsubscribeByArea()
                        self.datasource.frontOperationActive = true
                    }
                } else {
                    if self.datasource.backOperationActive {
                        self.finishUp(items: self.itemsPlug, error: nil)
                        return
                    } else if subscriptionActive(front: false) {
                        self.finishUp(items: self.itemsPlug, error: nil)
                        return
                    } else {
                 //       print("In \(self.classForCoder).InnerMain about to call unsubscribeByArea self.front is \(self.front)")
                        self.unsubscribeByArea()
                        self.datasource.backOperationActive = true
                    }
                }
               // print("In \(self.classForCoder).InnerMain, about to do retrieve. Front: \(self.front)")
                query = query.duplicate()
                self.reference = self.front ? datasource.frontElement : datasource.backElement
                var query = datasource.updateSortTerm(query: query, front: self.front, candidate: self.reference)
                query = query.updateQuery4(front: self.front)
                if self.isCancelled {
                    finishUp(items: itemsPlug , error: nil)
                    return
                }
                if self.subscriptionOperation == .subscribe {
                    if let subscription = self.datasource.subscription {
                        if self.datasource.subscriptionActive { // || (subscription.isFront && self.datasource.offset != 0) {
                            self.finishUp(items: itemsPlug, error: nil)
                            return
                        } else if subscription.active {
                            let error = RVError(message: "In \(self.instanceType).InnerMain, attempting to subscribe to a collection0subscription that is already active")
                            self.finishUp(items: itemsPlug, error: error)
                            return
                        } else {
                       //     if let reference = reference as? RVBaseModel? {
                                self.initiateSubscription(subscription: subscription, query: query, reference: reference, callback: {
                                    self.finishUp(items: self.itemsPlug, error: nil)
                                })
                        //    } else {
                        //        let error = RVError(message: "In \(self.classForCoder).InnerMain, attempting a subscription with SectionDatasource. Not Implemented")
                        //        self.finishUp(items: self.itemsPlug, error: error)
                       //         return
                       //     }

                            return
                        }
                    } else {
                        let error = RVError(message: "In \(self.classForCoder).InnerMain, have subscribe operation but datasource does not have a subscription")
                        self.finishUp(items: itemsPlug, error: error)
                        return
                    }
                } else if self.subscriptionOperation == .response {
                    let error = RVError(message: "In \(self.classForCoder).InnerMain \(#line), erroneously have Response subscriptionOperation")
                    self.finishUp(items: itemsPlug, error: error)
                    return
                } else {
                    datasource.innerRetrieve(query: query, callback: { (models, error) in
                        //print("In \(self.classForCoder).InnerMain, datasource.innerRetrieve callback")
                        if self.isCancelled {
                            self.finishUp(items: models, error: error)
                            return
                        } else if let error = error {
                            error.append(message: "In \(self.instanceType).main, got error doing innerRetrieve")
                            self.finishUp(items: models, error: error)
                            return
                        }
                        else if models.count > 0 {
                           // print("In \(self.classForCoder).InnerMain, have \(models.count) models")
                            self.insert(models: models, callback: { (models, error) in
                                if let error = error {
                                    error.append(message: "In \(self.instanceType).main, got error doing insert")
                                    self.finishUp(items: models, error: error)
                                    return
                                } else {
                                    if models.count > 0 {
                                        self.cleanup(models: models, callback: { (models, error) in
                                            self.refreshViews {
                                                self.finishUp(items: models, error: nil)
                                            }
                                        })
                                    } else {
                                        self.finishUp(items: models , error: nil)
                                    }

                                    return
                                }
                            })
                            return
                        } else {
                            self.checkSubscription()
                            self.finishUp(items: models, error: error)
                            return
                        }
                    })
                }
            } else {
                //print("In \(self.classForCoder).InnerMain, no query")
                let error = RVError(message: "In \(self.classForCoder).InnerMain, no query")
                self.finishUp(items: itemsPlug , error: error)
            }
        }
    }
    deinit {
        //print("In \(self.classForCoder).deinit")
    }

    func innerCleanup() -> (indexPaths: [IndexPath], sectionIndexes: IndexSet) {
        if let subscription = self.datasource.subscription {
            if self.datasource.subscriptionActive {
                if subscription.isFront { return innerCleanup2(front: false)}
                else { return innerCleanup2(front: true) }
            }
        }
        if self.datasource.lastItemIndex < (self.datasource.virtualCount / 2) { return innerCleanup2(front: false) }
        else { return innerCleanup2(front: true) }
    }
    func refreshViews(callback: @escaping () -> Void) {
 //       print("In \(self.classForCoder).refreshViews line #\(#line)")
        if self.isCancelled {
            callback()
            return
        } else {
            DispatchQueue.main.async {
                if let tableView = self.scrollView as? UITableView {
                    tableView.beginUpdates()
                    if let visibleIndexPaths = tableView.indexPathsForVisibleRows {
                        if visibleIndexPaths.count > 0 {
                            var section = -1
                            for indexPath in visibleIndexPaths {
                                //print("In \(self.classForCoder).refreshViews indexPath \(indexPath.section) \(indexPath.row)")
                                if indexPath.section == self.datasource.section {
                                    if let cell = tableView.cellForRow(at: indexPath) as? RVItemRetrieve {
                                        if let item = self.datasource.element(indexPath: indexPath, scrollView: tableView) as? RVBaseModel {
                                            cell.item = item
                                        }
                                    }
                                }
                                if section != indexPath.section {
                                    section = indexPath.section
                                    if let header = tableView.headerView(forSection: section) as? RVItemRetrieve {
                                        if let sectionModel = self.datasource.sectionModel as? RVBaseModel {
                                            header.item = sectionModel
                                        }
                                    }
                                }
                            }
                            tableView.endUpdates()
                            callback()
                            return
                        } else {
                            tableView.endUpdates()
                            callback()
                            return
                        }
                    } else {
                        tableView.endUpdates()
                        callback()
                        return
                    }
                } else if let collectionView = self.scrollView as? UICollectionView {
                    collectionView.performBatchUpdates({
                        var section = 01
                        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
                        if visibleIndexPaths.count > 0 {
                            for indexPath in visibleIndexPaths {
                                if indexPath.section == self.datasource.section {
                                    if let cell = collectionView.cellForItem(at: indexPath) as? RVItemRetrieve {
                                        if let item = self.datasource.element(indexPath: indexPath, scrollView: collectionView) as? RVBaseModel {
                                            cell.item = item
                                        }
                                    }
                                }
                                if section != indexPath.section {
                                    section = indexPath.section
                                    // no collectionView header
                                }
                            }
                        }
                    }, completion: { (success) in
                        callback()
                    })
                    return
                } else if self.scrollView == nil {
                    callback()
                } else {
                    callback()
                }
            }
        }
    }
    func innerCleanup2(front: Bool) -> (indexPaths: [IndexPath], sectionIndexes: IndexSet) {
        var indexPaths = [IndexPath]()
        var sectionIndexes = [Int]()
        var clone = self.datasource.cloneItems()
        let excess = clone.count - self.datasource.maxArraySize
        if (excess <= 0) { return (indexPaths: indexPaths, sectionIndexes: IndexSet(sectionIndexes) ) }
        else {
            let virtualMax = self.datasource.virtualCount-1
            let section = !self.datasource.sectionDatasourceMode ? self.datasource.section : self.datasource.FAKESECTION
            let arrayCount = clone.count - 1
            if !front {
                for i in 0..<excess {
                    if (section >= 0) {
                        indexPaths.append(IndexPath(item: virtualMax-i, section: section))
                        sectionIndexes.append(virtualMax - i)
                    }
                    clone.remove(at: arrayCount - i)
                }
                self.datasource.elements = clone
                return (indexPaths: indexPaths, sectionIndexes: IndexSet(sectionIndexes) )
            } else {
                var slicedArray = [T]()
                for i in excess..<clone.count { slicedArray.append(clone[i]) }
                self.datasource.elements = slicedArray
                self.datasource.offset = self.datasource.offset + excess
                return (indexPaths: indexPaths, sectionIndexes: IndexSet(sectionIndexes) )
            }
        }
    }
    func cleanup(models: [T], callback: @escaping([T], RVError?)-> Void) {
        DispatchQueue.main.async {
            let maxSize = self.datasource.maxArraySize
            if self.datasource.elementsCount <= maxSize {
                callback(models, nil)
                return
            } else if self.isCancelled {
                callback(models, nil)
                return
            } else if let tableView = self.scrollView as? UITableView {
                tableView.beginUpdates()
                let paths = self.innerCleanup()
                if (paths.indexPaths.count > 0) && (!self.datasource.collapsed) {
                    if !self.datasource.sectionDatasourceMode {
                        tableView.deleteRows(at: paths.indexPaths, with: self.datasource.rowAnimation)
                    } else {
                        tableView.deleteSections(paths.sectionIndexes, with: self.datasource.rowAnimation)
                    }
                   
                }
                tableView.endUpdates()
                callback(models, nil)
                return
            } else if let collectionView = self.scrollView as? UICollectionView {
                collectionView.performBatchUpdates({
                    let paths = self.innerCleanup()
                    if (paths.indexPaths.count > 0 ) && (!self.datasource.collapsed) {
                        if !self.datasource.sectionDatasourceMode {
                            collectionView.deleteItems(at: paths.indexPaths)
                        } else {
                            collectionView.deleteSections(paths.sectionIndexes)
                        }
                        
                    }
                }, completion: { (success) in
                    callback(models, nil)
                    return
                })
            } else if self.scrollView == nil {
                let _ = self.innerCleanup()
                callback(models, nil)
                return
            } else {
                let error = RVError(message: "In \(self.classForCoder).cleanupBack, erroreous scrollView \(self.scrollView?.description ?? " no ScrollView")")
                callback(models, error)
                return
            }
        }
    }
    func backHandler(models: [T]) -> (indexPaths: [IndexPath], sectionIndexes: IndexSet) {
        var indexPaths = [IndexPath]()
        var sectionIndexes = [Int]()
        if models.count == 0 { return (indexPaths, IndexSet(sectionIndexes)) }
        let section = !self.datasource.sectionDatasourceMode ? self.datasource.section : self.datasource.FAKESECTION
        //let virtualIndex = datasource.elementsCount + datasource.offset
        let virtualIndex = self.datasource.virtualCountIndependentOfCollapse
        var clone = datasource.cloneItems()

        for i in 0..<models.count {
            clone.append(models[i])
            if (section >= 0) {
                indexPaths.append(IndexPath(row: virtualIndex + i, section: section))
                sectionIndexes.append(virtualIndex + i)
            }
        }
        self.datasource.elements = clone
        //print("In \(self.classForCoder).backHandler, items count = \(self.datasource.elementsCount) collapsed: \(self.datasource.collapsed), datasource \(self.datasource.description )")
        return (indexPaths: indexPaths, sectionIndexes: IndexSet(sectionIndexes))
    }
    func frontHandler(newModels: [T]) -> (indexPaths: [IndexPath], sectionIndexes: IndexSet) {
        //print("In \(self.classForCoder).frontHandler")
        var indexPaths = [IndexPath]()
        var sectionIndexes = [Int]()
        if newModels.count == 0 { return (indexPaths, IndexSet(sectionIndexes)) }
        var clone = datasource.cloneItems()
 

        let newCount = newModels.count
        if self.datasource.offset > 0 {
            print("In \(self.classForCoder).insertFront offset is \(self.datasource.offset) and newCount = \(newCount)")
            if newCount <= datasource.offset {
                for i in 0..<newCount { clone.insert(newModels[i], at: 0) }
                self.datasource.elements = clone
                self.datasource.offset = self.datasource.offset - newCount
                return (indexPaths: indexPaths, sectionIndexes: IndexSet(sectionIndexes))
            } else {
                for i in 0..<self.datasource.offset { clone.insert(newModels[i], at: 0) }
              //  self.datasource.offset = 0
                //let section = self.datasource.section
                let section = !self.datasource.sectionDatasourceMode ? self.datasource.section : self.datasource.FAKESECTION
                var rowIndex: Int = 0
              //  var rowIndex: Int = (self.subscriptionOperation != .response) ? self.datasource.virtualCount : 0
                if (self.subscriptionOperation != .response) {
                    rowIndex = self.datasource.virtualCount
                } else {
                    rowIndex = !self.datasource.zeroCellModeOn ? 0 : self.datasource.zeroCellIndex
                }
                for i in (self.datasource.offset)..<newCount {
                    clone.insert(newModels[i], at: 0)
                    if (section >= 0 ) {
                        indexPaths.append(IndexPath(item: rowIndex, section: section))
                        sectionIndexes.append(rowIndex)
                    }
                    rowIndex = rowIndex + 1
                }
                self.datasource.offset = 0
                self.datasource.elements = clone
                return (indexPaths: indexPaths, sectionIndexes: IndexSet(sectionIndexes))
            }
        } else {
           // var rowIndex: Int = (self.subscriptionOperation != .response) ? self.datasource.virtualCount : 0
            var rowIndex: Int = 0
            //  var rowIndex: Int = (self.subscriptionOperation != .response) ? self.datasource.virtualCount : 0
            if (self.subscriptionOperation != .response) {
                rowIndex = self.datasource.virtualCount
            } else {
                rowIndex = !self.datasource.zeroCellModeOn ? 0 : self.datasource.zeroCellIndex
            }
           // let section = self.datasource.section
            let section = !self.datasource.sectionDatasourceMode ? self.datasource.section : self.datasource.FAKESECTION
            for i in 0..<newCount {
                clone.insert(newModels[i], at: 0)
                if (section >= 0 ) {
                    indexPaths.append(IndexPath(item: rowIndex, section: section))
                    sectionIndexes.append(rowIndex)
                }
                rowIndex = rowIndex + 1
            }
            self.datasource.offset = 0
            self.datasource.elements = clone
            return (indexPaths: indexPaths, sectionIndexes: IndexSet(sectionIndexes))
        }
    }
    
    
    func checkSubscription() {
        if self.subscriptionOperation == .none {
            
            //  if (self.front && self.datasource.offset == 0) || !self.front {
            if let subscription = self.datasource.subscription {
                if !subscription.active {
                //    print("In \(self.classForCoder).insert. About to call subscribe self.front = \(self.front)")
                    self.datasource.subscribe(scrollView: self.scrollView, front: self.front)
                }
            }
            //   }
        }
    }
    func insert(models: [T], callback: @escaping RVCallback<T>) {
       // print("In \(self.classForCoder).insert with models: \(models.count) \(self.front)")
        DispatchQueue.main.async {
            if self.isCancelled {
                callback(models, nil)
                return
            }
            var sizedModels = [T]()
            if self.datasource.datasourceType == .filter {
                let room = self.datasource.maxArraySize - self.datasource.elementsCount
                if (models.count <= room) { sizedModels = models }
                else if models.count > 0 {
                    for i in 0..<room { sizedModels.append(models[i]) }
                }
            } else { sizedModels = models }
            var originalRow: Int = -1
            var indexPathsCount: Int = 0
            if let tableView = self.scrollView as? UITableView {
                let originalScrollEnabled = tableView.isScrollEnabled
                let delay = ((self.front && !self.datasource.collapsed) && self.subscriptionOperation != .response )  ? 0.2 : 0.0001
                if ((self.front && !self.datasource.collapsed) && self.subscriptionOperation != .response) {
                    tableView.isScrollEnabled = false
                    tableView.layer.removeAllAnimations()
                }
                Timer.scheduledTimer(withTimeInterval: delay, repeats: false, block: { (timer) in
                    if self.isCancelled {
                        tableView.isScrollEnabled = true
                        callback(sizedModels, nil)
                        return
                    }
                    tableView.beginUpdates()
                    if sizedModels.count >= 0 {
                       // print("In \(self.classForCoder).insert, have \(models.count) \(String(describing: models.first))")
                        if let indexPaths = tableView.indexPathsForVisibleRows { if let indexPath = indexPaths.last { originalRow = indexPath.row } }
                        
                        // print("In \(self.classForCoder).insert, subscriptionOperation = \(self.subscriptionOperation)")
                        if (self.subscriptionOperation == .response) || self.referenceMatch {
                            let point = CGPoint(x: 10, y: (tableView.bounds.origin.y + tableView.bounds.height))
                            if let indexPath = tableView.indexPathForRow(at: point) { originalRow = indexPath.row }
                            var indexPaths = [IndexPath]()
                            var sectionIndexes = IndexSet()
                            //print("In \(self.classForCoder).insert, tableView reference match")
                            if self.front {
                                let paths = self.frontHandler(newModels: sizedModels)
                                indexPaths = paths.indexPaths
                                sectionIndexes = paths.sectionIndexes
                            }
                            else {
                                let paths = self.backHandler(models: sizedModels)
                                indexPaths = paths.indexPaths
                                sectionIndexes = paths.sectionIndexes
                            }
                            //print("In \(self.classForCoder).insert numberOfIndexPaths = \(indexPaths.count)")
                            if  (!self.datasource.collapsed)  {
                                if (!self.datasource.sectionDatasourceMode) && (indexPaths.count > 0) {
                                    tableView.insertRows(at: indexPaths, with: UITableViewRowAnimation.middle)
                                } else if sectionIndexes.count > 0 {
                                    //print("In \(self.classForCoder).insert \(#line), about to insertSections number: \(sectionIndexes.count)")
                                    tableView.insertSections(sectionIndexes , with: UITableViewRowAnimation.top)
                                }
                                indexPathsCount = indexPaths.count
                            }
                        } else {
                            print("In \(self.classForCoder).insert, tableView no reference match reference is \(self.reference?.description ?? " no reference")")
                            /*
                             if self.subscriptionOperation {
                             if let subscription = self.datasource.subscription {
                             subscription.reference = self.front ? self.datasource.frontElement : self.datasource.backElement
                             }
                             }
                             */
                        }
                    }

                    self.checkSubscription()
                    tableView.endUpdates()
                    tableView.isScrollEnabled = originalScrollEnabled
                    if self.isCancelled {
                        callback(sizedModels, nil)
                        return
                    }
                    if (!self.datasource.collapsed) && (self.front) && (originalRow >= 0) && (indexPathsCount > 0) && (self.subscriptionOperation != .response) {
                        tableView.beginUpdates()
                        let section = !self.datasource.sectionDatasourceMode ? self.datasource.section : self.datasource.FAKESECTION
                        if section >= 0 {
                            var indexPath = IndexPath(row: (originalRow + indexPathsCount), section: section)
                            var sectionIndex = originalRow + indexPathsCount
                            if indexPath.row >= self.datasource.virtualCount { indexPath.row = self.datasource.virtualCount - 1 }
                            if sectionIndex >= self.datasource.virtualCount { sectionIndex = self.datasource.virtualCount - 1 }
                            if !self.datasource.sectionDatasourceMode {
                         //       tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: false) // NEIL TOOK OUT TABLEVIEW SCROLL
                                if let indexPaths = tableView.indexPathsForVisibleRows {
                                    if indexPaths.count < 9 {
                                     //   tableView.reloadRows(at: indexPaths, with: UITableViewRowAnimation.bottom)  // NEIL TOOK OUT RELOAD
                                    }
                                }
                            } else {
                                // Neil unclear how to scroll Headers
                            }
                        }
                        tableView.endUpdates()
                        callback(sizedModels, nil)
                        return
                    } else if  (self.subscriptionOperation == .response) {
                        tableView.beginUpdates()
                        let section = self.datasource.section
                        if section >= 0 {
                            if self.datasource.virtualCount > 0 {
                                if !self.datasource.sectionDatasourceMode {
                                    let rowIndex = (!self.datasource.zeroCellModeOn) ? 0 : self.datasource.zeroCellIndex
                                    _ = IndexPath(row: rowIndex, section: section)
                             //       tableView.scrollToRow(at: indexPath, at: .top, animated: false)  // NEIL TOOK OUT TABLEVIEW SCROLL
                                } else {
                                    // Neil Unclear how to scroll a Header
                                }

                            }
                        }
                        tableView.endUpdates()
                        callback(sizedModels, nil)
                    } else {
                        callback(sizedModels, nil)
                    }
                })
                return
            } else if let collectionView = self.scrollView as? UICollectionView {
                collectionView.performBatchUpdates({
                    if !self.isCancelled {
                        if (self.subscriptionOperation == .none) && self.referenceMatch {

                            var paths: (indexPaths: [IndexPath], sectionIndexes: IndexSet)
                            if self.front { paths = self.frontHandler(newModels: sizedModels) }
                            else { paths = self.backHandler(models: sizedModels) }
                            if !self.datasource.sectionDatasourceMode {
                                if  (!self.datasource.collapsed)  { collectionView.insertItems(at: paths.indexPaths) }
                            } else if !self.datasource.collapsed {
                                collectionView.insertSections(paths.sectionIndexes)
                            }
                            
                        }
                    }
                }, completion: { (success) in
                    if self.subscriptionOperation == .none {
                        self.datasource.subscribe(scrollView: self.scrollView, front: self.front)
                    }
                    callback(sizedModels, nil)
                })
                return
            } else if self.scrollView == nil {
                if (self.referenceMatch) && (self.subscriptionOperation == .none) {
                    if self.front { let _ = self.frontHandler(newModels: sizedModels) }
                    else { let _ = self.backHandler(models: sizedModels) }
                }
                callback(sizedModels, nil)
                return
            } else {
                let error = RVError(message: "In \(self.instanceType).insert, erroroneous scrollView \(self.scrollView?.description ?? " no ScrollView")")
                callback(sizedModels, error)
                return
            }
        }
    }
    func finishUp(items: [T], error: RVError?) {
        DispatchQueue.main.async {
          //  print("In \(self.classForCoder).finishUp")
            self.callback(items, error)
            Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false , block: { (timer) in
                if (self.front) && ( self.subscriptionOperation == .none) { self.datasource.frontOperationActive = false }
                else if (!self.front) && (self.subscriptionOperation == .none) {
                    // print("In \(self.classForCoder).finishUp, setting backOperation to false")
                    self.datasource.backOperationActive = false
                }
            })
            self.completeOperation()
        }
    }
}
