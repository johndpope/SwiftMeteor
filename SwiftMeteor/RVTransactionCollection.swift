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
        super.init(name: .transaction, meteorMethod: .transactionBulkQuery)
    }
    override func populate(id: String, fields: NSDictionary) -> RVBaseModel {
        return RVTransaction(id: id , fields: fields)
    }
}
