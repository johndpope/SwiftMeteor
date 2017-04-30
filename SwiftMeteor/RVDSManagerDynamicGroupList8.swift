//
//  RVDSManagerDynamicGroupList8.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/17/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
class RVDSManagerDynamicGroupList8<S: RVSubbaseModel>: RVDSManager8<S> {
    override func retrieveSectionModels(query: RVQuery, callback: @escaping ([S], RVError?) -> Void) {
        RVGroup.bulkQuery(query: query) { (models, error) in
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
    /*
    /* Datasource for Rows nested in a Section-Based list */
    override func sectionDatasourceInstance(datasourceType: RVDatasourceType, maxSize: Int) -> RVBaseDatasource4<S> {
        let datasource = RVBaseDatasource8<S>(manager: self, datasourceType: datasourceType, maxSize: maxSize)
        // datasource.subscription = RVTransactionSubscription(front: true, showResponse: false)
        return datasource
    }
 */
    /* Query for Rows nested in a Section-Based list */
    override func queryForDatasourceInstance(model: S?) -> (RVQuery, RVError?) {
        //print("In \(self.classForCoder).queryForDatasourceInstance")
        let (query, error) = RVGroup.baseQuery
        if let error = error {
            return (query, error)
        } else if let model = model as? RVBaseModel {
            if let id = model.localId {
                query.addSort(field: .createdAt, order: .descending)
                query.addAnd(term: .createdAt, value: Date() as AnyObject, comparison: .lte)
                query.addAnd(term: .parentId, value: id as AnyObject, comparison: .eq)
                return (query, error)
            } else {
                let error = RVError(message: "In \(self.classForCoder).queryForDatasourceInstance, no sectionModel Id")
                return (query, error)
            }
        } else {
            let error = RVError(message: "In \(self.classForCoder).queryForDatasourceInstance, no sectionModel")
            return (query, error)
        }

    }
    
}
