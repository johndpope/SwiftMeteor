//
//  RVStateDispatcher8.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/16/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
import Foundation
class RVStateDispatcher8 {
    var instanceType: String { get { return String(describing: type(of: self)) } }
    var currentState:   RVBaseAppState8 = RVLoggedOutState8()
    var previousState:  RVBaseAppState8 = RVLoggedOutState8()

    fileprivate let queue = RVOperationQueue(title: "RVStateDispatcher8")
    static var shared: RVStateDispatcher8 = { return RVStateDispatcher8() }()
    func changeState(newState: RVBaseAppState8, returnToCenter: Bool = false) {
        queue.addOperation(RVChangeStateOperation8<RVBaseModel>(newState: newState, returnToCenter: returnToCenter))
    }
    func connectAction() {
        queue.addOperation(RVChangeConnectionStateOperation<RVBaseModel>() )
    }
    func logoutNotification(userInfo: [String: String]) {
        queue.addOperation(RVLogoutOperation<RVBaseModel>(userInfo: userInfo))
    }
    func gotLoginFromServer(serverUserName: String) {
       // print("In \(self.instanceType).gotLoginfromServer, queue count \(queue.operationCount)")
        queue.addOperation(RVLoginFromServerOperation<RVBaseModel>(serverUserName: serverUserName))
    }
    func reconnected() {
        queue.addOperation(RVReconnectedOperation<RVBaseModel>())
    }
}

class RVChangeStateOperation8<T: NSObject>: RVAsyncOperation<T> {
    private var newState: RVBaseAppState8
    private var deck: RVViewDeck8 { get { return RVViewDeck8.shared }}
    private var returnToCenter: Bool = false
    
    init(newState: RVBaseAppState8, returnToCenter: Bool ) {
        self.newState = newState
        self.returnToCenter = returnToCenter
        super.init(title: "Change State to \(newState)", callback: {(models: [T], error: RVError?) in })
    }
    override func asyncMain() {
        DispatchQueue.main.async {
            if self.isCancelled {
                DispatchQueue.main.async {
               //     print("In \(self.classForCoder).asyncMain, line: \(#line), about to do dealWithCallback")
                    self.dealWithCallback()
                    self.completeOperation()
                    return
                }
            } else {
                DispatchQueue.main.async {
                   // let previousState = RVStateDispatcher8.shared.previousState
                    RVStateDispatcher8.shared.previousState = RVStateDispatcher8.shared.currentState
                    RVStateDispatcher8.shared.currentState = self.newState
                    self.deck.viewDeckChangeState(newState: self.newState, previousState: RVStateDispatcher8.shared.previousState, returnToCenter: self.returnToCenter, callback: {
                        //print("In \(self.classForCoder).asyncMain, line: \(#line), about to do dealWithCallback")
                        self.dealWithCallback()
                        self.completeOperation()
                    })
                }
            }
        }
    }
}
class RVChangeConnectionStateOperation<T: NSObject>: RVAsyncOperation8<T> {
    init() {
        super.init(title: "RVChangeConnectionStateOperation", parent: nil) { (error: RVError? ) in }
    }
    override func asyncMain() {
        if self.isCancelled {
            completeOperation()
        } else {
            DispatchQueue.main.async {
                if !RVSwiftDDP.sharedInstance.connected {
                    RVSwiftDDP.sharedInstance.connected = true
                    NotificationCenter.default.post(name: RVNotification.connected, object: nil, userInfo: nil)
                    DispatchQueue.main.async { RVSwiftDDP.sharedInstance.ignoreSubscriptions = false }
                    self.completeOperation()
                } else {
                    self.completeOperation()
                }
            }
        }
    }
}
class RVReconnectedOperation<T: NSObject>: RVAsyncOperation8<T> {
    init(){
        super.init(title: "RVReconnectedOperation", parent: nil)
    }
    override func asyncMain() {
        if self.isCancelled {
            self.completeOperation()
        } else {
            DispatchQueue.main.async {
                if RVSwiftDDP.sharedInstance.connected {
                    NotificationCenter.default.post(name: RVBaseCoreInfo8.reconnectedNotification, object: self , userInfo: nil)
                    RVSwiftDDP.sharedInstance.disconnectedTimer = nil
                }
                self.completeOperation()

            }
        }
    }
}
class RVLogoutOperation<T: NSObject>: RVAsyncOperation8<T> {
    var userInfo: [String: String]
    init(userInfo: [String: String]) {
        self.userInfo = userInfo
        super.init(title: "RVChangeConnectionStateOperation", parent: nil) { (error: RVError? ) in }
    }
    override func asyncMain() {
        DispatchQueue.main.async {
            if self.isCancelled {
                self.completeOperation()
            } else  {
                RVBaseCoreInfo8.shared.logoutModels()
                NotificationCenter.default.post(name: RVNotification.userDidLogout, object: nil, userInfo: self.userInfo)
                RVStateDispatcher8.shared.changeState(newState: RVLoggedOutState8())
                self.completeOperation()
            }
        }
        
    }
}
class RVLoginFromServerOperation<T: NSObject>: RVAsyncOperation8<T> {
    var serverUserName: String
    init(serverUserName: String) {
        self.serverUserName = serverUserName
        super.init(title: "RVLoginFromServerOperation", parent: nil)
    }
    override func asyncMain() {
      //  print("In \(self.classForCoder).asyncMain")
        DispatchQueue.main.async {
            if self.isCancelled {
                self.completeOperation()
            } else if !RVBaseCoreInfo8.shared.loggedIn {
                RVBaseCoreInfo8.sharedInstance.completeLogin(username: self.serverUserName) { (error) in
                    if let error = error {
                        error.append(message: "In \(self.instanceType).ddpUserDidLogin, got error")
                        error.printError()
                    }
                    self.completeOperation()
                }
            } else {
                self.completeOperation()
            }
        }
        
    }
}
