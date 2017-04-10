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
    func removeAllSections(callback: RVCallback<S>) {
        print("In \(self.classForCoder).removeAllSections Needs to be implemented")
    }
}
