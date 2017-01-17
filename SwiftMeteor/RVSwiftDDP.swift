//
//  RVSwiftDDP.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/8/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
import SwiftDDP
enum RVNotification: String {
    case userDidLogin = "RVUserDidLogin"
    case userDidLogout = "RVUserDidLogout"
    case collectionDidChange = "RVCollectionDidChange"
}
enum RVSwiftEvent: String {
    case userDidLogin = "RVUserDidLogin"
    case userDidLogout = "RVUserDidLogout"
    case collectionDidChange = "RVCollectionDidChange"
    case viewDeckDidOpen = "RVViewDeckDidOpen"
}

class RVSwiftDDP: NSObject {
    var instanceType: String { get { return String(describing: type(of: self)) } }
    let meteorURL = "wss://rnmpassword-nweintraut.c9users.io/websocket"
    let userDidLogin = "userDid"
    var username: String? = nil
    static let pluggedUsername = "neil.weintraut@gmail.com"
    static let pluggedPassword = "password"
    var loginListeners = RVListeners()
    var logoutListeners = RVListeners()
    
    static let sharedInstance: RVSwiftDDP = {
        return RVSwiftDDP()
    }()
    override init() {
        super.init()
        Meteor.client.allowSelfSignedSSL = true // Connect to a server that users a self signed ssl certificate
        Meteor.client.logLevel = .info // Options are: .Verbose, .Debug, .Info, .Warning, .Error, .Severe, .None
        Meteor.client.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(RVSwiftDDP.collectionDidChange), name: NSNotification.Name(rawValue: METEOR_COLLECTION_SET_DID_CHANGE), object: nil)
    }
    func connect(callback: @escaping () -> Void ) {
        Meteor.connect(self.meteorURL) {
            self.temporary()
            callback()
        }
    }
    func addListener(listener: NSObject, eventType: RVSwiftEvent, callback: @escaping (_ info: [String: AnyObject]?) -> Bool) -> RVListener?  {
        switch(eventType) {
        case .userDidLogin:
            return loginListeners.addListener(listener: listener, eventType: eventType , callback: callback)
        case .userDidLogout:
            return logoutListeners.addListener(listener: listener, eventType: eventType , callback: callback)
        default:
            print("In RVSwiftDDP.addListener eventType \(eventType.rawValue) not supported")
            return nil
        }
    }
    func removeListener(listener: RVListener)  {
        switch(listener.eventType) {
        case .userDidLogin:
            loginListeners.removeListener(listener: listener)
        case .userDidLogout:
            logoutListeners.removeListener(listener: listener)
        default:
            print("In RVSwiftDDP.addListener eventType \(listener.eventType.rawValue) not supported")
        }
    }
    func connect(email: String, password: String) {
        Meteor.connect(self.meteorURL, email: email, password: password)
    }
    func temporary() {
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { (timer) in
            if self.username == nil {
                print("In \(self.instanceType).temporary, after two second wait, no user, so attempting to login")
                self.loginWithUsername(username: RVSwiftDDP.pluggedUsername, password: RVSwiftDDP.pluggedPassword, callback: { (result, error ) in
                    if let error = error {
                        error.append(message: "In \(self.instanceType).temporary, got error logging in with: \(RVSwiftDDP.pluggedUsername) and \(RVSwiftDDP.pluggedPassword)")
                        error.printError()
                    }
                })
            } else {
               // print("In \(self.instanceType).temporary already logged in with username \(self.username)")
            }
        }
    }

    func loginWithUsername(username: String, password: String, callback: @escaping (_ result: Any?, _ error: RVError?)-> Void) -> Void {
        Meteor.loginWithUsername(username, password: password) { (result, error) in
            if let error = error {
                let rvError = RVError(message: "In \(self.instanceType).loginWithUsername, got Meteor error", sourceError: error)
                callback(nil, rvError)
                return
            } else {
                callback(result, nil)
            }
        }
    }
    func loginWithPassword(email: String, password: String, completionHandler: @escaping (_ result: Any?, _ error: RVError?)-> Void) -> Void {
        Meteor.loginWithPassword(email, password: password) { (result: Any?, error: DDPError?) in
            if let error = error {
                let rvError = RVError(message: "In \(self.instanceType).loginWithPassword, got Meteor Error", sourceError: error)
                completionHandler(result, rvError)
                return
            } else {
                completionHandler(result, nil)
            }
        }
    }

    @objc func collectionDidChange(notification: NSNotification) {
        print("In \(self.instanceType).collectionDidChange notification target")
        if let userInfo = notification.userInfo {
            for (key, value) in userInfo {
                print("\(key) : \(value)")
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: RVNotification.collectionDidChange.rawValue), object: nil, userInfo: notification.userInfo)
    }

}
extension RVSwiftDDP: SwiftDDPDelegate {
    func ddpUserDidLogin(_ user:String) {
        //print("In \(self.instanceType).ddpUserDidLogin(), User did login as user \(user)")
        self.username = user
        RVCoreInfo.sharedInstance.username = user
        loginListeners.notifyListeners()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: RVNotification.userDidLogin.rawValue), object: nil, userInfo: ["user": user])
        
    }
    func ddpUserDidLogout(_ user:String) {
        //print("In \(self.instanceType).ddpUserDidLogout(), User did logout")
        self.username = nil
        logoutListeners.notifyListeners()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: RVNotification.userDidLogout.rawValue), object: nil, userInfo: ["user": user])
    }
}
