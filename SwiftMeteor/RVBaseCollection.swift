//
//  RVBaseCollection.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 12/15/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import Foundation
import SwiftDDP

class RVBaseCollection: AbstractCollection {
    enum eventType: String {
        case added      = "added"
        case changed    = "changed"
        case removed    = "removed"
    }
    var notificationName: Notification.Name { return Notification.Name("BaseSubscriptionNeedsToBeOverridden") }
    var unsubscribeNotificationName = Notification.Name("RVSubscriptionUnsubscribed")
    static let collectionNameKey = "CollectionNameKey"
    var collection: RVModelType
    var query: RVQuery = RVQuery()
    var instanceType: String { get { return String(describing: type(of: self)) } }
    var elements = [RVBaseModel]()
    var subscriptionID: String? = nil
    var listeners = [String]()
    let MaxOperations = 200
    let queue = RVOperationQueue()
    var _active: Bool = false
    var active: Bool { get { return _active } }
    var showResponse: Bool = false
    var front: Bool = false
    var isFront: Bool { return front }
    var identifier: TimeInterval = Date().timeIntervalSince1970
    var reference: RVBaseModel? = nil
    
    public typealias basicCallback = () -> Void
    init(collection: RVModelType) {
        self.collection = collection
        super.init(name: collection.rawValue)
    }

    func populate(id: String, fields: NSDictionary) -> RVBaseModel { return RVBaseModel(id: id, fields: fields) }
    func addListener(name: String) {
        if let _ = listeners.index(where: {notification in return notification == name}) {
            // do nothing
        } else {
            var newListeners = self.listeners.map { $0 }
            newListeners.append(name)
            self.listeners = newListeners
        }
    }
    func removeListener(name: String) {
        var newListeners = self.listeners.map { $0 }
      //  newListeners.append(name)
       // self.listeners = newListeners
        if let index = newListeners.index(where: {notification in return notification == name}) {
            newListeners.remove(at: index)
            self.listeners = newListeners
        } else {
            // do nothing
        }
    }
    func publish(eventType: eventType, model: RVBaseModel?, id: String) {
        let listeners = self.listeners
        for listener in listeners {
            NotificationCenter.default.post(name: Notification.Name(rawValue: listener), object: model, userInfo: ["eventType": eventType.rawValue, "id": id])
        }
    }
    
    override public func documentWasAdded(_ collection: String, id: String, fields: NSDictionary?) {
       print("\(self.instanceType).documentWasAdded for collection: \(collection), id: \(id)")
        if let fields = fields {
            let document = populate(id: id, fields: fields)
            RVTransactionBroadcast.shared.documentWasAdded(document: document)
            var copy = self.elements.map { $0 }
            copy.append(document)
            self.elements = copy
          //  print("In \(#file) #\(#line).documentWasAdded id: \(id)")
            self.publish(eventType: .changed, model: document, id: id)
        } else {
            print("In \(#file) #\(#line).documentWasAdded fields is nil")
        }
    }

    override public func documentWasChanged(_ collection: String, id: String, fields: NSDictionary?, cleared: [String]?) {
        //print("In \(self.instanceType).documentWasChanged, id: \(id), fields: \(fields)")
        var instance: RVBaseModel? = nil
        let elements = self.elements
        if let index = elements.index(where: {element in return (element.localId == id)}) {
            instance = elements[index]
            instance!.update(fields, cleared: cleared)
        } else {
            print("In \(self.instanceType) #\(#line).documentWasChanged \(id) document doesn't exist")
        }
        self.publish(eventType: .changed, model: instance, id: id)
    }
    override public func documentWasRemoved(_ collection: String, id: String) {
        var copy = elements.map {$0}
        if let index = copy.index(where: {element in return element.localId == id}) {
            copy.remove(at: index)
            self.elements = copy
            self.publish(eventType: .removed, model: nil, id: id)
        }
    }

    deinit {
        print("In \(self.instanceType).deinit. about to call unsubscribe")
        if let id = self.subscriptionID { RVSwiftDDP.sharedInstance.unsubscribe(id: id) }
    }
}
extension RVBaseCollection {
    
    func checkIfSubscribed(instanceType: String) {
        if let type = Meteor.collection(collection.rawValue) {
            if let type = type as? RVBaseCollectionSubscription {
                if let id = type.subscriptionID {
                    print("Warning. In \(instanceType).checkIfSubscribed, Collection of type: \(collection.rawValue) already subscribed, yet attempting to subscribe again \(type) existingSubscriptionID = \(id)")
                }
            }
        }
    }
    func subscribe(query: RVQuery, reference: RVBaseModel?, callback: @escaping() -> Void) -> Void {
        self.reference  = reference
        let _ = self.subscribe(query: query, callback: callback)
    }
    /**
     Sends a subscription request to the server. If a callback is passed, the callback asynchronously
     runs when the client receives a 'ready' message indicating that the initial subset of documents contained
     in the subscription has been sent by the server.
     
     - parameter name:       The name of the subscription.
     - parameter params:     An object containing method arguments, if any.
     - parameter callback:   The closure to be executed when the server sends a 'ready' message.
     */
    func subscribe(query:RVQuery, callback: @escaping () -> ()) -> String {
        checkIfSubscribed(instanceType: "\(self.instanceType)")
      //  print("---------- IN \(self.classForCoder).subscribe(query....")
        self.query = query
        if self.active { print("In \(self.classForCoder).subscribe, subscription was already active") }
        self._active    = true
        let (filters, projection) = query.query()
        self.subscriptionID = RVSwiftDDP.sharedInstance.subscribe(collectionName: collection, params: [filters as AnyObject, projection as AnyObject], callback: callback)
      //  print("---------- IN \(self.classForCoder).subscribe(query, callback) with subscriptionId \(self.subscriptionID!)")
        return self.subscriptionID!
    }
    
    

    /**
     Sends an unsubscribe request to the server using a subscription id. This allows fine-grained control of subscriptions. For example, you can unsubscribe to specific combinations of subscriptions and subscription parameters. If a callback is passed, the callback asynchronously
     runs when the unsubscribe transaction is complete.
     - parameter id: An id string returned from a subscription request
     - parameter callback:   The closure to be executed when the method has been executed
     */
    func unsubscribe(id: String, callback: @escaping() -> Void ) {
        self._active = false
        RVSwiftDDP.sharedInstance.unsubscribe(subscriptionId: id , callback: callback)
    }
    func unsubscribe() {
        if let _  = self.subscriptionID {
            self.queue.cancelAllOperations()
            self.subscriptionID = nil
            self._active = false
            if let id = self.subscriptionID {
                RVSwiftDDP.sharedInstance.unsubscribe(id: id)
            }
        }
    }
    
    func unsubscribe(callback: @escaping ()-> Void) -> Void {
        print("In \(self.classForCoder).unsubscribe for modelType: \(self.collection.rawValue)  Suspect")
        if let id = self.subscriptionID {
            self.queue.cancelAllOperations()
            print("In \(self.classForCoder).unsubscribe with id: \(id)  Suspect")
            if let id = self.subscriptionID {
                self.subscriptionID = nil
                self._active = false
                callback()
                RVSwiftDDP.sharedInstance.unsubscribe(subscriptionId: id, callback: {
                    print("In \(self.classForCoder).unsubscribe. Looking to do callback for \(id) but cauess crash ................")
                    //callback()
                })
                return
            } else {
                callback()
                return
            }
        } else {
            callback()
        }

    }
 
    
}
