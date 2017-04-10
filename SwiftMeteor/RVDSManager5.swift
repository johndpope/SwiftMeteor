//
//  RVDSManager5.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/9/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
class RVDSManager5<S: NSObject>: RVBaseDatasource4<RVBaseDatasource4<S>> {
    init(scrollView: UIScrollView?, maxSize: Int = 300) {
        super.init(manager: nil, datasourceType: .section, maxSize: maxSize)
        self.scrollView = scrollView
    }
    var numberOfSections: Int { return numberOfElements } // Unique to RVDSManagers
}
// RVDSManager Unique
extension RVDSManager5 {
    func sectionIndex(datasource: RVBaseDatasource4<S>) -> Int {
        for i in 0..<elements.count {
            if elements[i] == datasource { return i + offset }
        }
        return -1
    }
    func numberOfItems(section: Int) -> Int {
        if let datasource = self.datasourceInSection(section: section) {
            return datasource.numberOfElements
        } else { return 0 }
    }
    func item(indexPath: IndexPath, scrollView: UIScrollView?, updateLast: Bool = true) -> S? {
        // func element(indexPath: IndexPath) ->  T? {
        let section = indexPath.section
        if let datasource = datasourceInSection(section: section) {
            return datasource.element(indexPath: indexPath, scrollView: scrollView)
        } else {
            return nil
        }
    }
    func datasourceInSection(section: Int) -> RVBaseDatasource4<S>? {
        if (section >= 0) && (section < numberOfElements) {
            let physical = section - offset
            if physical >= 0 {
                return elements[physical]
            } else {
                // Neil retreive sections
                return nil
            }
        } else {
            print("In \(self.instanceType).datasourceInSection, invalid sectionIndex: \(section) ")
            return nil
        }
    }
    func removeAllSections(callback: @escaping RVCallback<S>) {
        let operation = RVManagerRemoveSections5<S>(manager: self, datasources: [RVBaseDatasource4<S>](), callback: callback, all: true)
        queue.addOperation(operation)
    }
    func toggle(datasource: RVBaseDatasource4<S>, callback: @escaping RVCallback<S>) {
        // print("In \(self.instanceType).toggle -------------------------------------- ")
        if self.sectionIndex(datasource: datasource) < 0 {
            let error = RVError(message: "In \(self.instanceType).toggle, datasource is not installed as a section \(datasource)")
            callback([S](), error)
            return
        } else {
            let operation = RVManagerExpandCollapseOperation5<S>( manager: self, operationType: .toggle, datasources: [datasource], callback: callback, all: false)
            queue.addOperation(operation)
        }
    }
    func appendSections(datasources: [RVBaseDatasource4<S>], sectionTypesToRemove: [RVBaseDatasource4<S>.DatasourceType] = Array<RVBaseDatasource4<S>.DatasourceType>(), callback: @escaping RVCallback<S>) {
        let operation = RVManagerAppendSections5( manager: self, datasources: datasources, sectionTypesToRemove: sectionTypesToRemove, callback: callback)
        queue.addOperation(operation)
    }
    func restart(datasource: RVBaseDatasource4<S>, query: RVQuery, callback: @escaping RVCallback<S>) {
        datasource.restart(scrollView: self.scrollView, query: query, callback: callback)
    }
    func scrolling(indexPath: IndexPath, scrollView: UIScrollView) {
        let section = indexPath.section
        if let datasource = self.datasourceInSection(section: section) {
            datasource.scroll(indexPath: indexPath, scrollView: scrollView)
        } else {
            // Neil retrieve more
        }
    }
    func remove(at: Int) {
        if at < 0 { return }
        if at >= self.elementsCount {
            print("IN \(self.classForCoder).remove at \(at), attempted to remove at an index greater than or equal to elementsCount \(self.elementsCount)")
            return
        } else {
            let physical = at - offset
            if physical >= 0 {
                if self.elements.count > 0 {
                    self.elements.remove(at: physical)
                } else {
                    print("In \(self.classForCoder).remove, attempting to remove element at \(physical) when count is zero")
                }
            } else {
                if offset <= 0 {
                    print("In \(self.classForCoder).remove, offset LTE zero when attempting to decrement with index = \(at)")
                } else {
                    offset = offset - 1
                }
            }
        }
    }
    func remove(indexes: [Int]) {
        if indexes.count == 0 { return }
        var sorted = indexes.sorted()
        sorted.reverse()
        for index in sorted { remove(at: index) }
    }
    func zeroElements() {
        self.elements = [RVBaseDatasource4<S>]()
        self.offset = 0
    }
}
class RVManagerExpandCollapseOperation5<T: NSObject> : RVAsyncOperation<T> {
    enum OperationType {
        case expand
        case collapse
        case toggle
        
    }
    weak var manager: RVDSManager5<T>? = nil
    let emptyResponse = [T]()
    var operationType: OperationType
    var datasources: [RVBaseDatasource4<T>]
    var all: Bool = false
    var count: Int
    init(title: String = "RVManagerExpandCollapseOperation", manager: RVDSManager5<T>, operationType: OperationType, datasources: [RVBaseDatasource4<T>], callback: @escaping RVCallback<T>, all: Bool = false) {
        self.manager = manager
        self.datasources = datasources
        self.count = datasources.count
        self.operationType = operationType
        self.all = all
        let title = "\(title) \(operationType)"
        super.init(title: title, callback: callback)
    }
    override func asyncMain() {
        if (self.manager != nil) && ( (self.datasources.count > 0) || self.all ) {
            if self.isCancelled {
                self.completeOperation()
                return
            } else { actualOperation() }
        } else {
            self.completeOperation(models: self.emptyResponse, error: nil)
            return
        }
    }
    func actualOperation() {
        if self.isCancelled {
            self.completeOperation(models: self.emptyResponse, error: nil)
            return
        }
        if let manager = self.manager {
            let datasources = self.all ? manager.elements : self.datasources
            switch(self.operationType) {
            case .expand:
                for datasource in datasources {
                    let scrollView = (manager.sectionIndex(datasource: datasource) < 0) ? nil : manager.scrollView
                    datasource.expand(scrollView: scrollView, callback: { (models, error) in
                        self.count = self.count - 1
                        if let error = error {
                            error.append(message: "In \(self.instanceType).actualOperation expand, got error")
                            self.completeOperation(models: self.emptyResponse, error: error)
                        } else if self.count <= 0 {
                            self.completeOperation(models: self.emptyResponse, error: nil)
                        }
                    })
                }
                return
            case .collapse:
                for datasource in datasources {
                    let scrollView = (manager.sectionIndex(datasource: datasource) < 0) ? nil : manager.scrollView
                    datasource.collapse(scrollView: scrollView, callback: { (models, error) in
                        self.count = self.count - 1
                        if let error = error {
                            error.append(message: "In \(self.instanceType).actualOperation collapse, got error")
                            self.completeOperation(models: self.emptyResponse, error: error)
                        } else if self.count <= 0 {
                            self.completeOperation(models: self.emptyResponse, error: nil)
                        }
                    })
                }
                return
            case .toggle:
                // print("In \(self.instanceType).actualOperation, toggle number of datasources \(datasources.count)")
                self.count = datasources.count
                for datasource in datasources {
                    let scrollView = (manager.sectionIndex(datasource: datasource) < 0) ? nil : manager.scrollView
                    datasource.toggle(scrollView: scrollView, callback: { (models, error) in
                        //print("In \(self.instanceType).actualOperation, toggle count \(self.count)  $$$$$$$$$$$$$$$$$")
                        self.count = self.count - 1
                        if let error = error {
                            error.append(message: "In \(self.instanceType).actualOperation toggle, got error")
                            self.completeOperation(models: self.emptyResponse, error: error)
                        } else if self.count <= 0 {
                            self.completeOperation(models: self.emptyResponse, error: nil)
                        }
                    })
                }
                return
            }
        } else {
            let error = RVError(message: "In \(self.instanceType).actualOperation, no manager")
            self.completeOperation(models: self.emptyResponse, error: error)
            return
        }
        
    }
    
}
class RVManagerAppendSections5<T: NSObject> : RVManagerRemoveSections5<T> {
    var sectionTypesToRemove: [RVBaseDatasource4<T>.DatasourceType]
    var sectionsToBeRemoved: [RVBaseDatasource4<T>] = [RVBaseDatasource4<T>]()
    init(title: String = "Add Sections", manager: RVDSManager5<T>, datasources: [RVBaseDatasource4<T>], sectionTypesToRemove: [RVBaseDatasource4<T>.DatasourceType] = Array<RVBaseDatasource4<T>.DatasourceType>(), callback: @escaping RVCallback<T>) {
        self.sectionTypesToRemove = sectionTypesToRemove
        super.init(title: "Add Sections", manager: manager, datasources: datasources, callback: callback)
    }
    override func asyncMain() {
        if self.isCancelled {
            complete(error: nil)
            return
        }
        if let manager = self.manager {
            if let tableView = manager.scrollView  as? UITableView {
                DispatchQueue.main.async {
                    if !self.isCancelled {
                        // print("In \(self.classForCoder).main, have TableView, notCancelled")
                        // print("In \(self.classForCoder).asynMan, datasources to remove \(self.sectionTypesToRemove)")
                        if self.sectionTypesToRemove.count > 0 {
                            for section in manager.elements {
                                for type in self.sectionTypesToRemove {
                                    if section.datasourceType == type {
                                        section.unsubscribe { section.cancelAllOperations() }
                                        self.sectionsToBeRemoved.append(section)
                                    }
                                }
                            }
                        }
                        tableView.beginUpdates()
                        let offset = manager.offset
                        var indexes = [Int]()
                        for datasource in self.datasources {
                            indexes.append(manager.elements.count + offset)
                            manager.elements.append(datasource)
                        }
                        //print("In \(self.classForCoder).main number of sections = \(manager.elements.count)")
                        tableView.insertSections(IndexSet(indexes), with: manager.rowAnimation)
                        tableView.endUpdates()
                        self.ignoreCancel = true
                    }
                    self.complete(error: nil)
                    /*
                     self.callback(self.emptyResponse, nil)
                     self.completeOperation()
                     */
                }
                return
            } else if let collectionView = manager.scrollView as? UICollectionView {
                DispatchQueue.main.async {
                    collectionView.performBatchUpdates({
                        if !self.isCancelled {
                            if self.sectionTypesToRemove.count > 0 {
                                for section in manager.elements {
                                    for type in self.sectionTypesToRemove {
                                        if section.datasourceType == type {
                                            section.unsubscribe { section.cancelAllOperations() }
                                            self.sectionsToBeRemoved.append(section)
                                        }
                                    }
                                }
                            }
                            var indexes = [Int]()
                            let offset = manager.offset
                            for datasource in self.datasources {
                                indexes.append(manager.elements.count + offset)
                                manager.elements.append(datasource)
                            }
                            collectionView.insertSections(IndexSet(indexes))
                            self.ignoreCancel = true
                        }
                    }, completion: { (success) in
                        self.complete(error: nil)
                    })
                }
                return
            } else if manager.scrollView == nil {
                if self.sectionTypesToRemove.count > 0 {
                    for section in manager.elements {
                        for type in self.sectionTypesToRemove {
                            if section.datasourceType == type {
                                section.unsubscribe { section.cancelAllOperations() }
                                self.sectionsToBeRemoved.append(section)
                            }
                        }
                    }
                }
                for datasource in self.datasources { manager.elements.append(datasource) }
                DispatchQueue.main.async {
                    self.complete(error: nil)
                }
            } else {
                let error = RVError(message: "In \(self.classForCoder).main, erroneous ScrollView: \(manager.scrollView?.description  ?? " no ScrollView")!")
                DispatchQueue.main.async {
                    self.complete(error: error )
                }
            }
        } else {
            let error = RVError(message: "In \(self.classForCoder).main, no manager")
            DispatchQueue.main.async {
                self.complete(error: error )
            }
        }
    }
    func complete(error: RVError?) {
        DispatchQueue.main.async {
            if let error = error {
                self.datasources = [RVBaseDatasource4<T>]()
                self.completeOperation(models: self.emptyResponse, error: error)
            } else if self.sectionsToBeRemoved.count > 0 {
                self.datasources = self.sectionsToBeRemoved
                self.innerAsyncMain()
            } else {
                self.datasources = [RVBaseDatasource4<T>]()
                self.completeOperation(models: self.emptyResponse, error: error)
            }
        }
    }
    
}
class RVManagerRemoveSections5<T: NSObject>: RVAsyncOperation<T> {
    weak var manager: RVDSManager5<T>? = nil
    var datasources: [RVBaseDatasource4<T>]
    var all: Bool = false
    var ignoreCancel: Bool = false
    let emptyResponse = [T]()
    init(title: String = "Remove Sections", manager: RVDSManager5<T>, datasources: [RVBaseDatasource4<T>], callback: @escaping RVCallback<T>, all: Bool = false) {
        self.datasources = datasources
        self.all = all
        self.manager = manager
        super.init(title: title, callback: callback)
    }
    override func asyncMain() {
        innerAsyncMain()
    }
    func innerAsyncMain() {
        if ((datasources.count == 0) && (!self.all)) || (self.isCancelled && !self.ignoreCancel) {
            self.completeIt(error: nil)
            return
        } else if let manager = self.manager {
            //print("In \(self.classForCoder).innerAsyncMain, past manager")
            var indexes = [Int]()
            let datasources = self.all ? manager.elements : self.datasources
            DispatchQueue.main.async {
                for datasource in datasources { datasource.unsubscribe { datasource.cancelAllOperations() } }
                DispatchQueue.main.async {
                    if let tableView = manager.scrollView as? UITableView {
                        DispatchQueue.main.async {
                            if (!(self.isCancelled  && !self.ignoreCancel)){
                                //print("In \(self.classForCoder).innerAsyncMain, about to remove ")
                                tableView.beginUpdates()
                                if self.all {
                                    for i in 0..<manager.elementsCount { indexes.append(i) }
                                    if indexes.count > 0 {
                                        manager.zeroElements()
                                        tableView.deleteSections(IndexSet(indexes), with: manager.rowAnimation)
                                    }
                                } else {
                                    //print("In \(self.classForCoder).innerAsyncMain, dataousrces to remove: \(datasources.count)")
                                    for datasource in datasources {
                                        let sectionIndex = manager.sectionIndex(datasource: datasource)
                                        // print("In \(self.classForCoder).innerAsyncMain, dataousrces to remove: \(sectionIndex)")
                                        if sectionIndex >= 0 { indexes.append(sectionIndex) }
                                    }
                                    if indexes.count > 0 {
                                        indexes.sort()
                                        manager.remove(indexes: indexes)
                                        indexes.reverse()
                                        tableView.deleteSections(IndexSet(indexes), with: manager.rowAnimation)
                                    }
                                }
                                tableView.endUpdates()
                            }
                            self.completeIt(models: self.emptyResponse, error: nil)
                        }
                    } else if let collectionView = manager.scrollView as? UICollectionView {
                        DispatchQueue.main.async {
                            collectionView.performBatchUpdates({
                                if !(self.isCancelled && !self.ignoreCancel) {
                                    if self.all {
                                        for i in 0..<manager.elements.count { indexes.append(i) }
                                        if indexes.count > 0 {
                                            manager.zeroElements()
                                            collectionView.deleteSections(IndexSet(indexes))
                                        }
                                    } else {
                                        for datasource in datasources {
                                            let sectionIndex = manager.sectionIndex(datasource: datasource)
                                            if sectionIndex >= 0 { indexes.append(sectionIndex) }
                                        }
                                        if indexes.count > 0 {
                                            indexes.sort()
                                            manager.remove(indexes: indexes)
                                            collectionView.deleteSections(IndexSet(indexes))
                                        }
                                    }
                                }
                            }, completion: { (true) in
                                self.completeIt(models: self.emptyResponse, error: nil)
                            })
                        }
                    } else if manager.scrollView == nil {
                        if self.all { manager.zeroElements() }
                        else {
                            for datasource in datasources {
                                let sectionIndex = manager.sectionIndex(datasource: datasource)
                                if sectionIndex >= 0 { indexes.append(sectionIndex) }
                            }
                            if indexes.count > 0 {
                                indexes.sort()
                                indexes.reverse()
                                for index in indexes { manager.elements.remove(at: index) }
                            }
                        }
                        self.completeIt(models: self.emptyResponse, error: nil)
                        return
                    } else {
                        let error = RVError(message: "In \(self.classForCoder).main, erroneous ScrollView: \(manager.scrollView?.description ?? " no scrollView")!")
                        self.completeIt(models: self.emptyResponse, error: error)
                    }
                }
            }
        } else {
            let error = RVError(message: "In \(self.classForCoder).main, no manager")
            self.completeIt(error: error)
        }
    }
    func completeIt(models: [T] = [T](), error: RVError? = nil) {
        DispatchQueue.main.async {
            self.callback(self.emptyResponse, error)
            self.completeOperation()
        }
    }
}
