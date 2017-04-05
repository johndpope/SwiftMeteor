//
//  RVDSManager4.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/26/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit

class RVDSManager4 {
    var instanceType: String { get { return String(describing: type(of: self)) } }
    fileprivate let queue = RVOperationQueue()
    fileprivate var sections = [RVBaseDatasource4]()
    weak var scrollView: UIScrollView? = nil
    var rowAnimation: UITableViewRowAnimation = .automatic
    init(scrollView: UIScrollView?) {
        self.scrollView = scrollView
    }
    func sectionIndex(datasource: RVBaseDatasource4) -> Int {
        for i in 0..<sections.count {
            if sections[i] == datasource { return i }
        }
        return -1
    }
    func datasourceInSection(section: Int) -> RVBaseDatasource4? {
        if (section < 0) || (section >= self.sections.count) { return nil }
        return self.sections[section]
    }
    func removeDatasources(byType: [RVBaseDataSource.Type]) {
        
    }
    
    var numberOfSections: Int { return sections.count }
    func numberOfItems(section: Int) -> Int {
        if (section >= 0) || (section < sections.count) {
            return sections[section].numberOfItems
        } else {
            print("In \(self.instanceType).numberOfItems, invalid sectionIndex: \(section) ")
            return 0
        }
    }
    func scrolling(indexPath: IndexPath, scrollView: UIScrollView) {
        let section = indexPath.section
        if (section < 0) || (section >= sections.count) { return }
        sections[section].scroll(index: indexPath.row, scrollView: scrollView)
    }
    func item(indexPath: IndexPath) ->  RVBaseModel? {
        let section = indexPath.section
        if (section < 0) || (section >= sections.count) { return nil }
        return sections[section].item(index: indexPath.row, scrollView: self.scrollView)
    }
    func removeSections(datasources: [RVBaseDatasource4], callback: @escaping RVCallback) {
        self.queue.addOperation(RVManagerRemoveSections4(manager: self, datasources: datasources , callback: callback))
    }
    func removeAllSections(callback: @escaping RVCallback) {
        self.queue.addOperation(RVManagerRemoveSections4(title: "Remove All Sections", manager: self, datasources: [RVBaseDatasource4](), callback: callback, all: true))
    }
    func collapseAll(callback: @escaping RVCallback) {
        self.queue.addOperation(RVManagerExpandCollapseOperation4(title: "Collapse All", manager: self, operationType: .collapse, datasources: [RVBaseDatasource4](), callback: callback, all: true))
    }
    func collapse(datasource: RVBaseDatasource4, callback: @escaping RVCallback) {
        if self.sectionIndex(datasource: datasource) < 0 {
            let error = RVError(message: "In \(self.instanceType).collapse, datasource is not installed as a section \(datasource)")
            callback([RVBaseModel](), error)
            return
        } else {
            self.queue.addOperation(RVManagerExpandCollapseOperation4(title: "Collapse Operation", manager: self, operationType: .collapse, datasources: [datasource], callback: callback))
        }
    }
    func expand(datasource: RVBaseDatasource4, callback: @escaping RVCallback) {
        if self.sectionIndex(datasource: datasource) < 0 {
            let error = RVError(message: "In \(self.instanceType).expand, datasource is not installed as a section \(datasource)")
            callback([RVBaseModel](), error)
            return
        } else {
            self.queue.addOperation(RVManagerExpandCollapseOperation4(title: "Expand Operation", manager: self, operationType: .expand, datasources: [datasource], callback: callback))
        }
    }
    func toggle(datasource: RVBaseDatasource4, callback: @escaping RVCallback) {
        print("In \(self.instanceType).toggle -------------------------------------- ")
        if self.sectionIndex(datasource: datasource) < 0 {
            let error = RVError(message: "In \(self.instanceType).toggle, datasource is not installed as a section \(datasource)")
            callback([RVBaseModel](), error)
            return
        } else {
            self.queue.addOperation(RVManagerExpandCollapseOperation4(title: "Toggle Operation", manager: self, operationType: .toggle, datasources: [datasource], callback: callback))
        }
    }
    func appendSections(datasources: [RVBaseDatasource4], sectionTypesToRemove: [RVBaseDatasource4.DatasourceType] = Array<RVBaseDatasource4.DatasourceType>(), callback: @escaping RVCallback) {
        self.queue.addOperation(RVManagerAppendSections4(manager: self, datasources: datasources, sectionTypesToRemove: sectionTypesToRemove, callback: callback))
    }

    func restart(datasource: RVBaseDatasource4, query: RVQuery, callback: @escaping RVCallback) {
        datasource.cancelAllOperations()
        datasource.unsubscribe {
            datasource.restart(scrollView: self.scrollView, query: query, callback: callback)
        }
    }

}

class RVManagerRemoveSections4: RVAsyncOperation {
    weak var manager: RVDSManager4? = nil
    var datasources: [RVBaseDatasource4]
    var callback: RVCallback
    var all: Bool = false
    let emptyResponse = [RVBaseModel]()
    init(title: String = "Remove Sections", manager: RVDSManager4, datasources: [RVBaseDatasource4], callback: @escaping RVCallback, all: Bool = false) {
        self.callback = callback
        self.datasources = datasources
        self.all = all
        self.manager = manager
        super.init(title: title)
    }
    func completeIt(error: RVError? = nil) {
        DispatchQueue.main.async {
            self.callback(self.emptyResponse, error)
            self.completeOperation()
        }

    }
    override func asyncMain() {
        innerAsyncMain()
    }
    func innerAsyncMain() {
        if ((datasources.count == 0) && (!self.all)) || self.isCancelled {
            self.completeIt(error: nil)
            return
        } else if let manager = self.manager {
            var indexes = [Int]()
            let datasources = self.all ? manager.sections : self.datasources
            DispatchQueue.main.async {
                for datasource in datasources { datasource.cancelAllOperations() }
                DispatchQueue.main.async {
                    if let tableView = manager.scrollView as? UITableView {
                        DispatchQueue.main.async {
                            if !self.isCancelled {
                                tableView.beginUpdates()
                                if self.all {
                                    for i in 0..<manager.sections.count { indexes.append(i) }
                                    if indexes.count > 0 {
                                        manager.sections = [RVBaseDatasource4]()
                                        tableView.deleteSections(IndexSet(indexes), with: manager.rowAnimation)
                                    }
                                } else {
                                    for datasource in datasources {
                                        let sectionIndex = manager.sectionIndex(datasource: datasource)
                                        if sectionIndex >= 0 { indexes.append(sectionIndex) }
                                    }
                                    if indexes.count > 0 {
                                        indexes.sort()
                                        indexes.reverse()
                                        for index in indexes { manager.sections.remove(at: index) }
                                        indexes.reverse()
                                        tableView.deleteSections(IndexSet(indexes), with: manager.rowAnimation)
                                    }
                                }
                                tableView.endUpdates()
                            }
                            self.completeIt()
                        }
                    } else if let collectionView = manager.scrollView as? UICollectionView {
                        DispatchQueue.main.async {
                            collectionView.performBatchUpdates({
                                if !self.isCancelled {
                                    if self.all {
                                        for i in 0..<manager.sections.count { indexes.append(i) }
                                        if indexes.count > 0 {
                                            manager.sections = [RVBaseDatasource4]()
                                            collectionView.deleteSections(IndexSet(indexes))
                                        }
                                    } else {
                                        for datasource in datasources {
                                            let sectionIndex = manager.sectionIndex(datasource: datasource)
                                            if sectionIndex >= 0 { indexes.append(sectionIndex) }
                                        }
                                        if indexes.count > 0 {
                                            indexes.sort()
                                            indexes.reverse()
                                            for index in indexes { manager.sections.remove(at: index) }
                                            indexes.reverse()
                                            collectionView.deleteSections(IndexSet(indexes))
                                        }
                                    }
                                }
                            }, completion: { (true) in
                                self.completeIt()
                            })
                        }
                    } else if manager.scrollView == nil {
                        if self.all { manager.sections = [RVBaseDatasource4]() }
                        else {
                            for datasource in datasources {
                                let sectionIndex = manager.sectionIndex(datasource: datasource)
                                if sectionIndex >= 0 { indexes.append(sectionIndex) }
                            }
                            if indexes.count > 0 {
                                indexes.sort()
                                indexes.reverse()
                                for index in indexes { manager.sections.remove(at: index) }
                            }
                        }
                        self.completeIt()
                    } else {
                        let error = RVError(message: "In \(self.classForCoder).main, erroneous ScrollView: \(manager.scrollView)!")
                        self.completeIt(error: error)
                    }
                }
            }
        } else {
            let error = RVError(message: "In \(self.classForCoder).main, no manager")
            self.completeIt(error: error)
        }
    }
}

class RVManagerAppendSections4: RVManagerRemoveSections4 {
    var sectionTypesToRemove: [RVBaseDatasource4.DatasourceType]
    var sectionsToBeRemoved: [RVBaseDatasource4] = [RVBaseDatasource4]()
    init(title: String = "Add Sections", manager: RVDSManager4, datasources: [RVBaseDatasource4], sectionTypesToRemove: [RVBaseDatasource4.DatasourceType] = Array<RVBaseDatasource4.DatasourceType>(), callback: @escaping RVCallback) {
        self.sectionTypesToRemove = sectionTypesToRemove
        super.init(title: "Add Sections", manager: manager, datasources: datasources, callback: callback)
    }
    func completeCancel() {
        DispatchQueue.main.async {
            if self.sectionsToBeRemoved.count > 0 {
                self.datasources = self.sectionsToBeRemoved
                self.innerAsyncMain()
            } else {
                self.callback(self.emptyResponse, nil)
                self.completeOperation()
            }
        }
    }
    override func asyncMain() {
        if (datasources.count == 0) || self.isCancelled {
            completeCancel()
            return
        }
        if let manager = self.manager {
            if let tableView = manager.scrollView  as? UITableView {
                DispatchQueue.main.async {
                    if !self.isCancelled {
                       // print("In \(self.classForCoder).main, have TableView, notCancelled")
                        if self.sectionTypesToRemove.count > 0 {
                            for section in manager.sections {
                                for type in self.sectionTypesToRemove {
                                    if section.datasourceType == type {
                                        section.unsubscribe { section.cancelAllOperations() }
                                        self.sectionsToBeRemoved.append(section)
                                    }
                                }
                            }
                        }
                        tableView.beginUpdates()
                        var indexes = [Int]()
                        for datasource in self.datasources {
                            indexes.append(manager.sections.count)
                            manager.sections.append(datasource)
                        }
                   //     print("In \(self.classForCoder).main number of sections = \(manager.sections.count)")
                        tableView.insertSections(IndexSet(indexes), with: manager.rowAnimation)
                        tableView.endUpdates()
                    }
                    self.callback(self.emptyResponse, nil)
                    self.completeOperation()
                }
                return
            } else if let collectionView = manager.scrollView as? UICollectionView {
                DispatchQueue.main.async {
                    collectionView.performBatchUpdates({
                        if !self.isCancelled {
                            if self.sectionTypesToRemove.count > 0 {
                                for section in manager.sections {
                                    for type in self.sectionTypesToRemove {
                                        if section.datasourceType == type {
                                            section.unsubscribe { section.cancelAllOperations() }
                                            self.sectionsToBeRemoved.append(section)
                                        }
                                    }
                                }
                            }
                            var indexes = [Int]()
                            for datasource in self.datasources {
                                indexes.append(manager.sections.count)
                                manager.sections.append(datasource)
                            }
                            collectionView.insertSections(IndexSet(indexes))
                        }
                    }, completion: { (success) in
                        self.callback(self.emptyResponse, nil)
                        self.completeOperation()
                    })
                }
                return
            } else if manager.scrollView == nil {
                if self.sectionTypesToRemove.count > 0 {
                    for section in manager.sections {
                        for type in self.sectionTypesToRemove {
                            if section.datasourceType == type {
                                section.unsubscribe { section.cancelAllOperations() }
                                self.sectionsToBeRemoved.append(section)
                            }
                        }
                    }
                }
                for datasource in self.datasources { manager.sections.append(datasource) }
                DispatchQueue.main.async {
                    self.callback(self.emptyResponse, nil )
                    self.completeOperation()
                }
            } else {
                let error = RVError(message: "In \(self.classForCoder).main, erroneous ScrollView: \(manager.scrollView)!")
                DispatchQueue.main.async {
                    self.callback(self.emptyResponse, error )
                    self.completeOperation()
                }
            }
        } else {
            let error = RVError(message: "In \(self.classForCoder).main, no manager")
            DispatchQueue.main.async {
                self.callback(self.emptyResponse, error)
                self.completeOperation()
            }
        }
    }
}

class RVManagerExpandCollapseOperation4: RVAsyncOperation {
    enum OperationType {
        case expand
        case collapse
        case toggle
    }
    weak var manager: RVDSManager4? = nil
    let emptyResponse = [RVBaseModel]()
    var callback: RVCallback
    var operationType: OperationType
    var datasources: [RVBaseDatasource4]
    var all: Bool = false
    var count: Int
    init(title: String, manager: RVDSManager4, operationType: OperationType, datasources: [RVBaseDatasource4], callback: @escaping RVCallback, all: Bool = false) {
        self.manager = manager
        self.callback = callback
        self.datasources = datasources
        self.count = datasources.count
        self.operationType = operationType
        self.all = all
        super.init(title: title)
    }
    override func asyncMain() {
        if (self.manager != nil) && ( (self.datasources.count > 0) || self.all ) {
            if self.isCancelled {
                DispatchQueue.main.async {
                    self.callback(self.emptyResponse, nil)
                    self.completeOperation()
                }
                return
            } else { actualOperation() }
        } else {
            DispatchQueue.main.async {
                self.callback(self.emptyResponse, nil)
                self.completeOperation()
            }
        }
        
    }
    func actualOperation() {
        if self.isCancelled {
            self.callback(emptyResponse, nil)
            completeOperation()
            return
        }
        if let manager = self.manager {
            let datasources = self.all ? manager.sections : self.datasources
            switch(self.operationType) {
            case .expand:
                for datasource in datasources {
                let scrollView = (manager.sectionIndex(datasource: datasource) < 0) ? nil : manager.scrollView
                    datasource.expand(scrollView: scrollView, callback: { (models, error) in
                        self.count = self.count - 1
                        if let error = error {
                            error.append(message: "In \(self.instanceType).actualOperation expand, got error")
                            DispatchQueue.main.async {
                                self.callback(models, error)
                                self.completeOperation()
                            }
                        } else if self.count <= 0 {
                            DispatchQueue.main.async {
                                self.callback(models, error)
                                self.completeOperation()
                            }
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
                            DispatchQueue.main.async {
                                self.callback(models, error)
                                self.completeOperation()
                            }
                        } else if self.count <= 0 {
                            DispatchQueue.main.async {
                                self.callback(models, error)
                                self.completeOperation()
                            }
                        }
                    })
                }
                return
            case .toggle:
                print("In \(self.instanceType).actualOperation, toggle number of datasources \(datasources.count)")
                self.count = datasources.count
                for datasource in datasources {
                    let scrollView = (manager.sectionIndex(datasource: datasource) < 0) ? nil : manager.scrollView
                    datasource.toggle(scrollView: scrollView, callback: { (models, error) in
                        print("In \(self.instanceType).actualOperation, toggle count \(self.count)  $$$$$$$$$$$$$$$$$")
                        self.count = self.count - 1
                        if let error = error {
                            error.append(message: "In \(self.instanceType).actualOperation toggle, got error")
                            DispatchQueue.main.async {
                                self.callback(models, error)
                                self.completeOperation()
                            }
                        } else if self.count <= 0 {
                            DispatchQueue.main.async {
                                self.callback(models, error)
                                self.completeOperation()
                            }
                        }
                    })
                }
                return
            }
        } else {
            let error = RVError(message: "In \(self.instanceType).actualOperation, no manager")
            DispatchQueue.main.async {
                self.callback(self.emptyResponse, error)
                self.completeOperation()
            }

            return
        }

    }
}
