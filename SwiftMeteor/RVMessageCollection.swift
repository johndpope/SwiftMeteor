//
//  RVMessageCollection.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/5/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
class RVMessageCollection2: RVBaseCollection {
    init() {
        super.init(name: .Message)
    }
    override func populate(id: String, fields: NSDictionary) -> RVBaseModel {
        let transaction = RVMessage(id: id , fields: fields)
        print("In \(self.instanceType).populate, have message \(transaction.createdAt!)")
        return transaction
    }
}
