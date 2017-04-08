//
//  RVTransactionDatasource44.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/27/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
class RVTransactionDatasource44<T: NSObject>: RVBaseDatasource4<T> {
    override func retrieve(query: RVQuery, callback: @escaping RVCallback) {
            RVTransaction.bulkQuery(query: query) { (models, error) in
                if let error = error {
                    error.append(message: "In \(self.classForCoder).retrieve, got Meteor Error")
                    callback([RVBaseModel](), error)
                } else {
                    //print("In \(self.classForCoder).retrieve have \(models.count) models ----------------")
                    callback(models, nil)
                }
            }
    }
}
