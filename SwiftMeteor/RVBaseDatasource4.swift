//
//  RVBaseDatasource4.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/21/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit

typealias RVCallback = ([RVBaseModel], RVError?) -> Void
typealias DSOperation = () -> Void

enum RVExpandCollapseOperationType {
    case collapseOnly
    case expandOnly
    case collapseAndZero
    case collapseZeroAndExpand
    case collapseZeroExpandAndLoad
    case toggle
}
protocol RVItemRetrieve: class {
    var item: RVBaseModel? { get set }
}
class RVBaseDatasource4<T:NSObject>: NSObject {
    enum DatasourceType: String {
        case top        = "Top"
        case main       = "Main"
        case filter     = "Filter"
        case subscribe  = "Subscribe"
        case unknown    = "Unknown"
    }
    let LAST_SORT_STRING = "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
    var instanceType: String { get { return String(describing: type(of: self)) } }
    let identifier = NSDate().timeIntervalSince1970
    var baseQuery: RVQuery? = nil
    fileprivate let queue = RVOperationQueue()
    var rowAnimation: UITableViewRowAnimation = UITableViewRowAnimation.automatic
    var items = [RVBaseModel]()
    var sections = [RVBaseDatasource4]()
    var section: Int { get { return manager.sectionIndex(datasource: self) }}
    var backOperationActive: Bool = false
    var frontOperationActive: Bool = false
    var subscriptionActive: Bool = false
    var maxArraySize: Int = 300
    var collapsed: Bool = false
    var subscription: RVSubscription? = nil
    var notificationInstalled: Bool = false
    var itemsCount: Int { return items.count}
    var sectionModel: RVBaseModel? = nil
    func append(_ newElement: NSObject) {
        if let item = newElement as? RVBaseModel {
            items.append(item)
        } else if let section = newElement as? RVBaseDatasource4 {
            sections.append(section)
        } else {
            print("In \(self.classForCoder).append object is neither RVBaseModel or RVBaseDatasource4 \(newElement)")
        }
    }
    func insert(_ newElement: NSObject, at: Int) {
        if let item = newElement as? RVBaseModel {
            items.insert(item, at: at)
        } else if let section = newElement as? RVBaseDatasource4 {
            sections.insert(section, at: at)
        } else {
            print("In \(self.classForCoder).insert object is neither RVBaseModel or RVBaseDatasource4 \(newElement)")
        }
    }
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
            //print("In \(self.classForCoder).offset setting to \(newValue) and arraysize is \(itemsCount)")
        }
    }
    var datasourceType: DatasourceType = .unknown
    var manager: RVDSManager4<T>
   // var model: RVBaseModel { return RVBaseModel() }
    fileprivate var lastItemIndex: Int = 0
    fileprivate let TargetBackBufferSize: Int = 20
    fileprivate let TargetFrontBufferSize: Int = 20
    fileprivate var backBufferSize: Int {
        get {
            if TargetBackBufferSize < (self.maxArraySize / 2) { return TargetBackBufferSize }
            else if self.maxArraySize < 50 {
                print("In \(self.classForCoder) maxArraySize too small maxArraySize: \(self.maxArraySize)")
            }
            return self.maxArraySize / 2 - 1
        }
    }
    fileprivate var frontBufferSize: Int {
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
    func innerRetrieve(query: RVQuery, callback: @escaping RVCallback) {
        DispatchQueue.main.async {
            self.retrieve(query: query, callback: callback)
        }
    }
    var subscriptionMaxCount: Int = 10
    fileprivate var _subscriptionMaxCount: Int = 0
    func retrieve(query: RVQuery, callback: @escaping RVCallback) {
        print("In RVBaseDatasource4.retrieve, need to override")
        RVBaseModel.bulkQuery(query: query, callback: callback as! ([RVBaseModel]?, RVError?) -> Void)
    }
    init(manager: RVDSManager4<T>, datasourceType: RVBaseDatasource4<T>.DatasourceType, maxSize: Int) {
        self.manager = manager
        self.datasourceType = datasourceType
        self.maxArraySize = ((maxSize < 500) && (maxSize > 50)) ? maxSize : 500
        super.init()
    }

    func cancelAllOperations() { self.queue.cancelAllOperations()}
    func unsubscribe(callback: @escaping () -> Void) {
        //print("In \(self.classForCoder).unsubscribe Need to implement")
            if let subscription = self.subscription {
                NotificationCenter.default.removeObserver(self, name: subscription.notificationName, object: nil)
                notificationInstalled = false
                subscription.unsubscribe(callback: {
                    self.subscriptionActive = false
                    callback()
                })
        } else {
            self.subscriptionActive = false
            callback()
        }
    }
    func listenToSubscriptionNotification(subscription: RVSubscription) {
        print("In \(self.classForCoder).listenToSubscription")
        if !notificationInstalled {
            notificationInstalled = true
            NotificationCenter.default.addObserver(self, selector: #selector(RVBaseDatasource4.receiveSubscriptionResponse(notification:)), name: subscription.notificationName, object: nil)
        }
    }
    func subscribe(scrollView: UIScrollView?, front: Bool) {
        if !self.subscriptionActive {
            //subscription.reference = self.items.first
            if let subscription = self.subscription {
                if (subscription.isFront && front) || (!subscription.isFront && !front) {
                    print("Neil check this \(self.classForCoder).subscribe, took out subscriptionOperation flag")
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
                }
            }
        }
    }
    func receiveSubscriptionResponse(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let payload = userInfo[RVPayload.payloadInfoKey] as? RVPayload {
                print("In \(self.classForCoder).receiveSubscription have payload \(payload.toString())")
                if let subscription = self.subscription {
                    if subscription.identifier == payload.subscription.identifier {
                        //print("In \(self.classForCoder).receiveSubscription subscriptions match")
                        let operation = RVSubcriptionResponseOperation(subscription: payload.subscription, datasource: self, incomingModels: payload.models, callback: { (models, error) in
                            if let error = error {
                                error.printError()
                            }
                        })
                        self.queue.addOperation(operation)
                    }
                }
            }
        }
        
    }

    deinit {
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
            print("In \(self.classForCoder).updateSortTerms, erroneous number of sort Tersm: \(query.sortTerms)")
        }
        if let sortTerm = query.sortTerms.first {
            let firstString: AnyObject = "" as AnyObject
            let lastString:  AnyObject = self.LAST_SORT_STRING as AnyObject
            var comparison = (sortTerm.order == .ascending) ?  RVComparison.gte : RVComparison.lte
            var sortString: AnyObject = (sortTerm.order == .descending) ? lastString : firstString
            if front {
                comparison = (sortTerm.order == .descending) ?  RVComparison.gt : RVComparison.lt
                sortString = (sortTerm.order == .descending) ? firstString : lastString
            }
            var sortDate: Date  = (sortTerm.order == .ascending)  ? query.decadeAgo : Date()
            if front { sortDate = (sortTerm.order == .descending) ? query.decadeAgo : Date() }
            
            var finalValue: AnyObject = sortString as AnyObject

            var strip = [RVKeys : AnyObject]()
            if let candidate = candidate {
                if let candidate = candidate as? RVBaseModel {
                    strip = self.stripCandidate(candidate: candidate)
                } else if let datasource = candidate as? RVBaseDatasource4 {
                    strip = self.stripCandidate(candidate: datasource.sectionModel)
                }
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
    var numberOfItems: Int { get { return virtualCount } }
    var virtualCount: Int {
        get {
            if self.collapsed { return 0 }
            return self.itemsCount + self.offset
        }
    }
    func inFront(scrollView: UIScrollView?) {
        //print("In \(self.classForCoder).inFront. ........................................... #######")
        if self.datasourceType == .filter { return }
        DispatchQueue.main.async {
            if self.frontOperationActive { return }
            let operation = RVLoadOperation(datasource: self, scrollView: scrollView, front: true, callback: { (models, error) in
                if let error = error {
                    error.append(message: "In \(self.classForCoder).inFront, got error")
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
    func item(index: Int, scrollView: UIScrollView?, updateLast: Bool = true) -> RVBaseModel? {
        if updateLast { self.lastItemIndex = index }
        if index < 0 {
            print("In \(self.instanceType).item, got negative index \(index)")
            return nil
        } else if index >= self.virtualCount {
            print("In \(self.instanceType).item, index \(index) greater than virtualCount: \(self.virtualCount)")
            return nil
        }
        var OKtoRetrieve: Bool = true
        if self.subscription != nil {
            if self.subscriptionActive {
                if self.itemsCount >= self.maxArraySize {
                    OKtoRetrieve = false
                }
            }
        }
        let physicalIndex = index - offset
        if physicalIndex < 0 {
            //print("In \(self.instanceType).item got physical index less than 0 \(physicalIndex). Offset is \(offset)")
            //print("In \(self.classForCoder).item calling inBack: index = \(index), count: \(itemsCount), offset: \(self.offset), backBuffer: \(self.backBufferSize)")
            if OKtoRetrieve {inFront(scrollView: scrollView)}
            return nil
        } else if physicalIndex < itemsCount {
            if (physicalIndex + self.backBufferSize) > itemsCount {
                //print("In \(self.classForCoder).item calling inBack:  index = \(index), count: \(itemsCount), offset: \(self.offset), backBuffer: \(self.backBufferSize)")
                if OKtoRetrieve {inBack(scrollView: scrollView) }
            }
            if physicalIndex < self.frontBufferSize {
               // print("In \(self.classForCoder).item calling inFront: index = \(index), count: \(itemsCount), offset: \(self.offset), backBuffer: \(self.backBufferSize)")
                if OKtoRetrieve { inFront(scrollView: scrollView) }
            }
            return items[physicalIndex]
        } else {
            print("In \(self.instanceType).item physicalIndex of \(physicalIndex) exceeds or equals array size \(itemsCount). Offset is \(self.offset)")
            return nil
        }
    }
    func scroll(index: Int, scrollView: UIScrollView) {
        print("in \(self.classForCoder).scroll \(index)")
        let _ = self.item(index: index, scrollView: scrollView, updateLast: false)
    }
    func cloneItems() -> [RVBaseModel] {
        var clone = [RVBaseModel]()
        for item in items { clone.append(item) }
        return clone
    }
    var frontItem: RVBaseModel? {
        get {
            if itemsCount == 0 { return nil }
            else { return items[0] }
        }
    }
    var backItem: RVBaseModel? {
        get {
            if itemsCount == 0 { return nil }
            else { return items[itemsCount - 1] }
        }
    }

    func restart(scrollView: UIScrollView?, query: RVQuery, callback: @escaping RVCallback) {
        self.unsubscribe{}
        self.cancelAllOperations()
        self.queue.addOperation(RVExpandCollapseOperation(datasource: self, scrollView: scrollView, operationType: .collapseZeroExpandAndLoad, query: query, callback: callback))
    }
    func expand(scrollView: UIScrollView?, callback: @escaping RVCallback) {
        self.queue.addOperation(RVExpandCollapseOperation(datasource: self, scrollView: scrollView, operationType: .expandOnly, callback: callback))
    }
    func collapse(scrollView: UIScrollView?, callback: @escaping RVCallback) {
        self.queue.addOperation(RVExpandCollapseOperation(datasource: self, scrollView: scrollView, operationType: .collapseOnly, callback: callback))
    }
    func toggle(scrollView: UIScrollView?, callback: @escaping RVCallback) {
        self.queue.addOperation(RVExpandCollapseOperation(datasource: self, scrollView: scrollView, operationType: .toggle, callback: callback))
    }

}

class RVExpandCollapseOperation<T:NSObject>: RVLoadOperation<T> {


    var operationType: RVExpandCollapseOperationType
    var query: RVQuery
    var emptyModels = [RVBaseModel]()
    init(datasource: RVBaseDatasource4<T>, scrollView: UIScrollView?, operationType: RVExpandCollapseOperationType, query: RVQuery = RVQuery(), callback: @escaping RVCallback) {
        self.operationType  = operationType
        self.query = query
        super.init(title: "RVExpandCollapseOperation", datasource: datasource, scrollView: scrollView, callback: callback)
    }
    func handleCollapse() -> [IndexPath] {
        var indexPaths = [IndexPath]()
        let section = self.datasource.section
        let lastItem = self.datasource.offset + self.datasource.itemsCount
        if (section >= 0) && (lastItem > 0) { for row in 0..<lastItem { indexPaths.append(IndexPath(row: row, section: section)) } }
        if (self.operationType == .collapseAndZero) || (self.operationType == .collapseZeroAndExpand ) || (self.operationType == .collapseZeroExpandAndLoad){
            self.datasource.items = [RVBaseModel]()
            self.datasource.offset = 0
        }
        if (operationType == .collapseZeroAndExpand) || (operationType == .collapseZeroExpandAndLoad) {
            self.datasource.collapsed = false
        } else {
            self.datasource.collapsed = true
        }
        return indexPaths
    }

    override func asyncMain() {
        var operationType = self.operationType
        if operationType == .toggle { operationType = (self.datasource.collapsed) ? .expandOnly : .collapseOnly }
        if self.isCancelled {
            self.finishUp(models: self.emptyModels, error: nil)
            return
        } else if (operationType != .expandOnly) {
            self.datasource.scrollView = self.scrollView
            if self.datasource.collapsed {
                if (operationType == .collapseAndZero) || (operationType == .collapseZeroAndExpand) || (operationType == .collapseZeroExpandAndLoad) {
                    self.datasource.items = [RVBaseModel]()
                    self.datasource.offset = 0
                }
                if (operationType == .collapseZeroAndExpand) || (operationType == .collapseZeroExpandAndLoad) { self.datasource.collapsed = false }
                self.finishUp(models: self.emptyModels, error: nil)
                return
            } else {
                DispatchQueue.main.async {
                    if self.isCancelled {
                        self.finishUp(models: self.emptyModels, error: nil)
                        return
                    } else {
                        if let tableView = self.scrollView as? UITableView {
                            tableView.beginUpdates()
                            if !self.isCancelled {
                                let indexPaths = self.handleCollapse()
                                if indexPaths.count > 0 { tableView.deleteRows(at: indexPaths, with: UITableViewRowAnimation.none) }
                                tableView.endUpdates()
                            }
                            if (operationType == .collapseZeroExpandAndLoad) {
                               // print("In \(self.classForCoder).main, about to do InnerMain, collapsed = \(self.datasource.collapsed)")
                                self.datasource.baseQuery = self.query
                                self.InnerMain()
                            } else {
                                self.finishUp(models: self.emptyModels, error: nil)
                            }
                            return
                        } else if let collectionView = self.scrollView as? UICollectionView {
                            collectionView.performBatchUpdates({
                                if self.isCancelled { return }
                                let indexPaths = self.handleCollapse()
                                if indexPaths.count > 0 { collectionView.deleteItems(at: indexPaths) }
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
                                self.datasource.items = [RVBaseModel]()
                                self.datasource.offset = 0
                            }
                            if (operationType == .collapseZeroAndExpand) || (operationType == .collapseZeroExpandAndLoad) {
                                self.datasource.collapsed = false
                            } else {
                                self.datasource.collapsed = true
                            }
                            if (operationType == .collapseZeroExpandAndLoad) {
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
                            let indexPaths = self.handleExpand()
                            tableView.insertRows(at: indexPaths, with: self.datasource.rowAnimation)
                        }
                        tableView.endUpdates()
                        self.finishUp(models: self.datasource.items, error: nil)
                        return
                    } else if let collectionView = self.scrollView as? UICollectionView {
                        collectionView.performBatchUpdates({
                            if !self.isCancelled {
                                let indexPaths = self.handleExpand()
                                collectionView.insertItems(at: indexPaths)
                            }
                        }, completion: { (success) in
                            self.finishUp(models: self.datasource.items, error: nil)
                        })
                        return
                    } else if self.scrollView != nil {
                        let _ = self.handleExpand()
                        self.finishUp(models: self.datasource.items, error: nil)
                        return
                    } else {
                        let error = RVError(message: "In \(self.classForCoder).main, invalid scrollView \(self.scrollView?.description ?? " no scroll view")")
                        self.finishUp(models: self.datasource.items, error: error)
                        return
                    }
                }
            } else {
                self.finishUp(models: self.datasource.items, error: nil)
                return
            }
        }
    }
    func handleExpand() -> [IndexPath] {
        var indexPaths = [IndexPath]()
        let section = self.datasource.section
        let lastItem = self.datasource.offset + self.datasource.itemsCount
        if (section >= 0) && (lastItem > 0) { for row in 0..<lastItem { indexPaths.append(IndexPath(row: row, section: section)) } }
        self.datasource.collapsed = false
        return indexPaths
    }
    func finishUp(models: [RVBaseModel], error: RVError?) {
        DispatchQueue.main.async {
            self.callback(models, error)
            self.completeOperation()
        }
    }
}
class RVSubscribeOperation<T:NSObject>: RVLoadOperation<T> {
    init(datasource: RVBaseDatasource4<T>, subscription: RVSubscription, callback: @escaping RVCallback) {
        super.init(title: "SubscriptionOperation", datasource: datasource, scrollView: datasource.scrollView, front: subscription.isFront, callback: callback)
        self.subscriptionOperation = .subscribe
    }
}
class RVSubcriptionResponseOperation<T:NSObject>: RVLoadOperation<T> {

    var incomingModels: [RVBaseModel]
    var responseType: RVEventType
    var sourceSubscription: RVSubscription
    init(title: String = "RVSubscriptionResponseOperation", subscription: RVSubscription, datasource: RVBaseDatasource4<T>, incomingModels: [RVBaseModel], responseType: RVEventType = .added, callback: @escaping RVCallback) {
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
        super.init(title: title, datasource: datasource, scrollView: scrollView, front: front, callback: callback)
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
class RVLoadOperation<T:NSObject>: RVAsyncOperation {
    enum SubscriptionOperation {
        case none
        case subscribe
        case response
    }


    var datasource: RVBaseDatasource4<T>
    weak var scrollView: UIScrollView?

    var reference: NSObject? = nil
    var front: Bool
    var subscriptionOperation: SubscriptionOperation = .none
    var referenceMatch: Bool {
        get {
            let current = self.front ? self.datasource.frontItem : self.datasource.backItem
            if (reference == nil) && (current == nil) { return true }
            if let reference = self.reference {
                if let current = current {
                    if reference == current { return true }
                    else { return false }
                } else { return false}
            } else { return false }
        }
    }
    init(title: String = "RVLoadOperation", datasource: RVBaseDatasource4<T>, scrollView: UIScrollView?, front: Bool = false, callback: @escaping RVCallback) {
        self.datasource             = datasource
        self.scrollView             = scrollView

        self.front                  = front
        super.init(title: "\(title) with front: \(front)", callback: callback, parent: nil)
    }
    override func asyncMain() {
        InnerMain()
    }
    func unsubscribeByArea() {
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
    func initiateSubscription(subscription: RVSubscription, query: RVQuery, reference: RVBaseModel?, callback: @escaping () -> Void) {
        self.datasource.subscriptionActive = true
        DispatchQueue.main.async {
            self.datasource.listenToSubscriptionNotification(subscription: subscription)
            subscription.subscribe(query: query, reference: reference, callback: callback)
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
                        self.unsubscribeByArea()
                        self.datasource.backOperationActive = true
                    }
                }
                //print("In \(self.classForCoder).InnerMain, about to do retrieve. Front: \(self.front)")
                query = query.duplicate()
                self.reference = self.front ? datasource.frontItem : datasource.backItem
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
                            if let reference = reference as? RVBaseModel? {
                                self.initiateSubscription(subscription: subscription, query: query, reference: reference, callback: {
                                    self.finishUp(items: self.itemsPlug, error: nil)
                                })
                            } else {
                                let error = RVError(message: "In \(self.classForCoder).InnerMain, attempting a subscription with SectionDatasource. Not Implemented")
                                self.finishUp(items: self.itemsPlug, error: error)
                                return
                            }

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
                        } else if models.count > 0 {
                            self.insert(models: models, callback: { (models, error) in
                                if let error = error {
                                    error.append(message: "In \(self.instanceType).main, got error doing insert")
                                    self.finishUp(items: models, error: error)
                                    return
                                } else {
                                    self.cleanup(models: models, callback: { (models, error) in
                                        self.refreshViews {
                                            self.finishUp(items: models, error: nil)
                                        }
                                    })
                                    return
                                }
                            })
                            return
                        } else {
                            self.finishUp(items: models, error: error)
                            return
                        }
                    })
                }
            } else {
                print("In \(self.classForCoder).InnerMain, no query")
                let error = RVError(message: "In \(self.classForCoder).InnerMain, no query")
                self.finishUp(items: itemsPlug , error: error)
            }
        }
    }
    deinit {
        //print("In \(self.classForCoder).deinit")
    }

    func innerCleanup() -> [IndexPath] {
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
        if self.isCancelled {
            callback()
            return
        } else {
            DispatchQueue.main.async {
                if let tableView = self.scrollView as? UITableView {
                    tableView.beginUpdates()
                    if let visibleIndexPaths = tableView.indexPathsForVisibleRows {
                        if visibleIndexPaths.count > 0 {
                            for indexPath in visibleIndexPaths {
                                //print("In \(self.classForCoder).refreshViews indexPath \(indexPath.section) \(indexPath.row)")
                                if indexPath.section == self.datasource.section {
                                    if let cell = tableView.cellForRow(at: indexPath) as? RVItemRetrieve {
                                        cell.item = self.datasource.item(index: indexPath.row, scrollView: tableView)
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
                        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
                        if visibleIndexPaths.count > 0 {
                            for indexPath in visibleIndexPaths {
                                if indexPath.section == self.datasource.section {
                                    if let cell = collectionView.cellForItem(at: indexPath) as? RVItemRetrieve {
                                        cell.item = self.datasource.item(index: indexPath.item, scrollView: collectionView)
                                    }
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
    func innerCleanup2(front: Bool) -> [IndexPath] {
        var indexPaths = [IndexPath]()
        var clone = self.datasource.cloneItems()
        let excess = clone.count - self.datasource.maxArraySize
        if (excess <= 0) { return indexPaths }
        else {
            let virtualMax = self.datasource.virtualCount-1
            let section = self.datasource.section
            let arrayCount = clone.count - 1
            if !front {
                for i in 0..<excess {
                    if (section >= 0) { indexPaths.append(IndexPath(item: virtualMax-i, section: section)) }
                    clone.remove(at: arrayCount - i)
                }
                self.datasource.items = clone
                return indexPaths
            } else {
                var slicedArray = [RVBaseModel]()
                for i in excess..<clone.count { slicedArray.append(clone[i]) }
                self.datasource.items = slicedArray
                self.datasource.offset = self.datasource.offset + excess
                return indexPaths
            }
        }
    }
    func cleanup(models: [RVBaseModel], callback: @escaping([RVBaseModel], RVError?)-> Void) {
        DispatchQueue.main.async {
            let maxSize = self.datasource.maxArraySize
            if self.datasource.itemsCount <= maxSize {
                callback(models, nil)
                return
            } else if self.isCancelled {
                callback(models, nil)
                return
            } else if let tableView = self.scrollView as? UITableView {
                tableView.beginUpdates()
                let indexPaths = self.innerCleanup()
                if (indexPaths.count > 0) && (!self.datasource.collapsed) { tableView.deleteRows(at: indexPaths, with: self.datasource.rowAnimation) }
                tableView.endUpdates()
                callback(models, nil)
                return
            } else if let collectionView = self.scrollView as? UICollectionView {
                collectionView.performBatchUpdates({
                    let indexPaths = self.innerCleanup()
                    if (indexPaths.count > 0 ) && (!self.datasource.collapsed) { collectionView.deleteItems(at: indexPaths) }
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
    func backHandler(models: [RVBaseModel]) -> [IndexPath] {
        let section = datasource.section
        let virtualIndex = datasource.itemsCount + datasource.offset
        var clone = datasource.cloneItems()
        var indexPaths = [IndexPath]()
        for i in 0..<models.count {
            clone.append(models[i])
            if (section >= 0) { indexPaths.append(IndexPath(row: virtualIndex + i, section: section)) }
        }
        self.datasource.items = clone
       // print("In \(self.classForCoder).backHandler, items count = \(self.datasource.itemsCount) collapsed: \(self.datasource.collapsed)")
        return indexPaths
    }
    func frontHandler(newModels: [RVBaseModel]) -> [IndexPath] {
        //print("In \(self.classForCoder).frontHandler")
        var clone = datasource.cloneItems()
 
        var indexPaths = [IndexPath]()
        let newCount = newModels.count
        if self.datasource.offset > 0 {
            print("In \(self.classForCoder).insertFront offset is \(self.datasource.offset) and newCount = \(newCount)")
            if newCount <= datasource.offset {
                for i in 0..<newCount { clone.insert(newModels[i], at: 0) }
                self.datasource.items = clone
                self.datasource.offset = self.datasource.offset - newCount
                return indexPaths
            } else {
                for i in 0..<self.datasource.offset { clone.insert(newModels[i], at: 0) }
                self.datasource.offset = 0
                let section = self.datasource.section
                var rowIndex: Int = (self.subscriptionOperation != .response) ? self.datasource.virtualCount : 0
                for i in (self.datasource.offset)..<newCount {
                    clone.insert(newModels[i], at: 0)
                    if (section >= 0 ) { indexPaths.append(IndexPath(item: rowIndex, section: section)) }
                    rowIndex = rowIndex + 1
                }
                self.datasource.items = clone
                return indexPaths
            }
        } else {
            var rowIndex: Int = (self.subscriptionOperation != .response) ? self.datasource.virtualCount : 0
            let section = self.datasource.section
            for i in 0..<newCount {
                clone.insert(newModels[i], at: 0)
                if (section >= 0 ) {  indexPaths.append(IndexPath(item: rowIndex, section: section)) }
                rowIndex = rowIndex + 1
            }
            self.datasource.offset = 0
            self.datasource.items = clone
            return indexPaths
        }
    }
    
    
    
    func insert(models: [RVBaseModel], callback: @escaping RVCallback) {
        //print("In \(self.classForCoder).insert")
        DispatchQueue.main.async {
            if self.isCancelled {
                callback(models, nil)
                return
            }
            var sizedModels = [RVBaseModel]()
            if self.datasource.datasourceType == .filter {
                let room = self.datasource.maxArraySize - self.datasource.itemsCount
                if (models.count <= room) { sizedModels = models }
                else {
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
                        callback(sizedModels, nil)
                        return
                    }
                    tableView.beginUpdates()
                    if let indexPaths = tableView.indexPathsForVisibleRows { if let indexPath = indexPaths.last { originalRow = indexPath.row } }
                    // print("In \(self.classForCoder).insert, subscriptionOperation = \(self.subscriptionOperation)")
                    if (self.subscriptionOperation == .response) || self.referenceMatch {
                        let point = CGPoint(x: 10, y: (tableView.bounds.origin.y + tableView.bounds.height))
                        if let indexPath = tableView.indexPathForRow(at: point) { originalRow = indexPath.row }
                        var indexPaths = [IndexPath]()
                        //print("In \(self.classForCoder).insert, tableView reference match")
                        if self.front { indexPaths = self.frontHandler(newModels: sizedModels) }
                        else { indexPaths = self.backHandler(models: sizedModels) }
                        //print("In \(self.classForCoder).insert numberOfIndexPaths = \(indexPaths.count)")
                        if  (!self.datasource.collapsed)  {
                            tableView.insertRows(at: indexPaths, with: UITableViewRowAnimation.middle)
                            indexPathsCount = indexPaths.count
                        }
                    } else {
                        print("In \(self.classForCoder).insert, tableView no reference match reference is \(self.reference?.description ?? " no reference")")
                        /*
                        if self.subscriptionOperation {
                            if let subscription = self.datasource.subscription {
                                subscription.reference = self.front ? self.datasource.frontItem : self.datasource.backItem
                            }
                        }
 */
                    }
                    if self.subscriptionOperation == .none {
                        
                      //  if (self.front && self.datasource.offset == 0) || !self.front {
                            if let subscription = self.datasource.subscription {
                                if !subscription.active {
                                    self.datasource.subscribe(scrollView: self.scrollView, front: self.front)
                                }
                            }
                     //   }
                    }
                    tableView.endUpdates()
                    tableView.isScrollEnabled = originalScrollEnabled
                    if self.isCancelled {
                        callback(sizedModels, nil)
                        return
                    }
                    if (!self.datasource.collapsed) && (self.front) && (originalRow >= 0) && (indexPathsCount > 0) && (self.subscriptionOperation != .response) {
                        tableView.beginUpdates()
                        let section = self.datasource.section
                        if section >= 0 {
                            var indexPath = IndexPath(row: (originalRow + indexPathsCount), section: section)
                            if indexPath.row >= self.datasource.virtualCount { indexPath.row = self.datasource.virtualCount - 1 }
                            tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: false)
                            if let indexPaths = tableView.indexPathsForVisibleRows {
                                if indexPaths.count < 9 {
                                    tableView.reloadRows(at: indexPaths, with: UITableViewRowAnimation.bottom)
                                }
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
                                let indexPath = IndexPath(row: 0, section: section)
                                tableView.scrollToRow(at: indexPath, at: .top, animated: false)
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
                            var indexPaths = [IndexPath]()
                            if self.front { indexPaths = self.frontHandler(newModels: sizedModels) }
                            else { indexPaths = self.backHandler(models: sizedModels) }
                            if  (!self.datasource.collapsed)  { collectionView.insertItems(at: indexPaths) }
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
    func finishUp(items: [RVBaseModel], error: RVError?) {
        DispatchQueue.main.async {
            //print("In \(self.classForCoder).finishUp")
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
