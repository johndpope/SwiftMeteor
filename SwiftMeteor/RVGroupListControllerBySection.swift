//
//  RVGroupListControllerBySection.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/10/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit

class RVGroupListControllerBySection: RVGroupListController4 {
    
    override var instanceConfiguration: RVBaseConfiguration4 { return RVTransactionConfiguration4DynamicSections(scrollView: dsScrollView) }
    override func viewDidLoad() {
        self.sectionTest = true
        super.viewDidLoad()
    }
    override func doSectionTest(callback: @escaping(RVError?) -> Void) {
        var (query, error) = self.configuration.mainQuery()
        query = query.duplicate()
        query.addSort(field: .createdAt, order: .ascending)
        query.limit = 3
        if let error = error {
            error.append(message: "In \(self.instanceType).loadMain, got error creating Query")
            callback(error)
        } else {
            self.sectionManager.restartSectionDatasource(query: query, callback: { (datasources, error) in
                if let error = error {
                    error.append(message: "IN \(self.instanceType).doSectionText, have error on restart callback")
                    callback(error)
                    return
                } else {
                    print("In \(self.instanceType).doSectionTest, successful return")
                }
            })
        }
        
    }



    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerCell = view as? RVFirstViewHeaderCell {
            //print("In \(self.classForCoder).willDisplayHeaderView section \(section)")
            if let datasource = self.sectionManager.datasourceInSection(section: section) {
                headerCell.datasource4 = datasource
                
                headerCell.configure(model: datasource.sectionModel)
            }
            headerCell.delegate = self
            //headerCell.configure(model: nil)
            headerCell.transform = tableView.transform
        }
    }
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        /*
        if let tableView = scrollView as? UITableView {
            if tableView == self.dsScrollView {
                if let indexPaths = tableView.indexPathsForVisibleRows {
                    if let first = indexPaths.first {
                      //  configuration4.manager.scrolling(indexPath: first, scrollView: tableView)
                        //  self.manager4.scrolling(indexPath: first, scrollView: tableView)
                    }
                    if let last = indexPaths.last {
                      //  configuration4.manager.scrolling(indexPath: last, scrollView: tableView)
                        //   self.manager4.scrolling(indexPath: last, scrollView: tableView)
                    }
                }
            }
        }
 */
    }
}
