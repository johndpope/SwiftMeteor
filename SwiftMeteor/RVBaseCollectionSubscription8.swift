//
//  RVBaseCollectionSubscription8.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/15/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
import SwiftDDP

enum RVSubscriptionEventType: String {
    case added      = "added"
    case changed    = "changed"
    case removed    = "removed"
}
class RVBaseCollectionSubscription8: NSObject, MeteorCollectionType, RVSubscription {

    fileprivate var _active: Bool = false
    var active: Bool { return _active }
    var collection: RVModelType { return self.modelType }
    var identifier: TimeInterval = Date().timeIntervalSince1970
    var reference: RVBaseModel? = nil
    var instanceType: String { get { return String(describing: type(of: self)) } }
    open var subscriptionID: String? = nil
    open var modelType: RVModelType
    open var name:String { return modelType.rawValue }
    open let client = Meteor.client
    var isFront: Bool = false
    var ignore: Bool = true {
        didSet {
            if ignore {
                NotificationCenter.default.addObserver(self, selector: #selector(RVBaseCollectionSubscription8.ignoreIncoming(notification:)), name: RVNotification.ignoreSubscription, object: nil)
            } else {
                NotificationCenter.default.removeObserver(self , name: RVNotification.ignoreSubscription, object: nil)
            }
            
        }
    }
    func ignoreIncoming(notification: Notification) {
        self.ignore = true
    }
    var showResponse: Bool = false
    var notificationName: Notification.Name { return Notification.Name("RVBaseaSubscriptionName.NEEDTOREPLACE") }
    var unsubscribeNotificationName: Notification.Name  { return Notification.Name("RVBaseaUnsubscribeName.NEEDTOREPLACE") }
    let MaxOperations = 200
    let queue = RVOperationQueue()
    static let collectionNameKey = "CollectionNameKey"
    var query: RVQuery = RVQuery()
    
    func populate(id: String, fields: NSDictionary) -> RVBaseModel { return RVBaseModel(id: id, fields: fields) }
    var isSubscriptionCancelled: Bool {
        if let test = RVSwiftDDP.sharedInstance.subscriptionsCancelled[self.collection] {
            return test
        }
        return false
    }
    public init(modelType: RVModelType, isFront: Bool = false, showResponse: Bool = false) {
        self.modelType      = modelType
        self.isFront        = isFront
        self.showResponse   = showResponse
        super.init()
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
    }
    func unsubscribe(callback: @escaping ()-> Void) -> Void {
        self.unsubscribe(subscription: self, callback: callback)
    }
    func unsubscribe(subscription: RVBaseCollectionSubscription8, callback: @escaping () -> Void) {
        subscription._active        = false
        if let id = self.subscriptionID {
            subscription.subscriptionID = nil
            RVSwiftDDP.sharedInstance.unsubscribe(subscriptionId: id , callback: callback)
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
        }

    }
    

    
    
    deinit {
        if let existing = RVSwiftDDP.sharedInstance.removeSubscription(subscription: self) { existing.unsubscribe() }
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
        print("In \(self.classForCoder).subscribe need to implement")
        //   print("In \(self.classForCoder).subscribe ..........")
        self.query = query
        if self.active { print("In \(self.classForCoder).subscribe, subscription was already active") }
        self._active    = true
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
    
    open func documentWasChanged(_ collection:String, id:String, fields:NSDictionary?, cleared:[String]?) {}
    
    /**
     Invoked when a document has been removed on the server.
     
     - parameter collection:     the string name of the collection to which the document belongs
     - parameter id:             the string unique id that identifies the document on the server
     */
    
    open func documentWasRemoved(_ collection:String, id:String) {}
    
    func finishUp(collection: String, id: String, fields: NSDictionary?, cleared: [String]?, eventType: RVEventType) {
        if self.subscriptionID != nil {
            if self.modelType.rawValue == collection {
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
                    self.callback(self.emptyModels, nil)
                    self.completeOperation()
                    return
                }
                if self.subscription.showResponse { self.showAnAlert(alertType: 0) }
                let payload = RVPayload(subscription: self.subscription, eventType: self.eventType, models: self.models, operation: self)
                //print("In \(self.classForCoder).asyncMain posting notification \(self.subscription.notificationName) with itemId \(self.id)")
                NotificationCenter.default.post(name: self.subscription.notificationName, object: self , userInfo: [RVPayload.payloadInfoKey: payload])
                self.callback(self.emptyModels, nil)
                self.completeOperation()
            }
            return
        } else {
            self.callback(self.emptyModels, nil)
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
