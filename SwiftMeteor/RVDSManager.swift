//
//  RVDSManager.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 12/31/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import UIKit

class RVDSManager {
    var instanceType: String { get { return String(describing: type(of: self)) } }
    var sections = [RVBaseDataSource]()
    weak var scrollView: UIScrollView?
    let animation = UITableViewRowAnimation.automatic
    init(scrollView: UIScrollView? = nil) {
        self.scrollView = scrollView
    }
    func section(datasource :RVBaseDataSource)->Int {
        var index = 0
        for section in sections {
            if section.identifier == datasource.identifier { return index }
            index = index + 1
        }
        return -1
    }
    func addSection(section: RVBaseDataSource) {
        section.scrollView = self.scrollView
        section.manager = self
        section.flushOperations()
        sections.append(section)
        if let tableView = self.scrollView as? UITableView {
            tableView.insertSections(IndexSet(integer: sections.count - 1), with: animation)
        } else if let _ = self.scrollView as? UICollectionView {
            
        } else {
            print("In \(self.instanceType).addSection, invalid scrollView")
        }
    }
    func removeAllSections(callback: @escaping() -> Void) {
        if let tableView = self.scrollView as? UITableView {
            tableView.beginUpdates()
            let indexSet = IndexSet(0..<sections.count)
            sections = [RVBaseDataSource]()
            tableView.deleteSections(indexSet, with: animation)
            tableView.endUpdates()
            callback()
        } else if let _ = self.scrollView as? UICollectionView {
            
        } else {
            callback()
        }
    }
    func item(section: Int, location: Int) -> RVBaseModel? {
        if section < sections.count {
            return sections[section].item(location: location)
        }
        return nil
    }
    func item(indexPath: IndexPath) -> RVBaseModel? {
        if indexPath.section < sections.count {
            return sections[indexPath.section].item(location: indexPath.row)
        }
        return nil
    }
    func forceFrontZone(indexPath: IndexPath) {
        if indexPath.section < sections.count {
            sections[indexPath.section].forceFrontZone(location: 0)
        }
    }
    func numberOfSections(scrollView: UIScrollView?) -> Int {
        if self.scrollView == nil && scrollView == nil { return sections.count }
        if let managerScrollView = self.scrollView {
            if let incoming = scrollView {
                if managerScrollView == incoming {
                    return sections.count
                }
            }
        }
        return 0
    }
    func numberOfItems(section: Int) -> Int {
        if (section >= 0) && (section < sections.count) {
          //  print("In RVDSManager.numberOfSections for section \(section)")
            return sections[section].scrollViewCount
        }
        return 0
    }
    func collapseDatasource(datasource: RVBaseDataSource, callback: @escaping() -> Void) {
        let sectionNumber = section(datasource: datasource)
        if sectionNumber >= 0 {
            if !datasource.collapsed {
                datasource.collapse {
                    callback()
                    return
                }
            } else {
                callback()
                return
            }
        } else {
            callback()
            return
        }
    }
    func expandDatasource(datasource: RVBaseDataSource, callback: @escaping() -> Void) {
        let sectionNumber = section(datasource: datasource)
        if sectionNumber >= 0 {
            if datasource.collapsed {
                datasource.expand {
                    callback()
                    return
                }
            } else {
                callback()
                return
            }

        } else {
            callback()
            return
        }
    }
    func startDatasource(datasource: RVBaseDataSource, query: RVQuery, callback: @escaping(_ error: RVError?) -> Void) {
        let sectionNumber = section(datasource: datasource)
        if sectionNumber >= 0 {
            datasource.start(query: query, callback: { (error) in
                callback(error)
            })
        } else {
            let rvError = RVError(message: "In \(self.instanceType).startDatasource datasource not found")
            callback(rvError)
        }
    }
    func stopAndResetDatasource(datasource: RVBaseDataSource, callback: @escaping(_ error: RVError?)-> Void ){
        let sectionNumber = section(datasource: datasource)
        let completionHandler = callback
        if sectionNumber >= 0 {
            datasource.stop(callback: { (error) in
                if let error = error {
                    error.append(message: "In \(self.instanceType).stopAndResetDatasource got error stopping")
                    completionHandler(error)
                } else {
                    datasource.reset {
                        callback(nil)
                    }
                }
            })
        } else {
            let rvError = RVError(message: "In \(self.instanceType).stopDatasource datasource not found")
            callback(rvError)
        }
    }
    func stopDatasource(datasource: RVBaseDataSource, callback: @escaping(_ error: RVError?)-> Void ){
        let sectionNumber = section(datasource: datasource)
        let completionHandler = callback
        if sectionNumber >= 0 {
            datasource.stop(callback: { (error) in
                completionHandler(error)
            })
        } else {
            let rvError = RVError(message: "In \(self.instanceType).stopDatasource datasource not found")
            callback(rvError)
        }
    }
    
}
