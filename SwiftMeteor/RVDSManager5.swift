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
    func toggle(datasource: RVBaseDatasource4<S>, callback: @escaping RVCallback<S>) {
        // print("In \(self.instanceType).toggle -------------------------------------- ")
        if self.sectionIndex(datasource: datasource) < 0 {
            let error = RVError(message: "In \(self.instanceType).toggle, datasource is not installed as a section \(datasource)")
            callback([S](), error)
            return
        } else {
            print("In \(self.instanceType).toggle, needs to be implemented")
        }
    }
    func appendSections(datasources: [RVBaseDatasource4<S>], sectionTypesToRemove: [RVBaseDatasource4<S>.DatasourceType] = Array<RVBaseDatasource4<S>.DatasourceType>(), callback: @escaping RVCallback<S>) {
        print("In \(self.instanceType).appendSections, Needs to be implemented ")
        
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
}
