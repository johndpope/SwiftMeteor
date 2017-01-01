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
        case added = "added"
        case changed = "changed"
        case removed = "removed"
    }
    var collectionName: RVModelType
    var meteorMethod: RVMeteorMethods
    var query: RVQuery = RVQuery()
    var instanceType: String { get { return String(describing: type(of: self)) } }
    var elements = [RVBaseModel]()
    var subscriptionID: String? = nil
    var listeners = [String]()

    init(name: RVModelType, meteorMethod: RVMeteorMethods) {
        self.collectionName = name
        self.meteorMethod = meteorMethod
        super.init(name: name.rawValue)
    }
    func findRecord(id: String) -> RVBaseModel? {
        let elements = self.elements
        if let index = elements.index(where: {element in return element._id == id}) {
            return elements[index]
        }
        return nil
    }
    func populate(id: String, fields: NSDictionary) -> RVBaseModel {
        return RVBaseModel(id: id, fields: fields)
    }
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
        newListeners.append(name)
        self.listeners = newListeners
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
        print("RBVBaseCollectio. In document was added")
        if let fields = fields {
            let document = populate(id: id, fields: fields)
            var copy = self.elements.map { $0 }
            copy.append(document)
            self.elements = copy
            print("In \(#file) #\(#line).documentWasAdded id: \(id)")
            self.publish(eventType: .changed, model: document, id: id)
        } else {
            print("In \(#file) #\(#line).documentWasAdded fields is nil")
        }
    }
    override public func documentWasChanged(_ collection: String, id: String, fields: NSDictionary?, cleared: [String]?) {
        //print("In \(self.instanceType).documentWasChanged, id: \(id), fields: \(fields)")
        var instance: RVBaseModel? = nil
        let elements = self.elements
        if let index = elements.index(where: {element in return element._id == id}) {
            instance = elements[index]
            instance!.update(fields, cleared: cleared)
        } else {
            print("In \(self.instanceType) #\(#line).documentWasChanged \(id) document doesn't exist")
        }
        self.publish(eventType: .changed, model: instance, id: id)
    }
    override public func documentWasRemoved(_ collection: String, id: String) {
        var copy = elements.map {$0}
        if let index = copy.index(where: {element in return element._id == id}) {
            copy.remove(at: index)
            self.elements = copy
            self.publish(eventType: .removed, model: nil, id: id)
        }
    }
}
extension RVBaseCollection {
    /**
    Sends a subscription request to the server.
    
    - parameter name:       The name of the subscription.
    */
    func subscribe() -> String {
        print("In \(self.instanceType).subscripe to \(meteorMethod.rawValue)")
        let (filters, projections) = self.query.query()
        self.subscriptionID = Meteor.subscribe(meteorMethod.rawValue, params: [filters as AnyObject, projections as AnyObject])
        return self.subscriptionID!
    }
    
    /**
     Sends a subscription request to the server.
     
     - parameter name:       The name of the subscription.
     - parameter params:     An object containing method arguments, if any.
     */
    func subscribe(subscription: RVMeteorMethods, query: RVQuery) -> String {
        self.meteorMethod = subscription
        self.query = query
        let (filters, projection) = query.query()
        self.subscriptionID = Meteor.subscribe(subscription.rawValue, params: [filters as AnyObject, projection as AnyObject])
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
    func subscribe(subscription: RVMeteorMethods, query:RVQuery, callback: DDPCallback?) -> String {
        self.meteorMethod = subscription
        self.query = query
        let (filters, projection) = query.query()
        self.subscriptionID = Meteor.subscribe(subscription.rawValue, params: [filters as AnyObject, projection as AnyObject], callback: callback)
        return self.subscriptionID!
    }
    
    
    /**
     Sends an unsubscribe request to the server. Unsubscibes to all subscriptions with the provided name.
     - parameter name:       The name of the subscription.
     
     */
    func unsubscribe() -> [String] {
        self.subscriptionID = nil
        return Meteor.unsubscribe(meteorMethod.rawValue)
    }
    
    /**
     Sends an unsubscribe request to the server using a subscription id. This allows fine-grained control of subscriptions. For example, you can unsubscribe to specific combinations of subscriptions and subscription parameters.
     - parameter id: An id string returned from a subscription request
     */
    func unsubscribeViaID() {
        if let id = self.subscriptionID {
            Meteor.unsubscribe(withId: id)
            self.subscriptionID = nil
        }
    }
    
    /**
     Sends an unsubscribe request to the server using a subscription id. This allows fine-grained control of subscriptions. For example, you can unsubscribe to specific combinations of subscriptions and subscription parameters. If a callback is passed, the callback asynchronously
     runs when the unsubscribe transaction is complete.
     - parameter id: An id string returned from a subscription request
     - parameter callback:   The closure to be executed when the method has been executed
     */
    func unsubscribe(callback: DDPCallback?) {
        if let id = self.subscriptionID {
            self.subscriptionID = nil
            return Meteor.unsubscribe(withId: id, callback: callback)
        } else {
            if let callback = callback {
                callback()
            }
        }
        
    }
}
