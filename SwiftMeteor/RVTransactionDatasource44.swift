//
//  RVTransactionDatasource44.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/27/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
class RVTransactionDatasource44<T: NSObject>: RVBaseDatasource4<T> {
    override func retrieve(query: RVQuery, callback: @escaping RVCallback<T>) {
            RVTransaction.bulkQuery(query: query) { (models, error) in
                if let error = error {
                    error.append(message: "In \(self.classForCoder).retrieve, got Meteor Error")
                    callback([T](), error)
                } else {
                    //print("In \(self.classForCoder).retrieve have \(models.count) models ----------------")
                    if let models = models as? [T] {
                        callback(models, nil)
                    } else {
                        let error = RVError(message: "In \(self.classForCoder).retrieve, failed to cast to type \(type(of: T.self))")
                        callback([T](), error)
                    }
                }
            }
    }
}
