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
    
    /*
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
*/



}
