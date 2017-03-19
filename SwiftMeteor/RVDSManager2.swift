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
}
class RVManagerCollapseOperation: RVManagerExpandOperation {
    override func actualOperation(datasource: RVBaseDataSource, completeOperation: @escaping() -> Void) {
        if self.isCancelled {
            self.callback()
            completeOperation()
            return
        }
        if !datasource.collapsed {
            datasource.collapse {
                self.callback()
                completeOperation()
                return
            }
        } else {
            self.callback()
            completeOperation()
            return
        }
    }
}
class RVManagerExpandOperation: RVAsyncOperation {
    weak var manager: RVDSManager2? = nil
    var callback: () -> Void
    weak var datasource: RVBaseDataSource? = nil
    init(title: String, manager: RVDSManager2, datasource: RVBaseDataSource, callback: @escaping() -> Void) {
        self.manager = manager
        self.callback = callback
        self.datasource = datasource
        super.init(title: title)
    }
    override func main() {
        if let manager = self.manager {
            if let datasource = self.datasource {
                if self.isCancelled {
                    self.callback()
                    completeOperation()
                    return
                }
                let sectionNumber = manager.section(datasource: datasource)
                if sectionNumber >= 0 {
                    actualOperation(datasource: datasource, completeOperation: completeOperation)
                    return
                } else {
                    self.callback()
                    completeOperation()
                    return
                }
            } else {
                self.callback()
                completeOperation()
                return
            }
        } else {
            self.callback()
            completeOperation()
        }

    }
    func actualOperation(datasource: RVBaseDataSource, completeOperation: @escaping() -> Void) {
        if self.isCancelled {
            self.callback()
            completeOperation()
            return
        }
        if datasource.collapsed {
            datasource.expand {
                self.callback()
                completeOperation()
                return
            }
        } else {
            self.callback()
            completeOperation()
            return
        }
    }
}
class RVManagerRemoveAllSectionsOperation: RVManagerStartDatasourceOperation {
    init(title: String, manager: RVDSManager2, callback: @escaping (RVError?) -> Void) {
        super.init(title: title, manager: manager, datasource: RVBaseDatasource2(), query: RVQuery() , callback: callback)
    }
    override func main() {
        if let manager = manager {
            if let tableView = manager.scrollView as? UITableView {
                if self.isCancelled {
                    self.callback(nil)
                    completeOperation()
                    return
                }
                tableView.beginUpdates()
                let indexSet = IndexSet(0..<manager.sections.count)
                manager.sections = [RVBaseDataSource]()
                tableView.deleteSections(indexSet, with: manager.animation)
                tableView.endUpdates()
                self.callback(nil)
                completeOperation()
                return
            } else if let _ = manager.scrollView as? UICollectionView {
                print("In \(self.instanceType).opeartion, CollectionView not supported")
                let rvError = RVError(message: "In \(self.instanceType).operation CollectionView not supported")
                self.callback(rvError)
                completeOperation()
                return
            } else {
                manager.sections = [RVBaseDataSource]()
                self.callback(nil)
                completeOperation()
                return
            }
        } else {
            print("In \(self.instanceType).operation no manager")
            self.callback(nil)
            completeOperation()
        }
        
    }
    
    func removeAllSections(callback: @escaping() -> Void) {

    }
}
class RVManagerStartDatasourceOperation: RVAsyncOperation {
    var datasource: RVBaseDataSource
    var query: RVQuery
    var callback: (RVError?) -> Void
    weak var manager: RVDSManager2? = nil
    init(title: String, manager: RVDSManager2, datasource: RVBaseDataSource, query: RVQuery, callback: @escaping(RVError?) -> Void ) {
        self.datasource = datasource
        self.query = query
        self.callback = callback
        self.manager = manager
        super.init(title: title)
    }
    override func main() {
        if let manager = manager {
            if self.isCancelled {
                self.callback(nil)
                completeOperation()
                return
            }
            let sectionNumber = manager.section(datasource: datasource)
            if sectionNumber >= 0 {
                self.datasource.start(query: query, callback: { (error) in
                    self.callback(error)
                    self.completeOperation()
                })
                return
            } else {
                let rvError = RVError(message: "In \(self.instanceType).operation datasource not found")
                self.callback(rvError)
                completeOperation()
                return
            }
        } else {
            print("In \(self.instanceType).operation no manager")
            self.callback(nil)
            completeOperation()
        }

    }
}
class RVManagerStopDatasourceOperation: RVManagerStartDatasourceOperation {
    init(title: String, manager: RVDSManager2, datasource: RVBaseDataSource, callback: @escaping(RVError?) -> Void ) {
        super.init(title: title, manager: manager, datasource: datasource , query: RVQuery() , callback: callback)
    }
    override func main() {
        if let manager = manager {
            if self.isCancelled {
                self.callback(nil)
                completeOperation()
                return
            }
            let sectionNumber = manager.section(datasource: datasource)
            if sectionNumber >= 0 {
                self.datasource.stop{(error) in
                    self.callback(error)
                    self.completeOperation()
                }
                return
            } else {
                let rvError = RVError(message: "In \(self.instanceType).operation datasource not found")
                self.callback(rvError)
                completeOperation()
                return
            }
        } else {
            print("In \(self.instanceType).operation no manager")
            self.callback(nil)
            completeOperation()
        }
        
    }
}
