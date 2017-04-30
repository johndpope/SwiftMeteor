//
//  RVCollectionSubscription.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/30/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
import SwiftDDP


class RVCollectionSubscription<M: RVBaseModel>: RVSubbaseModel, RVSubscription {
    var notificationName: Notification.Name {
        return Notification.Name("\(collection.rawValue)Subscription")
    }//{ return Notification.Name("RVBaseaSubscriptionName.NEEDTOREPLACE") }
    var unsubscribeNotificationName: Notification.Name  { return Notification.Name("RVBaseaUnsubscribeName.NEEDTOREPLACE") }
    open var subscriptionID: String? = nil
    func populate(id: String, fields: NSDictionary) -> M { return M(id: id, fields: fields) }
    let MaxOperations = 200
    var collection: RVModelType { return M.collectionType() }
    var modelType: RVModelType { return collection }
    let queue = RVOperationQueue(title: "RVBaseColelctionSubscription8", maxSize: 100)
    var instanceType: String { get { return String(describing: type(of: self)) } }
    var isSubscriptionCancelled: Bool {
        return false
    }
    var query: RVQuery = RVQuery()
    fileprivate var _active: Bool = false
    var active: Bool { return _active }
    var showResponse: Bool = false
    // var front
    var isFront: Bool = false
    var identifier: TimeInterval = Date().timeIntervalSince1970
    var reference: RVBaseModel? = nil
    var _ignore: Bool = true
    var ignore: Bool {
        get { return RVSwiftDDP.sharedInstance.ignoreSubscriptions || _ignore }
        set {
            _ignore = newValue
            if newValue {
                NotificationCenter.default.addObserver(self, selector: #selector(RVCollectionSubscription.ignoreIncoming(notification:)), name: RVNotification.ignoreSubscription, object: nil)
            } else {
                NotificationCenter.default.removeObserver(self , name: RVNotification.ignoreSubscription, object: nil)
            }
        }
    }
    public init(isFront: Bool = false, showResponse: Bool = false) {
        self.isFront        = isFront
        self.showResponse   = showResponse
        super.init(id: "BadId", fields: NSDictionary())
        Meteor.collections[collection.rawValue] = self
        /*
        if let existing: MeteorCollectionType = RVSwiftDDP.sharedInstance.existingMeteorSubscription(modelType: self.modelType) {
            if let _ = existing as? RVBaseCollectionSubscription8 {
                print("In \(self.classForCoder).init unsubscring \(modelType.rawValue) because got new subscription")
                /*
                self.unsubscribe(subscription: existing, callback: {
                    RVSwiftDDP.sharedInstance.addSubscription(subscription: self)
                })
 */
                return
            } else {
                print("In \(self.classForCoder).init have a MeteorCollectionpType that is not a RVBaseCollactionSubscription8")
            }
        }
        RVSwiftDDP.sharedInstance.addSubscription(subscription: self)
 */
    }
    
    required init(id: String, fields: NSDictionary?) {
        fatalError("init(id:fields:) has not been implemented")
    }
    func ignoreIncoming(notification: Notification) { self.ignore = true }


    // baseCallback
//    open var modelType: RVModelType
//    open var name:String { return modelType.rawValue }
    open let client = Meteor.client
    
    func unsubscribe(callback: @escaping ()-> Void) -> Void {
        self.unsubscribe(subscription: self, callback: callback)
    }
    func unsubscribe(subscription: RVCollectionSubscription<M>, callback: @escaping () -> Void) {
        subscription._active        = false
        subscription.ignore         = true
        subscription.queue.cancelAllOperations()
        if let id = self.subscriptionID {
            subscription.subscriptionID = nil
            callback()
            RVSwiftDDP.sharedInstance.unsubscribe(subscriptionId: id, callback: {
                //  callback()
            })
            return
        } else {
            callback()
        }
    }
    func unsubscribe() {
        if let _ = self.subscriptionID {
            self.queue.cancelAllOperations()
            RVSwiftDDP.sharedInstance.unsubscribe(id: self.subscriptionID)
            self.subscriptionID = nil
            self._active        = false
            self.ignore         = true
        }
        
    }
    
    
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        if let id = self.subscriptionID {
            //  let _ = Meteor.collections.removeValue(forKey: self.modelType.rawValue)
            RVSwiftDDP.sharedInstance.unsubscribe(id: id)
        }
        //if let existing = RVSwiftDDP.sharedInstance.removeSubscription(subscription: self) { existing.unsubscribe() }
    }
    
    /**
     Sends a subscription request to the server. If a callback is passed, the callback asynchronously
     runs when the client receives a 'ready' message indicating that the initial subset of documents contained
     in the subscription has been sent by the server.
     
     - parameter name:       The name of the subscription.
     - parameter params:     An object containing method arguments, if any.
     - parameter callback:   The closure to be executed when the server sends a 'ready' message.
     */
    func subscribe(query: RVQuery, reference: RVBaseModel?, callback: @escaping() -> Void) -> Void {
        self.query = query
        self.reference  = reference
        self.subscribe(query: query, callback: callback)
    }
    fileprivate func subscribe(query:RVQuery, callback: @escaping () -> Void) {
        if self.active { print("In \(self.classForCoder).subscribe, subscription was already active") }
        self._active    = true
        let (filters, projections) = self.query.query()
        self.ignore = false
        RVSwiftDDP.sharedInstance.subscribe(subscription: self , params: [filters as AnyObject , projections as AnyObject ], callback: callback)
    }

    
    
    
    
}

extension RVCollectionSubscription: MeteorCollectionType {
    /**
     Invoked when a document has been sent from the server.
     
     - parameter collection:     the string name of the collection to which the document belongs
     - parameter id:             the string unique id that identifies the document on the server
     - parameter fields:         an optional NSDictionary with the documents properties
     */
    
    open func documentWasAdded(_ collection: String, id: String, fields: NSDictionary?) {
        if isSubscriptionCancelled {
            print("In \(self.classForCoder).documentWasAdded, subscriptionCancelled")
            return
        }
        finishUp(collection: collection, id: id, fields: fields, cleared: nil, eventType: .added)
    }
    
    /**
     Invoked when a document has been changed on the server.
     
     - parameter collection:     the string name of the collection to which the document belongs
     - parameter id:             the string unique id that identifies the document on the server
     - parameter fields:         an optional NSDictionary with the documents properties
     - parameter cleared:                    Optional array of strings (field names to delete)
     */
    
    open func documentWasChanged(_ collection:String, id:String, fields:NSDictionary?, cleared:[String]?) {
        if isSubscriptionCancelled { return }
        finishUp(collection: collection, id: id, fields: fields, cleared: cleared, eventType: .changed)
    }
    
    /**
     Invoked when a document has been removed on the server.
     
     - parameter collection:     the string name of the collection to which the document belongs
     - parameter id:             the string unique id that identifies the document on the server
     */
    
    open func documentWasRemoved(_ collection:String, id:String) {
        if isSubscriptionCancelled { return }
        finishUp(collection: collection, id: id, fields: nil, cleared: nil, eventType: .removed)
    }
    
    func finishUp(collection: String, id: String, fields: NSDictionary?, cleared: [String]?, eventType: RVEventType) {
        
        if self.subscriptionID != nil {
            if self.collection.rawValue == collection {
               // print("In \(self.classForCoder).finishUp, have Collection \(collection) \(id)")
                var models = [M]()
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
                    queue.addOperation(RVModelSubscriptionBroadcast<M>(subscription: self , models: models, eventType: eventType, id: id))
                }
            } else {
                print("In \(self.classForCoder).finishUp, collectionName sent: \(collection), not equal to collection \(self.collection.rawValue). id: \(id) and subID = \(self.subscriptionID ?? "No subscriptionID")")
            }
        } else {
            // print("In \(self.classForCoder).finishUp for collection: \(collection) got eventType: \(eventType) for id \(id), when subscriptionID id nil")
        }
        
    }
}

class RVModelSubscriptionBroadcast<T: NSObject>: RVAsyncOperation<T> {
    var models:         [T]
    var eventType:      RVEventType
    var subscription:   RVSubscription
    var id:             String
    var emptyModels =    [T]()
    init(subscription: RVSubscription, models: [T], eventType: RVEventType, id: String) {
        self.models = models
        self.eventType = eventType
        self.subscription = subscription
        self.id = id
        super.init(title: "RVModelSubscriptionBroad for \(self.subscription.collection.rawValue), event: \(self.eventType)", callback: {(models: [T], error: RVError?) in } )
    }
    override func asyncMain() {
        if !self.isCancelled {
            DispatchQueue.main.async {
                if self.isCancelled {
                    // print("In \(self.classForCoder).asyncMain, line: \(#line), about to do dealWithCallback")
                    self.dealWithCallback()
                    //      if let callback = self.callback { callback(self.emptyModels, nil) } // CALLBACK TO BE REMOVED
                    self.completeOperation()
                    return
                }
                if self.subscription.showResponse { self.showAnAlert(alertType: 0) }
                let payload = RVPayload<T>(subscription: self.subscription, eventType: self.eventType, models: self.models, operation: self)
                //      print("In \(self.classForCoder).asyncMain posting notification \(self.subscription.notificationName) with itemId \(self.id)")
                NotificationCenter.default.post(name: self.subscription.notificationName, object: self , userInfo: [RVPayload.payloadInfoKey: payload])
                //  print("In \(self.classForCoder).asyncMain, line: \(#line), about to do dealWithCallback")
                self.dealWithCallback()
                //  if let callback = self.callback { callback(self.emptyModels, nil) } // CALLBACK TO BE REMOVED
                self.completeOperation()
            }
            return
        } else {
            // print("In \(self.classForCoder).asyncMain, line: \(#line), about to do dealWithCallback")
            self.dealWithCallback()
            // if let callback = self.callback { callback(self.emptyModels, nil) } // CALLBACK TO BE REMOVED
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
        if let model = self.models.first as? RVBaseModel {
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
                print("Response is: \(response ?? " no response")")
                self.completeOperation()
            })
        } else if index == 3 {
            UIAlertController.showTextEntryDialog(withTitle: title, andMessage: message, andPlaceHolder: "Enter something", configuration: { (textField) in
                if let _ = textField {
                    print("Have textField")
                }
            }, from: controller, completionHandler: { (response) in
                print("Response is: \(response ?? " no response")")
                self.completeOperation()
            })
        }
    }
}
