//
//  RVDSManager4.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/26/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit



class RVDSManager4<T:NSObject>: NSObject {
    var instanceType: String { get { return String(describing: type(of: self)) } }
    let queue = RVOperationQueue()
    var elements = [RVBaseDatasource4<T>]()
    var offset = 0
    var virtualCount: Int {
        return elements.count + offset
    }
    weak var scrollView: UIScrollView? = nil
    var rowAnimation: UITableViewRowAnimation = .automatic
    init(scrollView: UIScrollView?) { self.scrollView = scrollView }
    var frontElement: RVBaseDatasource4<T>? { return elements.first }
    var backElement: RVBaseDatasource4<T>? { return elements.last }
    
    func sectionIndex(datasource: RVBaseDatasource4<T>) -> Int {
        for i in 0..<elements.count {
            if elements[i] == datasource { return i + offset }
        }
        return -1
    }
    func datasourceInSection(section: Int) -> RVBaseDatasource4<T>? {
        if (section >= 0) && (section < virtualCount) {
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
 
    var numberOfSections: Int { return numberOfElements }
    var numberOfElements: Int { get { return virtualCount } }
    func numberOfItems(section: Int) -> Int {
        if let datasource = self.datasourceInSection(section: section) {
            return datasource.numberOfElements
        } else { return 0 }
    }
    func scrolling(indexPath: IndexPath, scrollView: UIScrollView) {
        let section = indexPath.section
        if let datasource = self.datasourceInSection(section: section) {
            datasource.scroll(indexPath: indexPath, scrollView: scrollView)
        } else {
            // Neil retrieve more
        }
    }
    func element(indexPath: IndexPath, scrollView: UIScrollView?, updateLast: Bool = true) -> T? {
   // func element(indexPath: IndexPath) ->  T? {
        let section = indexPath.section
        if let datasource = datasourceInSection(section: section) {
            return datasource.element(indexPath: indexPath, scrollView: scrollView)
        } else {
            return nil
        }
    }
    func removeSections(datasources: [RVBaseDatasource4<T>], callback: @escaping RVCallback<T>) {
        self.queue.addOperation(RVManagerRemoveSections4(manager: self, datasources: datasources , callback: callback))
    }
    func removeAllSections(callback: @escaping RVCallback<T>) {
        self.queue.addOperation(RVManagerRemoveSections4(title: "Remove All Sections", manager: self, datasources: [RVBaseDatasource4<T>](), callback: callback, all: true))
    }
    func collapseAll(callback: @escaping RVCallback<T>) {
        self.queue.addOperation(RVManagerExpandCollapseOperation4(title: "Collapse All", manager: self, operationType: .collapse, datasources: [RVBaseDatasource4<T>](), callback: callback, all: true))
    }
    func collapse(datasource: RVBaseDatasource4<T>, callback: @escaping RVCallback<T>) {
        if self.sectionIndex(datasource: datasource) < 0 {
            let error = RVError(message: "In \(self.instanceType).collapse, datasource is not installed as a section \(datasource)")
            callback([T](), error)
            return
        } else {
            self.queue.addOperation(RVManagerExpandCollapseOperation4(title: "Collapse Operation", manager: self, operationType: .collapse, datasources: [datasource], callback: callback))
        }
    }
    func expand(datasource: RVBaseDatasource4<T>, callback: @escaping RVCallback<T>) {
        if self.sectionIndex(datasource: datasource) < 0 {
            let error = RVError(message: "In \(self.instanceType).expand, datasource is not installed as a section \(datasource)")
            callback([T](), error)
            return
        } else {
            self.queue.addOperation(RVManagerExpandCollapseOperation4(title: "Expand Operation", manager: self, operationType: .expand, datasources: [datasource], callback: callback))
        }
    }
    func toggle(datasource: RVBaseDatasource4<T>, callback: @escaping RVCallback<T>) {
       // print("In \(self.instanceType).toggle -------------------------------------- ")
        if self.sectionIndex(datasource: datasource) < 0 {
            let error = RVError(message: "In \(self.instanceType).toggle, datasource is not installed as a section \(datasource)")
            callback([T](), error)
            return
        } else {
            self.queue.addOperation(RVManagerExpandCollapseOperation4(title: "Toggle Operation", manager: self, operationType: .toggle, datasources: [datasource], callback: callback))
        }
    }
    func appendSections(datasources: [RVBaseDatasource4<T>], sectionTypesToRemove: [RVBaseDatasource4<T>.DatasourceType] = Array<RVBaseDatasource4<T>.DatasourceType>(), callback: @escaping RVCallback<T>) {
        self.queue.addOperation(RVManagerAppendSections4<T>(manager: self, datasources: datasources, sectionTypesToRemove: sectionTypesToRemove, callback: callback))
    }

    func restart(datasource: RVBaseDatasource4<T>, query: RVQuery, callback: @escaping RVCallback<T>) {
        datasource.restart(scrollView: self.scrollView, query: query, callback: callback)
    }


}


class RVManagerRemoveSections4<T:NSObject>: RVAsyncOperation<T> {
    weak var manager: RVDSManager4<T>? = nil
    var datasources: [RVBaseDatasource4<T>]

    var all: Bool = false
    var ignoreCancel: Bool = false
    let emptyResponse = [T]()
    init(title: String = "Remove Sections", manager: RVDSManager4<T>, datasources: [RVBaseDatasource4<T>], callback: @escaping RVCallback<T>, all: Bool = false) {
        self.datasources = datasources
        self.all = all
        self.manager = manager
        super.init(title: title, callback: callback)
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
                                    for i in 0..<manager.elements.count { indexes.append(i) }
                                    if indexes.count > 0 {
                                        manager.elements = [RVBaseDatasource4<T>]()
                                        tableView.deleteSections(IndexSet(indexes), with: manager.rowAnimation)
                                    }
                                } else {
                                    //print("In \(self.classForCoder).innerAsyncMain, dataousrces to remove: \(datasources.count)")
                                    for datasource in datasources {
                                        let sectionIndex = manager.sectionIndex(datasource: datasource)
                                       // print("In \(self.classForCoder).innerAsyncMain, dataousrces to remove: \(sectionIndex)")
                                        if sectionIndex >= 0 {
                                            indexes.append(sectionIndex)
                                        }
                                    }
                                    if indexes.count > 0 {
                                        indexes.sort()
                                        indexes.reverse()
                                        for index in indexes { manager.elements.remove(at: index) }
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
                                if !(self.isCancelled && !self.ignoreCancel) {
                                    if self.all {
                                        for i in 0..<manager.elements.count { indexes.append(i) }
                                        if indexes.count > 0 {
                                            manager.elements = [RVBaseDatasource4<T>]()
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
                                            for index in indexes { manager.elements.remove(at: index) }
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
                        if self.all { manager.elements = [RVBaseDatasource4<T>]() }
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
                        self.completeIt()
                    } else {
                        let error = RVError(message: "In \(self.classForCoder).main, erroneous ScrollView: \(manager.scrollView?.description ?? " no scrollView")!")
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

class RVManagerAppendSections4<T: NSObject>: RVManagerRemoveSections4<T> {
    var sectionTypesToRemove: [RVBaseDatasource4<T>.DatasourceType]
    var sectionsToBeRemoved: [RVBaseDatasource4<T>] = [RVBaseDatasource4<T>]()
    init(title: String = "Add Sections", manager: RVDSManager4<T>, datasources: [RVBaseDatasource4<T>], sectionTypesToRemove: [RVBaseDatasource4<T>.DatasourceType] = Array<RVBaseDatasource4<T>.DatasourceType>(), callback: @escaping RVCallback<T>) {
        self.sectionTypesToRemove = sectionTypesToRemove
        super.init(title: "Add Sections", manager: manager, datasources: datasources, callback: callback)
    }
    func complete(error: RVError?) {
        DispatchQueue.main.async {
            if let error = error {
                self.datasources = [RVBaseDatasource4<T>]()
                self.callback(self.emptyResponse, error)
                self.completeOperation()
            } else if self.sectionsToBeRemoved.count > 0 {
                self.datasources = self.sectionsToBeRemoved
                self.innerAsyncMain()
            } else {
                self.datasources = [RVBaseDatasource4<T>]()
                self.callback(self.emptyResponse, error)
                self.completeOperation()
            }
        }
    }
    override func asyncMain() {
        if (datasources.count == 0) || self.isCancelled {
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
                        var indexes = [Int]()
                        for datasource in self.datasources {
                            indexes.append(manager.elements.count)
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
                            for datasource in self.datasources {
                                indexes.append(manager.elements.count)
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
}

class RVManagerExpandCollapseOperation4<T: NSObject>: RVAsyncOperation<T> {
    enum OperationType {
        case expand
        case collapse
        case toggle
    }
    weak var manager: RVDSManager4<T>? = nil
    
    let emptyResponse = [T]()
    var operationType: OperationType
    var datasources: [RVBaseDatasource4<T>]
    var all: Bool = false
    var count: Int
    init(title: String, manager: RVDSManager4<T>, operationType: OperationType, datasources: [RVBaseDatasource4<T>], callback: @escaping RVCallback<T>, all: Bool = false) {
        self.manager = manager
        self.datasources = datasources
        self.count = datasources.count
        self.operationType = operationType
        self.all = all
        super.init(title: title, callback: callback)
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
            let datasources = self.all ? manager.elements : self.datasources
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
               // print("In \(self.instanceType).actualOperation, toggle number of datasources \(datasources.count)")
                self.count = datasources.count
                for datasource in datasources {
                    let scrollView = (manager.sectionIndex(datasource: datasource) < 0) ? nil : manager.scrollView
                    datasource.toggle(scrollView: scrollView, callback: { (models, error) in
                        //print("In \(self.instanceType).actualOperation, toggle count \(self.count)  $$$$$$$$$$$$$$$$$")
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
