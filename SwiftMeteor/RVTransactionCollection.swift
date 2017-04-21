//
//  RVTransactionCollection.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/4/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
class RVTransactionCollection: RVBaseCollection {
    init() { super.init(collection: .transaction) }
    override func populate(id: String, fields: NSDictionary) -> RVBaseModel {
        let transaction = RVTransaction(id: id , fields: fields)
       print("In \(self.instanceType).populate, have transaction \(transaction.createdAt!) TopParentId: \(String(describing: transaction.topParentId))")
        return transaction
    }
}

