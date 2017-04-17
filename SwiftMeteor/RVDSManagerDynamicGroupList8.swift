//
//  RVDSManagerDynamicGroupList8.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/17/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
class RVDSManagerDynamicGroupList8<S: NSObject>: RVDSManager8<S> {
    override func retrieveSectionModels(query: RVQuery, callback: @escaping ([S], RVError?) -> Void) {
        RVTransaction.bulkQuery(query: query) { (models, error) in
            if let error = error {
                error.append(message: "In \(self.classForCoder).retrieve, got Meteor Error")
                callback([S](), error)
            } else {
                //print("In \(self.classForCoder).retrieve have \(models.count) models ----------------")
                if let models = models as? [S] {
                    // print("In \(self.classForCoder).retrieveSectionModels, have \(models.count)........")
                    callback(models, nil)
                } else {
                    let error = RVError(message: "In \(self.classForCoder).retrieve, failed to cast to type \(type(of: S.self))")
                    callback([S](), error)
                }
            }
        }
    }
    /* Datasource for Rows nested in a Section-Based list */
    override func sectionDatasourceInstance(datasourceType: RVDatasourceType, maxSize: Int) -> RVBaseDatasource4<S> {
        let datasource = RVTransactionDatasource44<S>(manager: self, datasourceType: datasourceType, maxSize: maxSize)
        // datasource.subscription = RVTransactionSubscription(front: true, showResponse: false)
        return datasource
    }
    /* Query for Rows nested in a Section-Based list */
    override var queryForDatasourceInstance: (RVQuery, RVError?) {
        print("In \(self.classForCoder).queryForDadtasourceInstance")
        let (query, error) = RVTransaction.baseQuery
        query.addSort(field: .createdAt, order: .descending)
        query.addAnd(term: .createdAt, value: Date() as AnyObject, comparison: .lte)
        return (query, error)
    }
    
}
