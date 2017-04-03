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
    override var notificationName: Notification.Name { return Notification.Name("RVBaseaSubscriptionName.NEEDTOREPLACE") }
    let MaxOperations = 200
    let queue = RVOperationQueue()
    init(front: Bool = true, showResponse: Bool = false) {
        self.front = front
        self.showResponse = showResponse
        super.init(collection: .transaction)
    }
    override func populate(id: String, fields: NSDictionary) -> RVBaseModel {
        let transaction = RVTransaction(id: id , fields: fields)
        // print("In \(self.instanceType).populate, have transaction \(transaction.createdAt!) TopParentId: \(transaction.topParentId)")
        return transaction
    }
    override public func documentWasAdded(_ collection: String, id: String, fields: NSDictionary?) {
        finishUp(collection: collection, id: id, fields: fields, cleared: nil, eventType: .added)
    }
    override public func documentWasChanged(_ collection: String, id: String, fields: NSDictionary?, cleared: [String]?) {
        finishUp(collection: collection, id: id, fields: fields, cleared: cleared, eventType: .changed)
    }
    override public func documentWasRemoved(_ collection: String, id: String) {
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
                    print("In \(self.instanceType) #\(#line).finishUp collection \(collection) EventType:\(eventType) fields is nil, id is \(id) and subID = \(self.subscriptionID)")
                    if eventType == .removed { return }
                }
                if queue.operationCount > self.MaxOperations {
                    print("In \(self.classForCoder).finishUp \(eventType), queCount > MaxOperations. Count is: \(queue.operationCount). Tossing Operation")
                } else {
                    print("In \(self.classForCoder).finishUp, collection: \(collection) eventType: \(eventType), id: \(id)")
                    queue.addOperation(RVModelSubscriptionBroadcast(subscription: self , models: models, eventType: eventType, id: id))
                }
            } else {
                print("In \(self.classForCoder).finishUp, collectionName sent: \(collection), not equal to collection \(self.collection.rawValue). id: \(id) and subID = \(self.subscriptionID)")
            }
        } else {
            print("In \(self.classForCoder).finishUp for collection: \(collection) got eventType: \(eventType) for id \(id), when subscriptionID id nil")
        }

    }
    fileprivate var _active: Bool = false
    var active: Bool { get { return _active } }
    var showResponse: Bool = false
    fileprivate var front: Bool = false
    var isFront: Bool { return front }
    var identifier: TimeInterval = Date().timeIntervalSince1970
    var reference: RVBaseModel? = nil
    
    func subscribe(query: RVQuery, reference: RVBaseModel?, callback: @escaping() -> Void) -> Void {
        print("In \(self.classForCoder).subscribe ..........")
        if self.active { print("In \(self.classForCoder).subscribe, subscription was already active") }
        self._active    = true
        self.reference  = reference
        let _ = self.subscribe(query: query, callback: callback)
    }
    func unsubscribe(callback: @escaping ()-> Void) -> Void {
        self.queue.cancelAllOperations()
        self.unsubscribeSelf {
            self._active = false
            callback()
        }
    }
    
}
class RVModelSubscriptionBroadcast: RVAsyncOperation {
    var models: [RVBaseModel]
    var eventType: RVEventType
    var subscription: RVSubscription
    var id: String
    init(subscription: RVSubscription, models: [RVBaseModel], eventType: RVEventType, id: String) {
        self.models = models
        self.eventType = eventType
        self.subscription = subscription
        self.id = id
        super.init(title: "RVModelSubscriptionBroad for \(self.subscription.collection.rawValue), event: \(self.eventType)")
    }
    override func asyncMain() {
        if !self.isCancelled {
            DispatchQueue.main.async {
                if self.isCancelled {
                    self.completeOperation()
                    return
                }
                if self.subscription.showResponse { self.showAnAlert(alertType: 0) }
                let payload = RVPayload(subscription: self.subscription, eventType: self.eventType, models: self.models, operation: self)
                print("In \(self.classForCoder).asyncMain posting notification \(self.subscription.notificationName) with id \(self.id)")
                NotificationCenter.default.post(name: self.subscription.notificationName, object: self , userInfo: [RVPayload.payloadInfoKey: payload])
                DispatchQueue.main.async {
                    self.completeOperation()
                }
            }
            return
        } else {
            self.completeOperation()
        }
    }
    func showAnAlert(alertType: Int) {
        if !subscription.showResponse { return }
        let index = alertType <= 3 ? alertType : 0
        let controller = UIViewController.top()
        var title = "Nothing"
        var messageTitle = "Nothing"
        var createdAt = "nothing"
        if let model = self.models.first {
            title = "\(model.modelType.rawValue)"
            messageTitle = model.title == nil ? "No Title" : model.title!
            createdAt = model.createdAt == nil ? "No created at" : (model.createdAt!).description
        }
        let message = "\(messageTitle), \(createdAt)"
        let actions = ["OK", "Jump", "Other"]
        if index == 0 {
            UIAlertController.showAlert(withTitle: title , andMessage: message, from: controller)
            completeOperation()
        } else if index == 1 {
            UIAlertController.showDialog(withTitle: title, andMessage: message, from: controller, andActions: actions, completionHandler: { (index) in
                if index <  actions.count {
                    print("Action: \(actions[index])")
                }
                self.completeOperation()
            })
        } else if index == 2 {
            UIAlertController.showTextEntryDialog(withTitle: title, andMessage: message, andPlaceHolder: "Enter something", from: controller, completionHandler: { (response) in
                print("Response is: \(response)")
                self.completeOperation()
            })
        } else if index == 3 {
            UIAlertController.showTextEntryDialog(withTitle: title, andMessage: message, andPlaceHolder: "Enter something", configuration: { (textField) in
                if let _ = textField {
                    print("Have textField")
                }
            }, from: controller, completionHandler: { (response) in
                print("Response is: \(response)")
                self.completeOperation()
            })
        }
    }
}
