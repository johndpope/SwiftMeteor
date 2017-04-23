//
//  RVTransactionSubscription.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/1/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//


import UIKit
class RVTransactionSubscription8: RVBaseCollectionSubscription8 {
    init(front: Bool = true, showResponse: Bool = false) {
        super.init(modelType: .transaction, isFront: front, showResponse: showResponse)
        { (id, fields) -> RVBaseModel in
            return RVTransaction(id: id , fields: fields)
        }
    }

}
