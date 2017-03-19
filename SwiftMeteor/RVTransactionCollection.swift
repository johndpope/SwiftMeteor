//
//  RVTransactionCollection.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/4/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
class RVTransactionCollection: RVBaseCollection {
    init() {

        super.init(collection: .transaction)
        print("IN \(self.classForCoder).init ...........")
    }
    override func populate(id: String, fields: NSDictionary) -> RVBaseModel {
        let transaction = RVTransaction(id: id , fields: fields)
       // print("In \(self.instanceType).populate, have transaction \(transaction.createdAt!) TopParentId: \(transaction.topParentId)")
        return transaction
    }
}
