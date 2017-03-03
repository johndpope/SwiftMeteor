//
//  RVListener.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/16/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation

class RVListener: NSObject {
    let identifier = Date().timeIntervalSince1970
    var eventType: RVSwiftEvent
    weak var listener: NSObject?
    var handler: ([String: AnyObject]?) -> Bool
    init(listener: NSObject, eventType: RVSwiftEvent, handler: @escaping (_ info: [String:AnyObject]?)-> Bool) {
        self.eventType = eventType
        self.handler = handler
        self.listener = listener
        super.init()
    }
    
}
class RVListeners: NSObject {
    var listeners = [RVListener ]()
    func addListener(listener: NSObject, eventType: RVSwiftEvent, callback: @escaping(_ info: [String: AnyObject]?)->Bool)-> RVListener {
     //   print("In \(self.classForCoder).addListener \(eventType), \(listener)")
        let rvListener = RVListener(listener: listener, eventType: eventType, handler: callback)
        var duplicate = duplicateListeners()
        duplicate.append(rvListener)
        self.listeners = duplicate
        return rvListener
    }
    func removeListener(listener: RVListener) {
        var duplicate = duplicateListeners()
        for index in (0..<duplicate.count) {
            let candidate = duplicate[index]
            if candidate.identifier == listener.identifier {
                duplicate.remove(at: index)
                break
            }
        }
        self.listeners = duplicate 
    }
    func duplicateListeners() -> [RVListener] {
        var duplicate = [RVListener]()
        for index in (0..<listeners.count) {
            duplicate.append(self.listeners[index])
        }
        return duplicate
    }
    func notifyListeners() {
        for listener in self.listeners {
                         //print("In \(self.classForCoder).notifyListeners, doing listener \(listener)")
            if !listener.handler(nil) {

                return
            }
        }
    }
    
}
class RVListenerContainer: NSObject {
    var container = [NSObject : [RVListener]]()
    func addListener(publisher: NSObject, eventType: RVSwiftEvent, listener: NSObject, callback: @escaping(_ info: [String:AnyObject]?)->Bool) {
        let rvListener = RVListener(listener: listener , eventType: eventType , handler: callback)
        if let listeners = container[publisher] {
            var found: Bool = false
            for candidate in listeners {
                if let candidateListener = candidate.listener {
                    if candidateListener == listener {
                        if candidate.eventType == eventType {
                            found = true
                            break
                        }
                    }
                }
            }
            if !found {
                var duplicate = duplicateArray(listeners: listeners)
                duplicate.append(rvListener)
                container[publisher] = duplicate
            } else {
                print("In \(self.classForCoder).addListener, attempted to add a listener where one already exists \(listener) \(eventType.rawValue)")
            }
        } else {
            var publisherDictionary = duplicateDictionary()
            publisherDictionary[publisher] = [rvListener]
            container = publisherDictionary
        }
    }
    func removeListener(listener: RVListener) {

    }
    func duplicateDictionary() -> [NSObject: [RVListener]] {
        var duplicate = [NSObject: [RVListener]]()
        for (key, listeners) in container { duplicate[key] = listeners }
        return duplicate
    }
    func duplicateArray(listeners: [RVListener]) -> [RVListener] {
        var duplicate = [RVListener]()
        for index in (0..<listeners.count) {
            duplicate.append(listeners[index])
        }
        return duplicate
    }
}
class RVSwiftDDPDisposeBag {
    var listeners = [RVListener]()
    
}
