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
    case connected = "Connected"
    case StateUninstalled = "StateUninstalled"
    case StateInstalled = "StateInstalled"
    case AppStateChanged = "AppStateChanged"
}
enum RVSwiftEvent: String {
    case userDidLogin = "RVUserDidLogin"
    case userDidLogout = "RVUserDidLogout"
    case collectionDidChange = "RVCollectionDidChange"
    case viewDeckDidOpen = "RVViewDeckDidOpen"
}

class RVSwiftDDP: NSObject {
    var messages: RVMessageCollection2!
    var transactions: RVTransactionCollection!
    enum SignupError: String {
        case emailAlreadyExists = "Email already exist" // DDPError 403
    }
    enum DDP_Codes: String {
        // self.userData.set(email, forKey: DDP_EMAIL)
        // self.userData.synchronize()
        // let email = self.userData.object(forKey: DDP_EMAIL) as? String
        // self.userData.removeObject(forKey: DDP_ID)
        case DDP_ID = "DDP_ID"                          // set by DDPExtension upon login                   String key="id"
        case DDP_EMAIL = "DDP_EMAIL"                    // set by DDPExtension upon login, signup           String key="email"
        case DDP_USERNAME = "DDP_USERNAME"              // set by DDPExtension upon login, signup           String key="username"
        case DDP_TOKEN = "DDP_TOKEN"                    // set by DDPExtension upon login                   String key="token"
        case DDP_TOKEN_EXPIRES = "DDP_TOKEN_EXPIRES"    // set by DDPExtension upon login                   NSDictionary key="tokenExpires"
        case DDP_LOGGED_IN = "DDP_LOGGED_IN"            // set by DDPExtension upon login Bool
        case DDP_USER_DID_LOGIN = "DDP_USER_DID_LOGIN"  // Notification Name
        case DDP_USER_DID_LOGOUT = "DDP_USER_DID_LOGOUT"// Notification Name
    }
    var instanceType: String { get { return String(describing: type(of: self)) } }
    var appState: RVBaseAppState {
        get { return RVCoreInfo.sharedInstance.appState }
        set { RVCoreInfo.sharedInstance.appState = newValue }
    }
    let meteorURL = "wss://rnmpassword-nweintraut.c9users.io/websocket"
    let userDidLogin = "userDid"
    //var username: String? = nil
    static let pluggedUsername = "elmer@fudd.com" //"neil.weintraut@gmail.com"
    static let pluggedPassword = "password"
    let userDefaults = UserDefaults.standard
    var loginListeners = RVListeners()
    var logoutListeners = RVListeners()
    var connected: Bool = false
    
    static let sharedInstance: RVSwiftDDP = {
        return RVSwiftDDP()
    }()
    override init() {
        super.init()
        Meteor.client.allowSelfSignedSSL = true // Connect to a server that users a self signed ssl certificate
        Meteor.client.logLevel = .info // Options are: .Verbose, .Debug, .Info, .Warning, .Error, .Severe, .None
        Meteor.client.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(RVSwiftDDP.collectionDidChange), name: NSNotification.Name(rawValue: METEOR_COLLECTION_SET_DID_CHANGE), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RVSwiftDDP.ddpDisconnected), name: NSNotification.Name(rawValue: DDP_DISCONNECTED), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RVSwiftDDP.ddpFailed), name: NSNotification.Name(rawValue: DDP_FAILED), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RVSwiftDDP.ddpWebsocketError), name: NSNotification.Name(rawValue: DDP_WEBSOCKET_ERROR), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RVSwiftDDP.ddpWebsocketClose), name: NSNotification.Name(rawValue: DDP_WEBSOCKET_CLOSE), object: nil)
    }
    @objc func ddpDisconnected(notification: NSNotification) {
        print("IN \(self.classForCoder).ddpDisconnected \(notification.userInfo?.description ?? " No userInfo")")
    }
    @objc func ddpFailed(notification: NSNotification) {
        print("IN \(self.classForCoder).ddpFailed \(notification.userInfo?.description ?? " No userInfo")")
    }
    @objc func ddpWebsocketError(notification: NSNotification) {
        print("IN \(self.classForCoder).ddpWebsocketError \(notification.userInfo?.description ?? "No User Info")")
    }
    @objc func ddpWebsocketClose(notification: NSNotification) {
        print("IN \(self.classForCoder).ddpWebsocketClose \(notification.userInfo?.description ?? " no userInfo")")
    }
    func getId() -> String {
        return Meteor.client.getId()
    }
    
    func signupViaEmail(email: String, password: String, profile: [String: AnyObject]? = nil, callback:@escaping(_ error: RVError?) -> Void ) {
        let email = email.lowercased()
        if !email.validEmail() {
            let rvError = RVError(message: "In \(self.instanceType).signupViaEmail, email is invalid \(email)", sourceError: nil, lineNumber: #line)
            callback(rvError)
            return
        }
        if !password.validPassword() {
            let rvError = RVError(message: "In \(self.instanceType).signupViaEmail, email \(email) is valid, but password \(password) contains spaces")
            callback(rvError)
            return
        }
        if let profile = profile {
            Meteor.client.signupWithEmail(email, password: password, profile: profile as NSDictionary, callback: { (result, error: DDPError?) in
            self.handleSignup(result: result , error: error , callback: callback)
            })
        } else {
            Meteor.client.signupWithEmail(email, password: password, callback: { (result, error: DDPError?) in
                self.handleSignup(result: result , error: error , callback: callback)
            })
        }
    }
    /* Returns ID of the Subscription */
    func subscribe(collectionName: RVModelType, params: [Any]?, callback: @escaping() -> Void) -> String {
        return Meteor.subscribe(collectionName.rawValue, params: params, callback: callback)
    }
    func unsubscribe(collectionName: String, callback: @escaping() -> Void ) -> [String] {
        return Meteor.unsubscribe(collectionName) {
            callback()
        }
    }
    func unsubscribe(subscriptionId: String, callback: @escaping() -> Void ) {
        return Meteor.unsubscribe(withId: subscriptionId, callback: callback)
    }
    
    func handleSignup(result: Any?, error: DDPError?, callback: @escaping(_ error: RVError?) -> Void ){
        if let error = error {
            let rvError = RVError(message: "In \(self.instanceType).signupViaEmail \(#line), got DDPError", sourceError: error, lineNumber: #line)
            callback(rvError)
            return
        } else if let _ = result {
           // print("In \(self.classForCoder).signupViaEmail line \(#line), result is \(result)")
            callback(nil)
            return
        } else {
            print("In \(self.classForCoder).signupViaEmail line \(#line), no error but no result")
            callback(nil)
            return
        }
    }
    func MeteorCall(method: RVMeteorMethods, params: [Any]?, callback: @escaping(_ any: Any?, _ error: RVError?) -> Void ) {
        Meteor.call(method.rawValue, params: params) { (any: Any? , error: DDPError?) in
            if let error = error {
                let rvError = RVError(message: "In \(self.classForCoder).MeteorCall", sourceError: error, lineNumber: #line, fileName: "")
                callback(nil , rvError)
                return
            } else {
                callback(any, nil)
            }
        }
    }
    /**
     Connect to a Meteor server and resume a prior session, if the user was logged in
     
     - parameter url:        The url of a Meteor server
     - parameter callback:   An optional closure to be executed after the connection is established
     */
    func connect(callback: @escaping () -> Void ) {
        Meteor.unsubscribe(RVModelType.transaction.rawValue) { 
            
        }
        Meteor.connect(self.meteorURL) {
            //print("In \(self.classForCoder).connect, connected -----------")
            self.connected = true
            callback()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: RVNotification.connected.rawValue), object: nil, userInfo: nil)
        }
    }
    func logout(callback: @escaping(_ error: RVError?)-> Void) {
        print("In \(self.classForCoder).logout")
        if Meteor.client.user() == nil {
            print("In \(self.classForCoder).logout, already logged out")
            RVStateDispatcher8.shared.changeState(newState: RVLoggedOutState8())
           // RVStateDispatcher4.shared.changeState(newState: RVBaseAppState4(appState: .loggedOut))
            callback(nil)
            logoutListeners.notifyListeners()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: RVNotification.userDidLogout.rawValue), object: nil, userInfo: nil)
            return
        }
        Meteor.logout { (result, error) in
            print("In \(self.classForCoder).logout Meteor logout callback")
            if let error = error {
                let rvError = RVError(message: "In \(self.classForCoder).logout, got DDPError", sourceError: error)
                callback(rvError)
            } else if let result = result {
                print("In \(self.classForCoder).logout, success. Result is \(result)")
                callback(nil)
            } else {
                //print("In \(self.classForCoder).logout, no error but no result")
                callback(nil)
            }
            RVStateDispatcher8.shared.changeState(newState: RVLoggedOutState8())
           // RVStateDispatcher4.shared.changeState(newState: RVBaseAppState4(appState: .loggedOut))
        }
    }
    func addListener(listener: NSObject, eventType: RVSwiftEvent, callback: @escaping (_ info: [String: AnyObject]?) -> Bool) -> RVListener?  {
        switch(eventType) {
        case .userDidLogin:
          //  print("In \(self.classForCoder) adding Listener for userDidLogin")
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
        print("In \(self.classForCoder).connect using email and password ---------------")
        Meteor.connect(self.meteorURL, email: email, password: password)
    }
    func temporary() {
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { (timer) in
            if RVCoreInfo.sharedInstance.username == nil {
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
    /*
     if let data = result as? NSDictionary,
     let id = data["id"] as? String,
     let token = data["token"] as? String,
     let tokenExpires = data["tokenExpires"] as? NSDictionary {
     let expiration = dateFromTimestamp(tokenExpires)
     self.userData.set(id, forKey: DDP_ID)
     self.userData.set(token, forKey: DDP_TOKEN)
     self.userData.set(expiration, forKey: DDP_TOKEN_EXPIRES)
     }
 */


    func loginWithUsername(username: String, password: String, callback: @escaping (_ result: Any?, _ error: RVError?)-> Void) -> Void {
        Meteor.loginWithUsername(username, password: password) { (result, error) in
            if let error = error {
                let rvError = RVError(message: "In \(self.instanceType).loginWithUsername \(username) \(password), got Meteor error", sourceError: error)
                callback(nil, rvError)
                return
            } else if let result = result as? [String : AnyObject] {
                print("In \(self.classForCoder).loginWithUsername, no error got result")
                RVBaseCoreInfo8.sharedInstance.loginCredentials = result
            //    RVCoreInfo.sharedInstance.loginCredentials = result
                callback(result, nil)
            } else {
                print("In \(self.classForCoder).loginWithUsername, no error but no result")
                callback(nil, nil)
            }
        }
    }
    func loginWithPassword(email: String, password: String, completionHandler: @escaping (_ result: Any?, _ error: RVError?)-> Void) -> Void {
        Meteor.loginWithPassword(email, password: password) { (result: Any?, error: DDPError?) in
            if let error = error {
                let rvError = RVError(message: "In \(self.instanceType).loginWithPassword, got Meteor Error for email \(email) password \(password)", sourceError: error)
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
        // print("In \(self.instanceType).ddpUserDidLogin(), User did login as user \(user)")
        RVBaseCoreInfo8.sharedInstance.completeLogin(username: user) { (error) in
            if let error = error {
                error.append(message: "In \(self.instanceType).ddpUserDidLogin, got error")
                error.printError()
                return
            } else {

            }
        }
        /*
        RVCoreInfo.sharedInstance.completeLogin(username: user) { (success, error) in
            if let error = error {
                error.append(message: "In \(self.classForCoder).ddpUserDidLogin user: \(user), got error")
                error.printError()
                return
            } else if success {
                RVCoreInfo.sharedInstance.appState = RVLoggedInState()
               // print("In \(self.classForCoder).ddpUserDidLogin, about to notify [\(self.loginListeners.listeners.count)] listeners and publish notification \(RVNotification.userDidLogin.rawValue)")
                self.loginListeners.notifyListeners()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: RVNotification.userDidLogin.rawValue), object: nil, userInfo: ["user": user])
                print("IN \(self.classForCoder) about to subscribe")
                self.messages = RVMessageCollection2()
                self.messages.query = RVQuery()
                Meteor.unsubscribe(withId: RVModelType.transaction.rawValue)
                /*
                self.transactions = RVTransactionCollection()
                let query = RVQuery()
                query.addAnd(term: .topParentId, value: "88" as AnyObject, comparison: .eq)
                self.transactions.query = query 
                let id = self.transactions.subscribe {
                    print("In \(self.classForCoder).ddpUserDidLogin")
                }
                print("In \(self.classForCoder), transaction id = \(id)")
 */
            } else {
                print("In \(self.classForCoder).ddpUserDidLogin, no error but failure")
            }
        }
 */
    }
    func ddpUserDidLogout(_ user:String) {
    //    print("In \(self.instanceType).ddpUserDidLogout(), User \(user) did logout")
        //self.username = nil
        RVBaseCoreInfo8.shared.logoutModels()

        logoutListeners.notifyListeners()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: RVNotification.userDidLogout.rawValue), object: nil, userInfo: ["user": user])
        
    }
}
