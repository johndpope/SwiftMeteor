//
//  RVSectionManager4.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/8/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
class RVSectionManager4<T: NSObject> {
    var instanceType: String { get { return String(describing: type(of: self)) } }
    fileprivate let queue = RVOperationQueue()
    fileprivate var sections = [RVBaseDatasource4]()

    var manager: RVDSManager4<T>
    init(manager: RVDSManager4<T>) {
        self.manager = manager
    }
    func numberOfSections() -> Int { return manager.numberOfSections }
    func numberOfItems(section: Int) -> Int {
        return manager.numberOfItems(section: section)
    }
    func item(indexPath: IndexPath) -> RVBaseModel? {
        return manager.item(indexPath: indexPath)
    }
    func scrolling(indexPath: IndexPath, scrollView: UIScrollView) {
        manager.scrolling(indexPath: indexPath , scrollView: scrollView)
    }
    func collapse(datasource: RVBaseDatasource4<T>, callback: @escaping RVCallback) {
        if manager.sectionIndex(datasource: datasource) < 0 {
            let error = RVError(message: "In \(self.instanceType).collapse, datasource is not installed as a section \(datasource)")
            callback([RVBaseModel](), error)
        } else{
            
        }
    }
    func expand(datasource: RVBaseDatasource4<T>, callback: @escaping RVCallback) {
        if manager.sectionIndex(datasource: datasource) < 0 {
            let error = RVError(message: "In \(self.instanceType).expand, datasource is not installed as a section \(datasource)")
            callback([RVBaseModel](), error)
        } else {
            
        }
    }
    var baseQuery: (RVQuery, RVError?) {
        print("In \(self.instanceType).baseQuery, need to replace")
        return (RVQuery(), nil)
    }
    func retrieveSections(callback: RVCallback) {
        print("In \(self.instanceType).retrieveSections, need to replace")
        callback([RVBaseModel](), nil)
    }
    var frontQueryOperationActive: Bool = false
    var backQueryOperationActive: Bool = false
    var frontSection: RVBaseDatasource4<T>? { return manager.frontSection}
    var backSection: RVBaseDatasource4<T>? { return manager.backSection }
}
class RVSectionManagerLoadOperation<T: NSObject>: RVAsyncOperation {
    weak var scrollView: UIScrollView?
    var front: Bool
    weak var sectionManager: RVSectionManager4<T>?
    var reference: RVBaseDatasource4<T>?
    init(title: String = "RVSectionManagerLoadOperation", sectionManager: RVSectionManager4<T>, scrollView: UIScrollView?, front: Bool = false, callback: @escaping RVCallback) {
        self.scrollView             = scrollView
        self.sectionManager         = sectionManager
        self.front                  = front
        super.init(title: "\(title) with front: \(front)", callback: callback, parent: nil)
    }
    override func asyncMain() {
        InnerMain()
    }
    func InnerMain() {
        if self.isCancelled {
            self.completeOperation(error: nil)
            return
        } else {
            if let sectionManager = self.sectionManager {
                let(query, error) = sectionManager.baseQuery
                if let error = error {
                    error.append(message: "In \(self.instanceType).InnerMain, got error creating query")
                    self.completeOperation(error: error)
                    return
                } else {
                    var query = query.duplicate()
                    if front {
                        if sectionManager.frontQueryOperationActive {
                            self.completeOperation(error: nil)
                            return
                        } else {
                            sectionManager.frontQueryOperationActive = true
                        }
                    } else {
                        if sectionManager.backQueryOperationActive {
                            self.completeOperation(error: nil)
                            return
                        } else {
                            sectionManager.backQueryOperationActive = true
                        }
                    }
                    self.reference = self.front ? sectionManager.frontSection : sectionManager.backSection
                    query = self.updateQuery(query: query, reference: self.reference, front: self.front)
                    self.innerRetrieve(query: query, callback: { (models, error) in
                        if let error = error {
                            error.append(message: "In \(self.instanceType).InnerMain, error retrieving Sections")
                            self.completeOperation(models: models, error: error)
                            return
                        } else if self.isCancelled {
                            self.completeOperation(models: models, error: nil)
                        } else {
                            self.insert(models: models, callback: { (models , error) in
                                if let error = error {
                                    error.append(message: "In \(self.instanceType).InnerMain, error inserting sections")
                                    self.completeOperation(models: models , error: error)
                                    return
                                } else {
                                    self.refreshView {
                                        self.completeOperation(models: models , error: nil)
                                        return
                                    }
                                }
                            })
                        }
                    })
                }
                
            } else {
                self.completeOperation(error: nil)
            }
        }
    }
    func innerRetrieve(query: RVQuery, callback: @escaping RVCallback) {
        DispatchQueue.main.async {
            self.retrieveSections(query: query, callback: callback)
        }
    }
    func insert(models: [RVBaseModel], callback: @escaping RVCallback) {
        print("In \(self.instanceType).insert, need to implement")
    }
    func retrieveSections(query: RVQuery, callback: RVCallback) {
        print("In \(self.instanceType).retrieveSections, need to replace")
        callback([RVBaseModel](), nil)
    }
    func updateQuery(query: RVQuery, reference: RVBaseDatasource4<T>?, front: Bool) -> RVQuery {
        print("In \(self.classForCoder).updateQuery, need to implement")
        return query
    }
    func refreshView(callback: @escaping () -> Void) {
        print("In \(self.classForCoder).refreshView, need to implement")
        callback()
    }
    override func completeOperation(models: [RVBaseModel] = [RVBaseModel](), error: RVError?) {
        super.completeOperation(models: models, error: error)
        if let sectionManager = self.sectionManager {
            if front && sectionManager.frontQueryOperationActive { sectionManager.frontQueryOperationActive = false }
            else if !front && sectionManager.backQueryOperationActive { sectionManager.backQueryOperationActive = false }
        }
    }
}
class RVSectionManagerExpandCollapseOperation<T: NSObject>: RVAsyncOperation {
    enum Mode {
        case collapse
        case expand
        case collapseRemove
        case collapseRemoveExpand
    }
    var mode: Mode
    weak var sectionManager: RVSectionManager4<T>?
    init(sectionManager: RVSectionManager4<T>, mode: Mode = .collapse, callback: @escaping RVCallback) {
        self.mode = mode
        self.sectionManager = sectionManager
        super.init(title: "RV", callback: callback, parent: nil)
    }
    override func asyncMain() {
        if self.isCancelled {
            self.completeOperation(error: nil)
            return
        } else {
            if let _ = self.sectionManager {
                
            }
        }
    }
}
