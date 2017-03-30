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
class RVBaseDatasource4: NSObject {
    enum DatasourceType: String {
        case top        = "Top"
        case main       = "Main"
        case filter     = "Filter"
        case unknown    = "Unknown"
    }
    var instanceType: String { get { return String(describing: type(of: self)) } }
    let identifier = NSDate().timeIntervalSince1970
    var baseQuery: RVQuery? = nil
    fileprivate let queue = RVOperationQueue()
    var rowAnimation: UITableViewRowAnimation = UITableViewRowAnimation.automatic
    var items = [RVBaseModel]()
    var section: Int { get { return manager.sectionIndex(datasource: self) }}
    var backOperationActive: Bool = false
    var frontOperationActive: Bool = false
    var maxArraySize: Int = 300
    var collapsed: Bool = false
    fileprivate var offset: Int = 0 {
        willSet {
            if newValue < 0 { print("In \(self.classForCoder) ERROR. attemtp to set Offset to a negative number \(newValue)") }
        }
    }
    var datasourceType: DatasourceType = .unknown
    var manager: RVDSManager4
    var model: RVBaseModel { return RVBaseModel() }
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
    func retrieve(query: RVQuery, callback: @escaping RVCallback) {
        print("In RVBaseDatasource4.retrieve, need to override")
        RVBaseModel.bulkQuery(query: query, callback: callback as! ([RVBaseModel]?, RVError?) -> Void)
    }
    init(manager: RVDSManager4, datasourceType: DatasourceType, maxSize: Int) {
        self.manager = manager
        self.datasourceType = datasourceType
        self.maxArraySize = ((maxSize < 500) && (maxSize > 50)) ? maxSize : 500
        super.init()
    }
    /*
    func baseQuery() -> (RVQuery, RVError?) {
        let (query, error) = model.basicQuery
        if let error = error { error.append(message: "In \(self.instanceType).baseQuery(), got error") }
        else {
            for term in self.dynamicAndTerms { query.addAnd(term: term.term, value: term.value, comparison: term.comparison) }
            for sortTerm in self.sortTerms { query.addSort(sortTerm: sortTerm) }
            for fixedTerm in self.dynamicFixedTerms { query.fixedTerm = fixedTerm}
        }
        return (query, error)
    }
 */
    func cancelAllOperations() { self.queue.cancelAllOperations()}
    func unsubscribe() {
        print("In \(self.classForCoder).unsubscribe Need to implement")
    }
}

extension RVBaseDatasource4 {
    func updateSortTerm(query: RVQuery, front: Bool = false, candidate: RVBaseModel? = nil) -> RVQuery {
        if (query.sortTerms.count == 0) || (query.sortTerms.count > 1) {
            print("In \(self.classForCoder).updateSortTerms, erroneous number of sort Tersm: \(query.sortTerms)")
        }
        if let candidate = candidate {
            print("In \(self.classForCoder).updateSortTerm, candidate \(candidate.title), \(candidate.createdAt)")
        } else {
            print("In \(self.classForCoder).updateSortTerm, no candidate")
        }
        if let sortTerm = query.sortTerms.first {
            let firstString: AnyObject = "" as AnyObject
            let lastString: AnyObject = "ZZZZZZZZZZZZZZZZZ" as AnyObject
            var comparison = (sortTerm.order == .ascending) ?  RVComparison.gte : RVComparison.lte

            var sortString: AnyObject = lastString
            if sortTerm.order == .ascending { sortString = firstString}
            if front {
                comparison = (sortTerm.order == .descending) ?  RVComparison.gt : RVComparison.lt
                sortString = (sortTerm.order == .descending) ? firstString : lastString
            }
            var sortDate: Date = Date()
            if sortTerm.order == .ascending { sortDate = query.decadeAgo }
            if front { sortDate = (sortTerm.order == .descending) ? query.decadeAgo : Date() }
            
            var sortField: RVKeys = .createdAt
            var finalValue: AnyObject = "" as AnyObject
            switch (sortTerm.field) {
            case .createdAt:
                if let candidate = candidate { if let date = candidate.createdAt { sortDate = date} }
                finalValue = sortDate as AnyObject
                sortField = .createdAt
            case .updatedAt:
                if let candidate = candidate { if let date = candidate.updatedAt { sortDate = date} }
                finalValue = sortDate as AnyObject
                sortField = .updatedAt
            case .commentLowercase, .comment:
                if let candidate = candidate { if let string = candidate.comment { sortString = string.lowercased() as AnyObject } }
                finalValue = sortString as AnyObject
                sortField = .commentLowercase
            case .handleLowercase, .handle:
                if let candidate = candidate { if let string = candidate.handleLowercase { sortString = string.lowercased() as AnyObject } }
                finalValue = sortString as AnyObject
                sortField = .handleLowercase
            case .title:
                if let candidate = candidate { if let string = candidate.title { sortString = string.lowercased() as AnyObject } }
                finalValue = sortString as AnyObject
                sortField = .title
            case .fullName:
                if let candidate = candidate { if let string = candidate.fullName { sortString = string.lowercased() as AnyObject } }
                finalValue = sortString as AnyObject
                sortField = .fullName
            default:
                print("In \(self.classForCoder).updateSortTerms, term: \(sortTerm.field.rawValue) not handled")
            }
            print("In \(self.classForCoder).updateSortTerm, finalValue is: \(finalValue), Comparison: \(comparison.rawValue), sortField: \(sortField.rawValue)")
            if let queryTerm = query.findAndTerm(term: sortTerm.field) { queryTerm.value =  finalValue}
            else { query.addAnd(term: sortField, value: finalValue, comparison: comparison) }
        }
        return query
    }
    var numberOfItems: Int { get { return virtualCount } }
    var virtualCount: Int {
        get {
            if self.collapsed { return 0 }
            return self.items.count + self.offset
        }
    }
    func inFront(scrollView: UIScrollView?) {
        print("In \(self.classForCoder).inFront. ........................................... #######")
        if self.datasourceType == .filter { return }
        DispatchQueue.main.async {
            if self.frontOperationActive { return }
            let operation = RVLoadOperation(datasource: self, scrollView: scrollView, front: true, callback: { (models, error) in
                if let error = error {
                    error.append(message: "In \(self.classForCoder).inFront, got error")
                    error.printError()
                } else {
                    print("In \(self.classForCoder).inFront, success")
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
                    print("In \(self.classForCoder).inBack, success")
                }
            })
            self.queue.addOperation(operation)
        }
    }
    func item(index: Int, scrollView: UIScrollView?) -> RVBaseModel? {
        self.lastItemIndex = index
        if index < 0 {
            print("In \(self.instanceType).item, got negative index \(index)")
            return nil
        } else if index >= self.virtualCount {
            print("In \(self.instanceType).item, index \(index) greater than virtualCount: \(self.virtualCount)")
            return nil
        }
        let physicalIndex = index - offset
        if physicalIndex < 0 {
            print("In \(self.instanceType).item got physical index less than 0 \(physicalIndex). Offset is \(offset)")
            print("In \(self.classForCoder).item calling inBack: index = \(index), count: \(items.count), offset: \(self.offset), backBuffer: \(self.backBufferSize)")
            inFront(scrollView: scrollView)
            return nil
        } else if physicalIndex < items.count {
            if (physicalIndex + self.backBufferSize) > items.count {
                print("In \(self.classForCoder).item calling inBack:  index = \(index), count: \(items.count), offset: \(self.offset), backBuffer: \(self.backBufferSize)")
                inBack(scrollView: scrollView)
            }
            if physicalIndex < self.frontBufferSize {
                print("In \(self.classForCoder).item calling inFront: index = \(index), count: \(items.count), offset: \(self.offset), backBuffer: \(self.backBufferSize)")
                inFront(scrollView: scrollView)
            }
            return items[physicalIndex]
        } else {
            print("In \(self.instanceType).item physicalIndex of \(physicalIndex) exceeds or equals array size \(items.count). Offset is \(self.offset)")
            return nil
        }
    }
    func cloneItems() -> [RVBaseModel] {
        var clone = [RVBaseModel]()
        for item in items { clone.append(item) }
        return clone
    }
    var frontItem: RVBaseModel? {
        get {
            if items.count == 0 { return nil }
            else { return items[0] }
        }
    }
    var backItem: RVBaseModel? {
        get {
            if items.count == 0 { return nil }
            else { return items[items.count - 1] }
        }
    }
    func backQuery(backItem: RVBaseModel?) -> (RVQuery?, RVError?) {
        print("In \(self.classForCoder).backQuery, needs work")
        return (self.baseQuery?.duplicate(), nil)
    }
    func frontQuery() -> (RVQuery?, RVError?) {
        return (RVQuery(), nil)
    }
    /*
    func backLoad(datasource: RVBaseDatasource4, scrollView: UIScrollView?, callback: @escaping RVCallback) {
        if backOperationActive {
            callback([RVBaseModel](), nil)
            return
        } else {
            queue.addOperation(RVLoadOperation(datasource: datasource , scrollView: scrollView, callback: callback) )
        }
    }

    func frontLoad(scrollView: UIScrollView?, callback: RVCallback) {
        
    }
    */
    func restart(scrollView: UIScrollView?, query: RVQuery, callback: @escaping RVCallback) {
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

class RVExpandCollapseOperation: RVLoadOperation {
    typealias RVCallback = ([RVBaseModel], RVError?) -> Void

    var operationType: RVExpandCollapseOperationType
    var query: RVQuery
    var emptyModels = [RVBaseModel]()
    init(datasource: RVBaseDatasource4, scrollView: UIScrollView?, operationType: RVExpandCollapseOperationType, query: RVQuery = RVQuery(), callback: @escaping RVCallback) {
        self.operationType  = operationType
        self.query = query
        super.init(title: "RVExpandCollapseOperation", datasource: datasource, scrollView: scrollView, callback: callback)
    }
    func handleCollapse() -> [IndexPath] {
        var indexPaths = [IndexPath]()
        let section = self.datasource.section
        let lastItem = self.datasource.offset + self.datasource.items.count
        if lastItem > 0 { for row in 0..<lastItem { indexPaths.append(IndexPath(row: row, section: section)) } }
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
    func getToLoad() {
        self.datasource.baseQuery = self.query
    }
    override func asyncMain() {
        var operationType = self.operationType
        if operationType == .toggle { operationType = (self.datasource.collapsed) ? .expandOnly : .collapseOnly }
        if self.isCancelled {
            self.finishUp(models: self.emptyModels, error: nil)
            return
        } else if (operationType != .expandOnly) {
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
                                if indexPaths.count > 0 { tableView.deleteRows(at: indexPaths, with: self.datasource.rowAnimation) }
                                tableView.endUpdates()
                            }
                            if (operationType == .collapseZeroExpandAndLoad) {
                                print("In \(self.classForCoder).main, about to do InnerMain, collapsed = \(self.datasource.collapsed)")
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
                            let error = RVError(message: "In \(self.classForCoder).main, erroneous scrollVIew \(self.scrollView)")
                            self.finishUp(models: self.emptyModels, error: error)
                            return
                        }
                    }
                }
            }
        } else {
            print("In \(self.classForCoder).main expand collapsed: \(datasource.collapsed)")
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
                        let error = RVError(message: "In \(self.classForCoder).main, invalid scrollView \(self.scrollView)")
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
        let lastItem = self.datasource.offset + self.datasource.items.count
        if lastItem > 0 { for row in 0..<lastItem { indexPaths.append(IndexPath(row: row, section: section)) } }
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
class RVLoadOperation: RVAsyncOperation {
    typealias RVCallback = ([RVBaseModel], RVError?) -> Void
    let itemsPlug = [RVBaseModel]()
    var datasource: RVBaseDatasource4
    weak var scrollView: UIScrollView?
    var callback: RVCallback
    var reference: RVBaseModel? = nil
    var front: Bool
    var referenceMatch: Bool {
        get {
            let current = self.datasource.backItem
            if (reference == nil) && (current == nil) { return true }
            if let reference = self.reference {
                if let current = current {
                    if reference == current { return true }
                    else { return false }
                } else { return false}
            } else { return false }
        }
    }
    init(title: String = "RVLoadOperation", datasource: RVBaseDatasource4, scrollView: UIScrollView?, front: Bool = false, callback: @escaping RVCallback) {
        self.datasource     = datasource
        self.scrollView     = scrollView
        self.callback       = callback
        self.front          = front
        super.init(title: "RVLoadOperation with front: \(front)")
    }
    override func asyncMain() {
        InnerMain()
    }
    func InnerMain() {
        //print("In \(self.classForCoder).InnerMain")
        
        if self.isCancelled {
            finishUp(items: itemsPlug, error: nil)
            return
        } else {
            self.reference = self.front ? datasource.frontItem : datasource.backItem
            if self.front && self.datasource.datasourceType == .filter {
                finishUp(items: itemsPlug , error: nil)
                return
            }
            let (query, error) = datasource.backQuery(backItem: self.reference)
            if let error = error {
                error.append(message: "In \(self.instanceType). got error generating query")
            }
            if var query = query {
                 print("In \(self.classForCoder).InnerMain, for front: \(self.front) haveQuery frontOperationActive: \(self.datasource.frontOperationActive), backOperationActive: \(self.datasource.backOperationActive)")
                if self.front {
                    if self.datasource.frontOperationActive {
                        self.finishUp(items: self.itemsPlug, error: nil)
                        return
                    } else {
                        self.datasource.frontOperationActive = true
                    }
                } else {
                    if self.datasource.backOperationActive {
                        self.finishUp(items: self.itemsPlug, error: nil)
                        return
                    } else {
                        self.datasource.backOperationActive = true
                    }
                }
                print("In \(self.classForCoder).InnerMain, about to do retrieve. Front: \(self.front)")
                query = query.duplicate()
                
                var query = datasource.updateSortTerm(query: query, front: self.front, candidate: self.reference)
                query = query.updateQuery4(front: self.front, reference: self.reference)
                datasource.innerRetrieve(query: query, callback: { (models, error) in
                    print("In \(self.classForCoder).InnerMain, datasource.innerRetrieve callback")
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
                                    self.finishUp(items: models, error: nil)
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
    func insertFront(newModels: [RVBaseModel])-> [IndexPath] {
        var indexPaths = [IndexPath]()
        var clone = self.datasource.cloneItems()
        let newCount = newModels.count
        if self.datasource.offset > 0 {

            if newCount <= datasource.offset {
                for i in 0..<newCount { clone.insert(newModels[i], at: 0) }
                self.datasource.items = clone
                self.datasource.offset = self.datasource.offset - newCount
                return indexPaths
            } else {
                for i in 0..<self.datasource.offset { clone.insert(newModels[i], at: 0) }
                let section = self.datasource.section
                for i in (self.datasource.offset)..<newCount {
                    clone.insert(newModels[i], at: 0)
                    indexPaths.append(IndexPath(item: 0, section: section))
                }
                self.datasource.offset = 0
                return indexPaths
            }
        } else {
            let section = self.datasource.section
            for i in 0..<newCount {
                clone.insert(newModels[i], at: 0)
                indexPaths.append(IndexPath(item: 0, section: section))
            }
            self.datasource.offset = 0
            return indexPaths
        }
    }
    func innerCleanup() -> [IndexPath] {
        if self.datasource.lastItemIndex < (self.datasource.virtualCount / 2) { return innerCleanup2(front: false) }
        else { return innerCleanup2(front: true) }
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
                    indexPaths.append(IndexPath(item: virtualMax-i, section: section))
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
            if self.datasource.items.count <= maxSize {
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
                let error = RVError(message: "In \(self.classForCoder).cleanupBack, erroreous scrollView \(self.scrollView)")
                callback(models, error)
                return
            }
        }
    }
    func backHandler(models: [RVBaseModel]) -> [IndexPath] {
        let section = datasource.section
        let virtualIndex = datasource.items.count + datasource.offset
        var clone = datasource.cloneItems()
        var indexPaths = [IndexPath]()
        for i in 0..<models.count {
            clone.append(models[i])
            indexPaths.append(IndexPath(row: virtualIndex + i, section: section))
        }
        self.datasource.items = clone
        print("In \(self.classForCoder).backHandler, items count = \(self.datasource.items.count) collapsed: \(self.datasource.collapsed)")
        return indexPaths
    }
    func frontHandler(models: [RVBaseModel]) -> [IndexPath] {
        print("In \(self.classForCoder).frontHandler")
  //      let section = datasource.section
  //      let virtualIndex = datasource.items.count + datasource.offset
  //      var clone = datasource.cloneItems()
        let indexPaths = [IndexPath]()
        /*
        for i in 0..<models.count {
            clone.append(models[i])
            indexPaths.append(IndexPath(row: virtualIndex + i, section: section))
        }
        self.datasource.items = clone
        */
        return indexPaths
    }
    func insert(models: [RVBaseModel], callback: @escaping RVCallback) {
        print("In \(self.classForCoder).insert")
        DispatchQueue.main.async {
            if self.isCancelled {
                callback(models, nil)
                return
            }
            var sizedModels = [RVBaseModel]()
            if self.datasource.datasourceType == .filter {
                let room = self.datasource.maxArraySize - self.datasource.items.count
                if (models.count <= room) { sizedModels = models }
                else {
                    for i in 0..<room { sizedModels.append(models[i]) }
                }
            } else { sizedModels = models }
            if let tableView = self.scrollView as? UITableView {
                tableView.beginUpdates()

                if self.referenceMatch {
                    var indexPaths = [IndexPath]()
                    print("In \(self.classForCoder).insert, tableView reference match")
                    if self.front { indexPaths = self.frontHandler(models: sizedModels) }
                    else { indexPaths = self.backHandler(models: sizedModels) }
                    if  (!self.datasource.collapsed)  { tableView.insertRows(at: indexPaths, with: self.datasource.rowAnimation) }
                } else {
                    print("In \(self.classForCoder).insert, tableView no reference match")
                }
                tableView.endUpdates()
                callback(sizedModels, nil)
                return
            } else if let collectionView = self.scrollView as? UICollectionView {
                collectionView.performBatchUpdates({
                    if !self.isCancelled {
                        if self.referenceMatch {
                            var indexPaths = [IndexPath]()
                            if self.front { indexPaths = self.frontHandler(models: sizedModels) }
                            else { indexPaths = self.backHandler(models: sizedModels) }
                            if  (!self.datasource.collapsed)  { collectionView.insertItems(at: indexPaths) }
                        }
                    }
                }, completion: { (success) in
                    callback(sizedModels, nil)
                })
                return
            } else if self.scrollView == nil {
                if self.referenceMatch {
                    if self.front { let _ = self.frontHandler(models: sizedModels) }
                    else { let _ = self.backHandler(models: sizedModels) }
                }
                callback(sizedModels, nil)
                return
            } else {
                let error = RVError(message: "In \(self.instanceType).insert, erroroneous scrollView \(self.scrollView)")
                callback(sizedModels, error)
                return
            }
        }
    }
    func finishUp(items: [RVBaseModel], error: RVError?) {
        DispatchQueue.main.async {
            //print("In \(self.classForCoder).finishUp")
            self.callback(items, error)
            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false , block: { (timer) in
                if self.front { self.datasource.frontOperationActive = false }
                else {
                    // print("In \(self.classForCoder).finishUp, setting backOperation to false")
                    self.datasource.backOperationActive = false
                }
            })
            self.completeOperation()
        }
    }
}
