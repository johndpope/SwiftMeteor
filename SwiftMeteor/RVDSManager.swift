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
    weak var scrollView: UIScrollView!
    let animation = UITableViewRowAnimation.automatic
    init(scrollView: UIScrollView) {
        self.scrollView = scrollView
    }
    func section(datasource :RVBaseDataSource)->Int {
        var index = 0
        for section in sections {
            if section.identifier == datasource.identifier { return index }
            index = index + 1
        }
        return 0
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
    func numberOfSections() -> Int {
        return sections.count
    }
    func numberOfItems(section: Int) -> Int {
        if (section >= 0) && (section < sections.count) {
          //  print("In RVDSManager.numberOfSections for section \(section)")
            return sections[section].scrollViewCount
        }
        return 0
    }
    
}
