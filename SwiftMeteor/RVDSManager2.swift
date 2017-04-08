//
//  RVDSManager2.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/10/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
class RVDSManager2: RVDSManager {
    let queue = RVOperationQueue()
    override func section(datasource: RVBaseDataSource) -> Int { return super.section(datasource: datasource )}
    override func numberOfItems(section: Int) -> Int { return super.numberOfItems(section: section) }
    override func numberOfSections(scrollView: UIScrollView?) -> Int { return super.numberOfSections(scrollView: scrollView) }
    override func item(section: Int, location: Int) -> RVBaseModel? { return super.item(section: section, location: location) }
    override func item(indexPath: IndexPath) -> RVBaseModel? { return super.item(indexPath: indexPath) }
    override func collapseDatasource(datasource: RVBaseDataSource, callback: @escaping () -> Void) {
        let operation = RVManagerCollapseOperation(title: "Collapse", manager: self , datasource: datasource, callback: callback)
        self.queue.addOperation(operation)
    }
    override func expandDatasource(datasource: RVBaseDataSource, callback: @escaping () -> Void) {
        let operation = RVManagerExpandOperation(title: "Expand", manager: self , datasource: datasource , callback: callback)
        self.queue.addOperation(operation)
    }
    override func addSection(section: RVBaseDataSource) { super.addSection(section: section) }
    func removeAllSections(callback: @escaping (RVError?) -> Void) {
        let operation = RVManagerRemoveAllSectionsOperation(title: "RemoveAllSections", manager: self, callback: callback)
        self.queue.addOperation(operation)
    }
    override func startDatasource(datasource: RVBaseDataSource, query: RVQuery, callback: @escaping (RVError?) -> Void) {
        let operation = RVManagerStartDatasourceOperation(title: datasource.datasourceType.rawValue, manager: self , datasource: datasource, query: query, callback: callback)
        self.queue.addOperation(operation)
    }
    override func stopDatasource(datasource: RVBaseDataSource, callback: @escaping (RVError?) -> Void) {
        let operation = RVManagerStopDatasourceOperation(title: datasource.datasourceType.rawValue, manager: self , datasource: datasource, callback: callback)
        self.queue.addOperation(operation)
    }
    func toggle(datasource: RVBaseDataSource, callback: @escaping() -> Void) {
        if datasource.collapsed {
            self.expandDatasource(datasource: datasource, callback: callback)
        } else {
            self.collapseDatasource(datasource: datasource, callback: callback)
        }
    }
    func resetDatasource(datasource: RVBaseDataSource, callback: @escaping (RVError?) -> Void ) {
        let operation = RVManagerResetDatasourceOperation(title: "Reset Datasource", datasource: datasource, callback: callback)
        self.queue.addOperation(operation)
    }
}
class RVManagerCollapseOperation: RVManagerExpandOperation {
    override func actualOperation(datasource: RVBaseDataSource, completeOperation: @escaping() -> Void) {
        //print("In \(self.classForCoder).actualOperation )")
        if self.isCancelled {
            self.pcallback()
            completeOperation()
            return
        }
        if !datasource.collapsed {
            datasource.collapse {
                self.pcallback()
                completeOperation()
                return
            }
        } else {
            self.pcallback()
            completeOperation()
            return
        }
    }
}
class RVManagerExpandOperation: RVAsyncOperation {
    weak var manager: RVDSManager2? = nil
    var pcallback: () -> Void
    weak var datasource: RVBaseDataSource? = nil
    init(title: String, manager: RVDSManager2, datasource: RVBaseDataSource, callback: @escaping() -> Void) {
        self.manager = manager
        self.pcallback = callback
        self.datasource = datasource
        super.init(title: title, callback: {(models: [RVBaseModel], error: RVError?) in }, parent: nil)
    }
    override func asyncMain() {
        if let manager = self.manager {
            if let datasource = self.datasource {
                if self.isCancelled {
                    self.pcallback()
                    completeOperation()
                    return
                }
                let sectionNumber = manager.section(datasource: datasource)
                if sectionNumber >= 0 {
                    actualOperation(datasource: datasource, completeOperation: completeOperation)
                    return
                } else {
                    self.pcallback()
                    completeOperation()
                    return
                }
            } else {
                self.pcallback()
                completeOperation()
                return
            }
        } else {
            self.pcallback()
            completeOperation()
        }

    }
    func actualOperation(datasource: RVBaseDataSource, completeOperation: @escaping() -> Void) {
        if self.isCancelled {
            self.pcallback()
            completeOperation()
            return
        }
        if datasource.collapsed {
            datasource.expand {
                self.pcallback()
                completeOperation()
                return
            }
        } else {
            self.pcallback()
            completeOperation()
            return
        }
    }
}
class RVManagerRemoveAllSectionsOperation: RVManagerStartDatasourceOperation {
    init(title: String, manager: RVDSManager2, callback: @escaping (RVError?) -> Void) {
        super.init(title: title, manager: manager, datasource: RVBaseDatasource2(), query: RVQuery() , callback: callback)
    }
    override func asyncMain() {
        if let manager = manager {
            if let tableView = manager.scrollView as? UITableView {
                if self.isCancelled {
                    self.pcallback(nil)
                    completeOperation()
                    return
                }
                tableView.beginUpdates()
                let indexSet = IndexSet(0..<manager.sections.count)
                manager.sections = [RVBaseDataSource]()
                tableView.deleteSections(indexSet, with: manager.animation)
                tableView.endUpdates()
                self.pcallback(nil)
                completeOperation()
                return
            } else if let _ = manager.scrollView as? UICollectionView {
                print("In \(self.instanceType).opeartion, CollectionView not supported")
                let rvError = RVError(message: "In \(self.instanceType).operation CollectionView not supported")
                self.pcallback(rvError)
                completeOperation()
                return
            } else {
                manager.sections = [RVBaseDataSource]()
                self.pcallback(nil)
                completeOperation()
                return
            }
        } else {
            print("In \(self.instanceType).operation no manager")
            self.pcallback(nil)
            completeOperation()
        }
        
    }
    
    func removeAllSections(callback: @escaping() -> Void) {

    }
}
class RVManagerStartDatasourceOperation: RVAsyncOperation {
    var datasource: RVBaseDataSource
    var query: RVQuery
    var pcallback: (RVError?) -> Void
    weak var manager: RVDSManager2? = nil
    init(title: String, manager: RVDSManager2, datasource: RVBaseDataSource, query: RVQuery, callback: @escaping(RVError?) -> Void ) {
        self.datasource = datasource
        self.query = query
        self.pcallback = callback
        self.manager = manager
        super.init(title: title, callback: {(models: [RVBaseModel], error: RVError?) in })
    }
    override func asyncMain() {
        if let manager = manager {
            if self.isCancelled {
                self.pcallback(nil)
                completeOperation()
                return
            }
            let sectionNumber = manager.section(datasource: datasource)
            if sectionNumber >= 0 {
                self.datasource.start(query: query, callback: { (error) in
                    self.pcallback(error)
                    self.completeOperation()
                })
                return
            } else {
                let rvError = RVError(message: "In \(self.instanceType).operation datasource not found")
                self.pcallback(rvError)
                completeOperation()
                return
            }
        } else {
            print("In \(self.instanceType).operation no manager")
            self.pcallback(nil)
            completeOperation()
        }

    }
}
class RVManagerResetDatasourceOperation: RVAsyncOperation {
    var datasource: RVBaseDataSource
    var pcallback: (RVError?) -> Void
    init(title: String, datasource: RVBaseDataSource, callback: @escaping(RVError?) -> Void ) {
        self.datasource = datasource
        self.pcallback = callback
        super.init(title: title, callback: {(models: [RVBaseModel], error: RVError?) in })
    }
    override func asyncMain() {
        
        if self.isCancelled {
            self.pcallback(nil)
            completeOperation()
            return
        } else {
            
            self.datasource.reset {
               // print("IN \(self.classForCoder).main return from reset")
                self.pcallback(nil)
                self.completeOperation()
            }
        }
    }
}
class RVManagerStopDatasourceOperation: RVManagerStartDatasourceOperation {
    init(title: String, manager: RVDSManager2, datasource: RVBaseDataSource, callback: @escaping(RVError?) -> Void ) {
        super.init(title: title, manager: manager, datasource: datasource , query: RVQuery() , callback: callback)
    }
    override func asyncMain() {
        if let manager = manager {
            if self.isCancelled {
                self.pcallback(nil)
                completeOperation()
                return
            }
            let sectionNumber = manager.section(datasource: datasource)
            if sectionNumber >= 0 {
                self.datasource.stop{(error) in
                    self.pcallback(error)
                    self.completeOperation()
                }
                return
            } else {
                let rvError = RVError(message: "In \(self.instanceType).operation datasource not found")
                self.pcallback(rvError)
                completeOperation()
                return
            }
        } else {
            print("In \(self.instanceType).operation no manager")
            self.pcallback(nil)
            completeOperation()
        }
        
    }
}
