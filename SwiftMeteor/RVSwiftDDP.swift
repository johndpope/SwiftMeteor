//
//  RVSwiftDDP.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/8/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
import SwiftDDP

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
    let meteorClient = Meteor.client

    func addSubscription(subscription: RVBaseCollectionSubscription8) {
        Meteor.collections[subscription.modelType.rawValue] = subscription
    }

    func subscribe(subscription: RVBaseCollectionSubscription8, params: [AnyObject], callback: @escaping () -> Void ) -> Void {
        if let id = subscription.subscriptionID {
            print("In \(self.classForCoder).subscribe attempting to subscribe when already subscribed. id: \(id)")
            self.unsubscribe(id: id)
        }
        subscription.subscriptionID = self.subscribe(collectionName: subscription.modelType, params: params, callback: callback)
    }
    /* Returns ID of the Subscription */
    func subscribe(collectionName: RVModelType, params: [Any]?, callback: @escaping () -> Void ) -> String {
        return Meteor.subscribe(collectionName.rawValue, params: params) { DispatchQueue.main.async {callback()} }
    }
    func subscribe(collectionName: String, params: [AnyObject]) -> String {
        return Meteor.subscribe(collectionName, params: params)
    }
    
    func unsubscribe(subscriptionId: String?, callback: @escaping () -> Void) {
        if let id = subscriptionId {
            Meteor.unsubscribe(withId: id, callback: { DispatchQueue.main.async { callback() } })
            return
        } else { callback() }
    }
    func unsubscribe(id: String?) { if let id = id { Meteor.unsubscribe(withId: id) } }
    func meteorCall(method: String, params: [Any], callback: @escaping (Any?, RVError?) -> Void ) {
        Meteor.call(method, params: params) { (result: Any?, error: DDPError?) in
            DispatchQueue.main.async {
                if let error = error {
                    let rvError = RVError(message: "In \(self.classForCoder).meteorCall, got Meteor Error", sourceError: error , lineNumber: #line)
                    callback(nil, rvError)
                } else {
                    callback(result, nil)
                }
            }
        }
    }
    fileprivate var _disconnectedTimer: Timer? = nil
    var disconnectedTimer: Timer? {
        get {
            if let timer = self._disconnectedTimer { return timer }
            self._disconnectedTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { (timer) in
                UILabel.showMessage("Attempting to Connect", ofSize: 24.0, of: UIColor.candyGreen(), in: UIViewController.top().view, forDuration: 2.0)
            }
            self._disconnectedTimer!.fire()
            return self._disconnectedTimer
        }
        set {
            if newValue == nil {
                if let timer = self._disconnectedTimer { timer.invalidate() }
                self._disconnectedTimer = nil
            }
        }
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
    var subscriptionsCancelled: [RVModelType: Bool] = [.transaction: false , .Group: false]
    var ignoreSubscriptions: Bool = true {
        didSet {
            if ignoreSubscriptions {
                NotificationCenter.default.post(name: RVNotification.ignoreSubscription, object: self , userInfo: nil)
            }
        }
    }
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(RVSwiftDDP.ddpConnected(notification:)), name: NSNotification.Name("DDP Connected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RVSwiftDDP.ddpDisconnected(notification:)), name: NSNotification.Name("DDP Disconnected"), object: nil)
        // NotificationCenter.default.post(name: NSNotification.Name("DDP Connected"), object: self, userInfo: nil)
        //  NotificationCenter.default.post(name: NSNotification.Name("DDP Disconnected"), object: self, userInfo: nil)
    }
    @objc func ddpDisconnected(notification: NSNotification) {
        // print("IN \(self.classForCoder).ddpDisconnected \(notification.userInfo?.description ?? " No userInfo")")
        if self.connected {
            self.connected = false
            self.ignoreSubscriptions = true
            //for (key, _) in self.subscriptionsCancelled { self.subscriptionsCancelled[key] = true }
            self.disconnectedTimer = nil
            let _ = self.disconnectedTimer
            Timer.scheduledTimer(withTimeInterval: 20.0, repeats: true) { (timer) in
                if !self.connected {
                    RVSwiftDDP.sharedInstance.connect()
                } else {
                    timer.invalidate()
                }
            }
        }
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
    func ddpConnected(notification: NSNotification) {
        print("In \(self.classForCoder).ddpConnected ")
        if !self.connected {
         //   self.connected = true
         //   self.ignoreSubscriptions = false
            /*
            for (key, _) in self.subscriptionsCancelled {
                let model = key
                self.subscriptionsCancelled[model] = false
                
            }
 */
            RVStateDispatcher8.shared.connectAction()
           // NotificationCenter.default.post(name: RVNotification.connected, object: nil, userInfo: nil)
        }
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
        Meteor.call(method.rawValue.lowercased(), params: params) { (any: Any? , error: DDPError?) in
            DispatchQueue.main.async {
                if let error = error {
                    let rvError = RVError(message: "In \(self.classForCoder).MeteorCall", sourceError: error, lineNumber: #line, fileName: "")
                    callback(nil , rvError)
                    return
                } else {
                    callback(any, nil)
                }
            }
        }
    }
    /**
     Connect to a Meteor server and resume a prior session, if the user was logged in
     
     - parameter url:        The url of a Meteor server
     - parameter callback:   An optional closure to be executed after the connection is established
     */
    func connect() {
        if !self.connected {
            let time = Date()
            print("In \(self.classForCoder). attempting to connect at time \(time)")
          //  for (key, _) in self.subscriptionsCancelled { self.subscriptionsCancelled[key] = true }
            Meteor.connect(self.meteorURL, callback: {
                self.disconnectedTimer = nil
                if !self.connected {
                    print("In \(self.classForCoder).connect, connected with attempt time of \(time) -----------")
                  //  self.connected = true
                  //  self.ignoreSubscriptions = false
                    /*
                    for (key, _) in self.subscriptionsCancelled {
                        let model = key
                        self.subscriptionsCancelled[model] = false
                       
                    }
                    */
                    RVStateDispatcher8.shared.connectAction()
                   // NotificationCenter.default.post(name: RVNotification.connected, object: nil, userInfo: nil)
                }
            })
        }
    }
    func logout(callback: @escaping(_ error: RVError?)-> Void) {
        print("In \(self.classForCoder).logout")
        if Meteor.client.user() == nil {
            print("In \(self.classForCoder).logout, already logged out")
            
             RVStateDispatcher8.shared.logoutNotification(userInfo: ["user": "unknown"])
           // RVStateDispatcher8.shared.changeState(newState: RVLoggedOutState8())
           // RVStateDispatcher4.shared.changeState(newState: RVBaseAppState4(appState: .loggedOut))
            callback(nil)
         //   logoutListeners.notifyListeners()
         //   NotificationCenter.default.post(name: RVNotification.userDidLogout, object: nil, userInfo: nil)
         //   return
        }
        Meteor.logout { (result, error) in
            print("In \(self.classForCoder).logout Meteor logout callback")
            if let error = error {
                let rvError = RVError(message: "In \(self.classForCoder).logout, got DDPError", sourceError: error)
                 RVStateDispatcher8.shared.logoutNotification(userInfo: ["user": "unknown"])
                callback(rvError)
            } else if let result = result {
                print("In \(self.classForCoder).logout, success. Result is \(result)")
                 RVStateDispatcher8.shared.logoutNotification(userInfo: ["user": "unknown"])
                callback(nil)
            } else {
                //print("In \(self.classForCoder).logout, no error but no result")
                 RVStateDispatcher8.shared.logoutNotification(userInfo: ["user": "unknown"])
                callback(nil)
            }
          //  RVStateDispatcher8.shared.changeState(newState: RVLoggedOutState8())
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
                print("In \(self.classForCoder).loginWithUsername, no error got result and credentials: \(result)")
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
            } else if let result = result as? [String : AnyObject] {
                 print("In \(self.classForCoder).loginWithPassword, and credentials: \(String(describing: result))")
                RVBaseCoreInfo8.sharedInstance.loginCredentials = result
            }
             completionHandler(result, nil)
        }
    }

    @objc func collectionDidChange(notification: NSNotification) {
        print("In \(self.instanceType).collectionDidChange notification target")
        if let userInfo = notification.userInfo {
            for (key, value) in userInfo {
                print("\(key) : \(value)")
            }
        }
        NotificationCenter.default.post(name: RVNotification.collectionDidChange, object: nil, userInfo: notification.userInfo)
    }
}
extension RVSwiftDDP: SwiftDDPDelegate {
    // Called as delegate by DDPClient
    func ddpUserDidLogin(_ user:String) {
        RVStateDispatcher8.shared.gotLoginFromServer(serverUserName: user)
        // print("In \(self.instanceType).ddpUserDidLogin(), User did login as user \(user)")
        /*
        RVBaseCoreInfo8.sharedInstance.completeLogin(username: user) { (error) in
            if let error = error {
                error.append(message: "In \(self.instanceType).ddpUserDidLogin, got error")
                error.printError()
                return
            } else {

            }
        }
 */
    }
    // Called as delegate by DDPClient
    func ddpUserDidLogout(_ user:String) {
    //    print("In \(self.instanceType).ddpUserDidLogout(), User \(user) did logout")
        //self.username = nil
        RVStateDispatcher8.shared.logoutNotification(userInfo: ["user": user])
      //  RVBaseCoreInfo8.shared.logoutModels()

   //     logoutListeners.notifyListeners()
   //     NotificationCenter.default.post(name: RVNotification.userDidLogout, object: nil, userInfo: ["user": user])
        
    }
}
