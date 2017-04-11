//
//  RVDSManager5Transaction.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/10/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation

class RVDSManager5Transaction<S: NSObject>: RVDSManager5<S> {

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
}
