//
//  RVDSManager.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 12/31/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import Foundation

class RVDSManager {
    var sections = [RVBaseDataSource]()
    func section(datasource :RVBaseDataSource)->Int {
        var index = 0
        for section in sections {
            if section.identifier == datasource.identifier { return index }
            index = index + 1
        }
        return 0
    }
    func addSection(section: RVBaseDataSource) {
        sections.append(section)
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
