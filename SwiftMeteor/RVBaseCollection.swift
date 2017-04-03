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
    var collection: RVModelType
    var query: RVQuery = RVQuery()
    var instanceType: String { get { return String(describing: type(of: self)) } }
    var elements = [RVBaseModel]()
    var subscriptionID: String? = nil
    var listeners = [String]()
    public typealias basicCallback = () -> Void
    init(collection: RVModelType) {
        if let type = Meteor.collection(collection.rawValue) {
            print("Warning. Collection of type: \(collection.rawValue) already subscribed, yet attempting to subscribe again \(type)")
        }
        self.collection = collection
        super.init(name: collection.rawValue)    }
    /*
    func findRecord(id: String) -> RVBaseModel? {
        let elements = self.elements
        if let index = elements.index(where: {element in return element._id == id}) {
            return elements[index]
        }
        return nil
    }
 */
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
       print("\(self.classForCoder).documentWasAdded for collection: \(collection), id: \(id)")
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
        self.unsubscribeSelf { }
    }
}
extension RVBaseCollection {
    func checkIfSubscribed() {
        if let type = Meteor.collection(collection.rawValue) {
            print("Warning. Collection of type: \(collection.rawValue) already subscribed, yet attempting to subscribe again \(type)")
        }
    }
    /**
    Sends a subscription request to the server.
    
    - parameter name:       The name of the subscription.
    */
    func subscribe() -> String {

        print("In \(self.classForCoder).subscribe()")
        let (filters, projections) = self.query.query()
        self.subscriptionID = Meteor.subscribe(collection.rawValue, params: [filters as AnyObject, projections as AnyObject])
        return self.subscriptionID!
    }
    func subscribe(callback: @escaping()-> Void) -> String {
        print("In \(self.classForCoder).subscribe(callback: @escaping()-> Void")
        let (filters, projections) = self.query.query()
        self.subscriptionID = Meteor.subscribe(collection.rawValue, params: [filters as AnyObject, projections as AnyObject], callback: callback)
        return self.subscriptionID!
    }

    
    /**
     Sends a subscription request to the server.
     
     - parameter name:       The name of the subscription.
     - parameter params:     An object containing method arguments, if any.
     */
    func subscribe(query: RVQuery) -> String {
print("In \(self.classForCoder).unc subscribe(query: RVQuery)")
        self.query = query
        let (filters, projection) = query.query()
        self.subscriptionID = Meteor.subscribe(collection.rawValue, params: [filters as AnyObject, projection as AnyObject])
        return self.subscriptionID!
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
        print("---------- IN \(self.classForCoder).subscribe(query....")
        self.query = query
        let (filters, projection) = query.query()
        self.subscriptionID = Meteor.subscribe(collection.rawValue, params: [filters as AnyObject, projection as AnyObject], callback: callback)
        return self.subscriptionID!
    }
    
    
    /**
     Sends an unsubscribe request to the server. Unsubscibes to all subscriptions with the provided name.
     - parameter name:       The name of the subscription.
     
     */
    func unsubscribeAll(callback: @escaping () -> Void) -> [String] {
        self.subscriptionID = nil
        print("In \(self.classForCoder).unsubscribe ")
        return Meteor.unsubscribe(collection.rawValue, callback: callback)
    }
    
    /**
     Sends an unsubscribe request to the server using a subscription id. This allows fine-grained control of subscriptions. For example, you can unsubscribe to specific combinations of subscriptions and subscription parameters.
     - parameter id: An id string returned from a subscription request
     */
    func unsubscribeSelf(callback: @escaping () -> Void)  {
        print("In \(self.classForCoder).unsubscribeSelf")
        if let id = self.subscriptionID {
            self.subscriptionID = nil
            
             print("In \(self.classForCoder).unsubscribeSelf subscriptionId \(id)")
            return Meteor.unsubscribe(withId: id , callback: callback)
        } else {
            callback()
        }
    }
    /**
     Sends an unsubscribe request to the server using a subscription id. This allows fine-grained control of subscriptions. For example, you can unsubscribe to specific combinations of subscriptions and subscription parameters. If a callback is passed, the callback asynchronously
     runs when the unsubscribe transaction is complete.
     - parameter id: An id string returned from a subscription request
     - parameter callback:   The closure to be executed when the method has been executed
     */
    func unsubscribe(id: String, callback: @escaping() -> Void ) {
        return Meteor.unsubscribe(withId: id, callback: callback)
    }
    
}
