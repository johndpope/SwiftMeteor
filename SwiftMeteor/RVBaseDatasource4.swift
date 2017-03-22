//
//  RVBaseDatasource4.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/21/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit

class RVBaseDatasource4: RVBaseDataSource {
    typealias RVCallback = ([RVBaseModel], RVError?) -> Void
    typealias DSOperation = () -> Void
    fileprivate let queue = RVOperationQueue()
    var rowAnimation: UITableViewRowAnimation = UITableViewRowAnimation.automatic
    var items = [RVBaseModel]()
    var section: Int { get { return 0 }}
    var backOperationActive: Bool = false
    var frontOperationActive: Bool = false
    var maxArraySize: Int = 300
    // var collapsed: Bool = false
    // var offset: Int = 0
    // var datasourceType: RVBaseDataSource.DatasourceType
    func retrieve(query: RVQuery, callback: @escaping RVCallback) {
        print("In RVBaseDatasource4.retrieve, need to override")
        RVBaseModel.bulkQuery(query: query, callback: callback as! ([RVBaseModel]?, RVError?) -> Void)
    }
}

extension RVBaseDatasource4 {
    var numberOfItems: Int { get { return virtualCount } }
    override var virtualCount: Int {
        get {
            if self.collapsed { return 0 }
            return self.items.count + self.offset
        }
    }
    func item(index: Int) -> RVBaseModel? {
        if index < 0 {
            print("In \(self.classForCoder).item, got negative index \(index)")
            return nil
        }
        let physicalIndex = index - offset
        if physicalIndex < 0 {
            print("In \(self.classForCoder).item got physical index less than 0 \(physicalIndex). Offset is \(offset)")
            return nil
        } else if physicalIndex < items.count {
            return items[physicalIndex]
        } else {
            print("In \(self.classForCoder).item physicalIndex of \(physicalIndex) exceeds array size \(items.count). Offset is \(self.offset)")
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
        return (RVQuery(), nil)
    }
    func frontQuery() -> (RVQuery?, RVError?) {
        return (RVQuery(), nil)
    }
    func backLoad(datasource: RVBaseDatasource4, scrollView: UIScrollView?, filterTerms: RVFilterTerms?, callback: @escaping RVCallback) {
        if backOperationActive {
            callback([RVBaseModel](), nil)
            return
        } else {
            queue.addOperation(RVBackLoadOperation(datasource: datasource , scrollView: scrollView, filterTerms: filterTerms, callback: callback) )
        }
    }
    func frontLoad(scrollView: UIScrollView?, callback: RVCallback) {
        
    }
    func restart(scrollView: UIScrollView?, callback: RVCallback) {
        
    }
}
class RVFrontLoadOperation: RVBackLoadOperation {

    
}
class RVExpandCollapseOperation: RVAsyncOperation {
    typealias RVCallback = ([RVBaseModel], RVError?) -> Void
    var datasource: RVBaseDatasource4
    weak var scrollView: UIScrollView?
    var callback: RVCallback
    var collapse: Bool
    var empty: Bool
    var emptyModels = [RVBaseModel]()
    init(datasource: RVBaseDatasource4, scrollView: UIScrollView?, collapse: Bool, empty: Bool, callback: @escaping RVCallback) {
        self.datasource     = datasource
        self.scrollView     = scrollView
        self.callback       = callback
        self.collapse       = collapse
        self.empty          = empty
        super.init(title: "RVExpandCollapseOperation")
    }
    func handleCollapse() -> [IndexPath] {
        var indexPaths = [IndexPath]()
        let section = self.datasource.section
        let lastItem = self.datasource.offset + self.datasource.items.count
        if lastItem > 0 { for row in 0..<lastItem { indexPaths.append(IndexPath(row: row, section: section)) } }
        if self.empty { self.datasource.items = [RVBaseModel]() }
        self.datasource.collapsed = true
        return indexPaths
    }
    override func main() {
        if self.isCancelled {
            self.finishUp(models: self.emptyModels, error: nil)
            return
        } else if collapse {
            if self.datasource.collapsed {
                if self.empty { self.datasource.items = [RVBaseModel]() }
                self.finishUp(models: self.emptyModels, error: nil)
                return
            } else {
                if let tableView = self.scrollView as? UITableView {
                    tableView.beginUpdates()
                    if !self.isCancelled {
                        let indexPaths = self.handleCollapse()
                        if indexPaths.count > 0 { tableView.deleteRows(at: indexPaths, with: self.datasource.rowAnimation) }
                        tableView.endUpdates()
                        self.finishUp(models: self.emptyModels, error: nil)
                    }
                    return
                } else if let collectionView = self.scrollView as? UICollectionView {
                    collectionView.performBatchUpdates({
                        if self.isCancelled { return }
                        let indexPaths = self.handleCollapse()
                        if indexPaths.count > 0 { collectionView.deleteItems(at: indexPaths) }
                    }, completion: { (success) in
                        self.finishUp(models: self.emptyModels, error: nil)
                    })
                    return
                } else if self.scrollView == nil {
                    self.datasource.collapsed = true
                    if self.empty { self.datasource.items = [RVBaseModel]() }
                } else {
                    let error = RVError(message: "In \(self.classForCoder).main, erroneous scrollVIew \(self.scrollView)")
                    self.finishUp(models: self.emptyModels, error: error)
                    return
                }
            }
        } else {
            if self.datasource.collapsed {
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
                    let _ = handleExpand()
                    self.finishUp(models: self.datasource.items, error: nil)
                    return
                } else {
                    let error = RVError(message: "In \(self.classForCoder).main, invalid scrollView \(self.scrollView)")
                    self.finishUp(models: self.datasource.items, error: error)
                    return
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
    var filterTerms: RVFilterTerms?
    var reference: RVBaseModel? = nil
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
    init(datasource: RVBaseDatasource4, scrollView: UIScrollView?, filterTerms: RVFilterTerms?, callback: @escaping RVCallback) {
        self.datasource     = datasource
        self.scrollView     = scrollView
        self.callback       = callback
        self.filterTerms    = filterTerms
        super.init(title: "RVBackLoadOperation")
    }
    
    override func main() {
        if self.isCancelled {
            finishUp(front: false, items: itemsPlug, error: nil)
            return
        } else {
            self.reference = datasource.backItem
            let (query, error) = datasource.backQuery(backItem: self.reference)
            if let query = query {
                datasource.retrieve(query: query, callback: { (models, error) in
                    if self.isCancelled {
                        self.finishUp(front: false, items: models, error: error)
                        return
                    } else if let error = error {
                        error.append(message: "In \(self.instanceType).main, got error doing retrieve")
                        self.finishUp(front: false, items: models, error: error)
                        return
                    } else if models.count > 0 {
                        self.insertAtBack(models: models, callback: { (models, error) in
                            if let error = error {
                                error.append(message: "In \(self.instanceType).main, got error doing insertAtBack")
                                self.finishUp(front: false, items: models, error: error)
                                return
                            } else {
                                self.cleanupBack(models: models, callback: { (models, error) in
                                    self.finishUp(front: false, items: models, error: nil)
                                })
                                return
                            }
                        })
                        return
                    } else {
                        self.finishUp(front: false, items: models, error: error)
                        return
                    }
                })
            } else {
                self.finishUp(front: false, items: itemsPlug , error: error)
            }
        }
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
        return indexPaths
    }
    func insertAtBack(models: [RVBaseModel], callback: @escaping RVCallback) {
        DispatchQueue.main.async {
            if self.isCancelled {
                callback(models, nil)
                return
            }
            if let tableView = self.scrollView as? UITableView {
                tableView.beginUpdates()
                if self.referenceMatch {
                   let indexPaths = self.backHandler(models: models)
                    if  (!self.datasource.collapsed)  { tableView.insertRows(at: indexPaths, with: self.datasource.rowAnimation) }
                }
                tableView.endUpdates()
                callback(models, nil)
                return
            } else if let collectionView = self.scrollView as? UICollectionView {
                collectionView.performBatchUpdates({
                    if !self.isCancelled {
                        if self.referenceMatch {
                            let indexPaths = self.backHandler(models: models)
                            if  (!self.datasource.collapsed)  { collectionView.insertItems(at: indexPaths) }
                        }
                    }
                }, completion: { (success) in
                    callback(models, nil)
                })
                return
            } else if self.scrollView == nil {
                if self.referenceMatch { let _ = self.backHandler(models: models) }
                callback(models, nil)
                return
            } else {
                let error = RVError(message: "In \(self.instanceType).insertABack, erroroneous scrollView \(self.scrollView)")
                callback(models, error)
                return
            }
        }
    }
    func finishUp(front: Bool, items: [RVBaseModel], error: RVError?) {
        DispatchQueue.main.async {
            self.callback(items, error)
            if front { self.datasource.frontOperationActive = false }
            else { self.datasource.backOperationActive = false }
            self.completeOperation()
        }
    }
}
