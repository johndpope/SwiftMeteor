//
//  RVBaseSubscription.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/2/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
import UIKit
class RVBaseCollectionSubscription: RVBaseCollection, RVSubscription {
    var modelType: RVModelType { return RVModelType.baseModel }


    init(collection: RVModelType, front: Bool = true, showResponse: Bool = false) {
        super.init(collection: collection)
        self.front = front
        self.showResponse = showResponse

    }
    override func populate(id: String, fields: NSDictionary) -> RVBaseModel {
        let transaction = RVTransaction(id: id , fields: fields)
      //  print("In \(self.instanceType).populate, have transaction \(transaction.createdAt!) TopParentId: \(String(describing: transaction.topParentId))")
        return transaction
    }

    override public func documentWasAdded(_ collection: String, id: String, fields: NSDictionary?) {
        if isSubscriptionCancelled {
            print("In \(self.classForCoder).documentWasAdded, subscriptionCancelled")
            return
        }
        finishUp(collection: collection, id: id, fields: fields, cleared: nil, eventType: .added)
    }
    override public func documentWasChanged(_ collection: String, id: String, fields: NSDictionary?, cleared: [String]?) {
        if isSubscriptionCancelled { return }
        finishUp(collection: collection, id: id, fields: fields, cleared: cleared, eventType: .changed)
    }
    override public func documentWasRemoved(_ collection: String, id: String) {
        if isSubscriptionCancelled { return }
        finishUp(collection: collection, id: id, fields: nil, cleared: nil, eventType: .removed)
    }


    func finishUp(collection: String, id: String, fields: NSDictionary?, cleared: [String]?, eventType: RVEventType) {
    
        if self.subscriptionID != nil {
            if self.collection.rawValue == collection {
                var models = [RVBaseModel]()
                if cleared != nil {
                    print("In \(self.classForCoder).finishUp, clearedArray is not null..... not implemented")
                }
                if let fields = fields {
                    models.append(populate(id: id, fields: fields))
                    
                } else {
                    if eventType == .removed { return }
                    print("In \(self.instanceType) #\(#line).finishUp collection \(collection) EventType:\(eventType) fields is nil, id is \(id) and subID = \(self.subscriptionID ?? "No subscriptionID")")
                    //if eventType == .removed { return }
                }
                if queue.operationCount > self.MaxOperations {
                    print("In \(self.classForCoder).finishUp \(eventType), queCount > MaxOperations. Count is: \(queue.operationCount). Tossing Operation")
                } else {
                   // print("In \(self.classForCoder).finishUp, collection: \(collection) eventType: \(eventType), id: \(id)")
                    queue.addOperation(RVModelSubscriptionBroadcast<RVBaseModel>(subscription: self , models: models, eventType: eventType, id: id))
                }
            } else {
                print("In \(self.classForCoder).finishUp, collectionName sent: \(collection), not equal to collection \(self.collection.rawValue). id: \(id) and subID = \(self.subscriptionID ?? "No subscriptionID")")
            }
        } else {
           // print("In \(self.classForCoder).finishUp for collection: \(collection) got eventType: \(eventType) for id \(id), when subscriptionID id nil")
        }

    }

    

    
}

