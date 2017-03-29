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
    var offset: Int = 0
    var datasourceType: DatasourceType = .unknown
    var manager: RVDSManager4
    var model: RVBaseModel { return RVBaseModel() }

    fileprivate let backBuffer = 20
    fileprivate let frontBuffer = 20
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
                comparison = (sortTerm.order == .descending) ?  RVComparison.gte : RVComparison.lte
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
        DispatchQueue.main.async {
            if self.frontOperationActive { return }
        }
    }
    func inBack(scrollView: UIScrollView?) {
        DispatchQueue.main.async {
            if self.backOperationActive {
               // print("In \(self.classForCoder).inBack, backOperationActive")
                return
            }
            let operation = RVBackLoadOperation(datasource: self, scrollView: scrollView, callback: { (models, error) in
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
            print("In \(self.classForCoder).item calling inBack: index = \(index), count: \(items.count), offset: \(self.offset), backBuffer: \(self.backBuffer)")
            inFront(scrollView: scrollView)
            return nil
        } else if physicalIndex < items.count {
            if (physicalIndex + self.backBuffer) > items.count {
                print("In \(self.classForCoder).item calling inBack:  index = \(index), count: \(items.count), offset: \(self.offset), backBuffer: \(self.backBuffer)")
                inBack(scrollView: scrollView)
            }
            if physicalIndex < self.frontBuffer {
                print("In \(self.classForCoder).item calling inFront: index = \(index), count: \(items.count), offset: \(self.offset), backBuffer: \(self.backBuffer)")
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
    func backLoad(datasource: RVBaseDatasource4, scrollView: UIScrollView?, callback: @escaping RVCallback) {
        if backOperationActive {
            callback([RVBaseModel](), nil)
            return
        } else {
            queue.addOperation(RVBackLoadOperation(datasource: datasource , scrollView: scrollView, callback: callback) )
        }
    }
    func frontLoad(scrollView: UIScrollView?, callback: RVCallback) {
        
    }
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
class RVFrontLoadOperation: RVBackLoadOperation {

    
}
class RVExpandCollapseOperation: RVBackLoadOperation {
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
class RVBackLoadOperation: RVAsyncOperation {
    typealias RVCallback = ([RVBaseModel], RVError?) -> Void
    let itemsPlug = [RVBaseModel]()
    var datasource: RVBaseDatasource4
    weak var scrollView: UIScrollView?
    var callback: RVCallback
    var reference: RVBaseModel? = nil
    var front: Bool = false
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
    init(title: String = "RVBackLoadOperation", datasource: RVBaseDatasource4, scrollView: UIScrollView?, callback: @escaping RVCallback) {
        self.datasource     = datasource
        self.scrollView     = scrollView
        self.callback       = callback
        super.init(title: title)
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
            self.reference = datasource.backItem
            let (query, error) = datasource.backQuery(backItem: self.reference)
            if let error = error {
                error.append(message: "In \(self.instanceType). got error generating query")
            }
            if var query = query {
                 print("In \(self.classForCoder).InnerMain, haveQuery")
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
                print("In \(self.classForCoder).InnerMain, about to do retrieve")
                query = query.duplicate()
                
                let query = datasource.updateSortTerm(query: query, front: false, candidate: self.reference)
                datasource.retrieve(query: query, callback: { (models, error) in
                    print("In \(self.classForCoder).InnerMain, datasource.retrieve callback")
                    if self.isCancelled {
                        self.finishUp(items: models, error: error)
                        return
                    } else if let error = error {
                        error.append(message: "In \(self.instanceType).main, got error doing retrieve")
                        self.finishUp(items: models, error: error)
                        return
                    } else if models.count > 0 {
                        self.insert(models: models, callback: { (models, error) in
                            if let error = error {
                                error.append(message: "In \(self.instanceType).main, got error doing insertAtBack")
                                self.finishUp(items: models, error: error)
                                return
                            } else {
                                self.cleanupBack(models: models, callback: { (models, error) in
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
        print("In \(self.classForCoder).deinit")
    }
    func innerCleanupBack() -> [IndexPath] {
        let maxSize = self.datasource.maxArraySize < 100 ? 100 : self.datasource.maxArraySize
        var indexPaths = [IndexPath]()
        if self.datasource.items.count <= maxSize {
            return indexPaths
        } else {
            let section = self.datasource.section
            var clone = self.datasource.cloneItems()
            let offset = self.datasource.offset
            let arrayCount = clone.count
            for i in maxSize..<arrayCount {
                clone.removeLast()
                indexPaths.append(IndexPath(item: (offset + i), section: section))
            }
            self.datasource.items = clone
            return indexPaths
        }
    }
    func cleanupBack(models: [RVBaseModel], callback: @escaping([RVBaseModel], RVError?)-> Void) {
        DispatchQueue.main.async {
            let maxSize = self.datasource.maxArraySize < 100 ? 100 : self.datasource.maxArraySize
            if self.datasource.items.count <= maxSize {
                callback(models, nil)
                return
            } else if self.isCancelled {
                callback(models, nil)
                return
            } else if let tableView = self.scrollView as? UITableView {
                tableView.beginUpdates()
                let indexPaths = self.innerCleanupBack()
                if (indexPaths.count > 0) && (!self.datasource.collapsed) { tableView.deleteRows(at: indexPaths, with: self.datasource.rowAnimation) }
                tableView.endUpdates()
                callback(models, nil)
                return
            } else if let collectionView = self.scrollView as? UICollectionView {
                collectionView.performBatchUpdates({
                    let indexPaths = self.innerCleanupBack()
                    if (indexPaths.count > 0 ) && (!self.datasource.collapsed) { collectionView.deleteItems(at: indexPaths) }
                }, completion: { (success) in
                    callback(models, nil)
                    return
                })
            } else if self.scrollView == nil {
                let _ = self.innerCleanupBack()
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
        print("In \(self.classForCoder).insertAtBack")
        DispatchQueue.main.async {
            if self.isCancelled {
                self.finishUp(items: models, error: nil)
                return
            }
            if let tableView = self.scrollView as? UITableView {
                tableView.beginUpdates()

                if self.referenceMatch {
                    var indexPaths = [IndexPath]()
                    print("In \(self.classForCoder).insertAtBack, tableView reference match")
                    if self.front { indexPaths = self.frontHandler(models: models) }
                    else { indexPaths = self.backHandler(models: models) }
                    if  (!self.datasource.collapsed)  { tableView.insertRows(at: indexPaths, with: self.datasource.rowAnimation) }
                } else {
                    print("In \(self.classForCoder).insertAtBack, tableView no reference match")
                }
                tableView.endUpdates()
                self.finishUp(items: models, error: nil)
                return
            } else if let collectionView = self.scrollView as? UICollectionView {
                collectionView.performBatchUpdates({
                    if !self.isCancelled {
                        if self.referenceMatch {
                            var indexPaths = [IndexPath]()
                            if self.front { indexPaths = self.frontHandler(models: models) }
                            else { indexPaths = self.backHandler(models: models) }
                            if  (!self.datasource.collapsed)  { collectionView.insertItems(at: indexPaths) }
                        }
                    }
                }, completion: { (success) in
                    self.finishUp(items: models, error: nil)
                })
                return
            } else if self.scrollView == nil {
                if self.referenceMatch {
                    if self.front { let _ = self.frontHandler(models: models) }
                    else { let _ = self.backHandler(models: models) }
                }
                self.finishUp(items: models, error: nil)
                return
            } else {
                let error = RVError(message: "In \(self.instanceType).insertABack, erroroneous scrollView \(self.scrollView)")
                self.finishUp(items: models, error: error)
                return
            }
        }
    }
    func finishUp(items: [RVBaseModel], error: RVError?) {
        DispatchQueue.main.async {
            print("In \(self.classForCoder).finishUp")
            self.callback(items, error)
            if self.front { self.datasource.frontOperationActive = false }
            else {
               // print("In \(self.classForCoder).finishUp, setting backOperation to false")
                self.datasource.backOperationActive = false
            }
            self.completeOperation()
        }
    }
}
