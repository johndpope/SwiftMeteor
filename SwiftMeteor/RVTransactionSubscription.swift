//
//  RVTransactionSubscription.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/1/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//


import UIKit
class RVTransactionSubscription: RVBaseCollectionSubscription8 {
    override var notificationName: Notification.Name { return Notification.Name("TransactionSubscription") }
    init(front: Bool = true, showResponse: Bool = false) {
        super.init(modelType: .transaction, isFront: front, showResponse: showResponse)
      //  super.init(collection: .transaction)
    }
    override func populate(id: String, fields: NSDictionary) -> RVBaseModel {
        let transaction = RVTransaction(id: id , fields: fields)
        print("In \(self.instanceType).populate, have transaction \(transaction.createdAt!) TopParentId: \(String(describing: transaction.topParentId))")
        return transaction
    }
}
