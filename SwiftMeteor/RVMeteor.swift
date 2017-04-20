//
//  RVMeteor.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/19/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
import SwiftDDP

/*
class RVMeteor {
    var instanceType: String { get { return String(describing: type(of: self)) } }
    static let shared: RVMeteor = { return RVMeteor()}()
    var subscriptionsByModelType: [RVModelType: [RVBaseCollectionSubscription8]] = [RVModelType: [ RVBaseCollectionSubscription8]]()
    var subscriptions = [String : RVBaseCollectionSubscription]()
    init() {}

    /**
     Connect to a Meteor server and resume a prior session, if the user was logged in
     
     - parameter url:        The url of a Meteor server
     - parameter callback:   An optional closure to be executed after the connection is established
     */
    func connect(_ url:String, callback: @escaping() -> Void) {
        Meteor.connect(url) {
            DispatchQueue.main.async {
                callback()
            }
        }
    }
    
    fileprivate func removeFromSubscriptionsByModelType(subscription: RVBaseCollectionSubscription8) -> Bool {
        let modelType = subscription.collection
        var found: Bool = false
        if var subscriptions = self.subscriptionsByModelType[modelType] {
            for i in 0..<subscriptions.count {
                if subscriptions[i] == subscription {
                    subscriptions.remove(at: i)
                    self.subscriptionsByModelType[modelType] = subscriptions
                    found = true
                    break
                }
            }
        }
        return found
    }
    func addSubscription(subscription: RVBaseCollectionSubscription8) {
        var byType = [ RVBaseCollectionSubscription8]()
        if let id = subscription.subscriptionID {
            if let _ = subscriptions[id] {
                print("IN \(self.instanceType).addSubscription, attempting to add a subscription where ID already exists")
            } else {
                if let collections = self.subscriptionsByModelType[subscription.collection] {byType = collections }
                byType.append(subscription)
                self.subscriptionsByModelType[subscription.collection] = byType
                self.subscriptions[id] = subscription
            }
        } else {
            print("In \(self.instanceType).addSubscription, #\(#line) no ID for \(subscription)")
        }

    }
    func subscribe(subscription: RVBaseCollectionSubscription8, params: [Any], callback: @escaping() -> Void) {
        subscribeInner(subscription: subscription, params: params) { () in
            self.addSubscription(subscription: subscription)
            callback()
        }
    }
    fileprivate func subscribeInner(subscription: RVBaseCollectionSubscription8, params: [Any], callback: @escaping() -> Void) {
        DispatchQueue.main.async {
            subscription.subscriptionID = Meteor.subscribe(subscription.collection.rawValue, params: params, callback: {
                DispatchQueue.main.async {
                    callback()
                }
            })
        }
    }
    func unsubscribeAllOfACollection(modelType: RVModelType) {
        if let collections = self.subscriptionsByModelType[modelType] {
            for collection in collections {
                if let _ = collection.subscriptionID {
                    self.unsubscribe(subscription: collection, callback: { (id) in })
                }
            }
        }
    }
    func unsubscribe(subscription: RVBaseCollectionSubscription8, callback: @escaping (String?) -> Void ) {
        DispatchQueue.main.async {
            if let id = subscription.subscriptionID {
                if let match = self.subscriptions.removeValue(forKey: id) {
                    print("In \(self.instanceType).unsubscribe SubscriptionID: \(id) for \(subscription.collection.rawValue) found and removed in subscriptions dictionary")
                    match.subscriptionID = nil
                }
                if self.removeFromSubscriptionsByModelType(subscription: subscription) {
                    print("In \(self.instanceType).unsubscribe SubscriptionID: \(id) for \(subscription.collection.rawValue) found and removed in SubscriptionsByModelType")
                }
                Meteor.unsubscribe(withId: id, callback: {
                    DispatchQueue.main.async {
                        callback(id)
                    }
                })
                
            } else {
                callback(nil)
            }
        }
    }
}
 */
