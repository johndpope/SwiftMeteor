//
//  RVCoreInfo.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/7/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit

class RVCoreInfo: NSObject {
    static let sharedInstance: RVCoreInfo = { return RVCoreInfo() }()
    let domainName = RVDomainName.Rendevu
    
    var username: String? = nil
    var defaultState: RVBaseAppState {
        get {
            var stack = [RVBaseModel]()
            if let domain = self.domain { stack.append(domain) }
            return RVMainViewControllerState(stack: stack)
        }
    }
    private var _appState: RVBaseAppState = RVLoggedoutState()
    var appState: RVBaseAppState {
        get { return _appState }
        set { changeState(newState: newValue)}
    }
    var mainStoryboard = "Main"
    var loginCredentials: [String: AnyObject]? = nil
    var rootTask: RVTask?
    var userId: String? = nil
    var userProfile: RVUserProfile? = nil
    var domain: RVDomain? = nil
    var domainId: String? {
        get {
            if let domain = self.domain { return domain.localId}
            else { return nil }
        }
    }
    var rootGroup: RVGroup? = nil
    var specialCode = "NotValid"
    var navigationBarColor: UIColor { get {return UIColor(colorLiteralRed: 64/256, green: 128/256, blue: 255/256, alpha: 1.0)}}
    
    func userAndDomain() -> (RVUserProfile, String)? {
        if let userProfile = self.userProfile {
            if let domain = self.domain {
                if let domainId = domain.localId {
                    return (userProfile, domainId)
                }
            }
        }
        return nil
    }
    private var _messageCollection: RVMessageCollection? = nil
    var messageCollection: RVMessageCollection {
        get {
            if let collection = self._messageCollection { return collection }
            let collection = RVMessageCollection(name: "Message")
            self._messageCollection = collection
            return collection 
        }
    }
    var watchGroupImagePlaceholder: UIImage { get { return UIImage(named: "JNW.png")! } }
    private var activeButton: UIButton? = nil
    private var activeBarButton: UIBarButtonItem? = nil
    func changeState(newState: RVBaseAppState) {
        let currentState = self.appState
        if let _ = currentState as? RVLoggedoutState {
        } else { newState.lastState = currentState }
        self._appState = newState
    }
    // True response indicates Button is now in control to move forward
    func setActiveButtonIfNotActive(_ button: UIButton? = nil, _ barButton: UIBarButtonItem? = nil) -> Bool {
        if button == nil && barButton == nil {
            print("In \(self.classForCoder).setActiveButtonIfNotActive, both button and barButton are nil. This is an error.")
            return false
        } else if button != nil && barButton != nil {
            print("In \(self.classForCoder).setActiveButtonIfNotActive, both button and barButton are set. This is an error.")
            return false
        } else if self.activeButton == nil && self.activeBarButton == nil {
         //   print("In \(self.classForCoder).setActiveButton... passed. Returning true")
            activeButton = button
            activeBarButton = barButton
            return true
        } else { // Get here if one of the two button types is set
            return false
        }
    }
    // True response indicates that button was the active one
    func clearActiveButton(_ button: UIButton? = nil, _ barButton: UIBarButtonItem? = nil) -> Bool {
        if button == nil && barButton == nil {
            print("In \(self.classForCoder).clearActiveButton, both button and barButton are nil. This is an error.")
            return false
        }
        if button != nil && barButton != nil {
            print("In \(self.classForCoder).clearActiveButton, both button and barButton are set. This is an error.")
            return false
        }
        if let button = button {
            if let activeButton = self.activeButton {
                if button.isEqual(activeButton) {
                    self.activeButton = nil
                    return true
                } else { return false}
            }
        } else if let button = barButton {
            if let activeButton = self.activeBarButton {
                if button.isEqual(activeButton){
                    self.activeBarButton = nil
                    return true
                } else { return false}
            }
        }
        return false
    }
    func clearLogin() {
        domain = nil
        userProfile = nil
        username = nil
        loginCredentials = nil
    }
    func completeLogin(username: String, callback: @escaping(_ success: Bool, _ error: RVError?) -> Void) {
        //print("In \(self.classForCoder).completeLogin")
        RVUserProfile.getOrCreateUsersUserProfile(callback: { (profile, error) in
            if let error = error {
                error.append(message: "In \(self.classForCoder).getUserInfo(), got error")
                error.printError()
                return
            } else if let profile = profile {
                // self.userProfile = profile
                self.getDomain(callback: { (domain , error) in
                    if let error = error {
                        error.append(message: "In \(self.classForCoder).getUserProfile, got error getting Domain")
                        error.printError()
                        callback(false, error)
                        return
                    } else if let domain = domain {
                        self.domain = domain
                        self.userProfile = profile
                        self.username = username
                         print("In \(self.classForCoder).completeLogin, about to get RootGroup")
                        RVGroup.getRootGroup(callback: { (group , error) in
                            if let error = error {
                                error.append(message: "In \(self.classForCoder).completeLogin, error getting Root Group")
                            } else if let group = group {
                                print("Have root group \(group.localId ?? " no group.localId")" )
                                self.rootGroup = group
                            } else {
                                print("In \(self.classForCoder).completeLogin, no error, but no root group")
                            }
                        })
                        callback(true, nil)
                        return
                    } else {
                        callback(false, nil)
                    }
                })

                return
            } else {
                print("In \(self.classForCoder).getUserInfo(), no error but no profile")
            }
        })
    }
    private func getUserProfile() {
        if username == nil {
            self.userProfile = nil
            self.userId = nil
        } else {
            RVUserProfile.getOrCreateUsersUserProfile(callback: { (profile, error) in
                if let error = error {
                    error.append(message: "In \(self.classForCoder).getUserInfo(), got error")
                    error.printError()
                    return
                } else if let profile = profile {
                   // self.userProfile = profile
                    self.getDomain(callback: { (domain , error) in
                        if let error = error {
                            error.append(message: "In \(self.classForCoder).getUserProfile, got error getting Domain")
                            error.printError()
                            return
                        } else {
                            self.domain = domain
                            self.userProfile = profile
                            
                        }
                    })
                } else {
                    print("In \(self.classForCoder).getUserInfo(), no error but no profile")
                }
            })
        }
    }
    func getDomain(callback: @escaping(_ profile: RVDomain? , _ error: RVError?)-> Void) {
        let domain = RVDomain()
        domain.domainName = self.domainName
        domain.title = self.domainName.rawValue
        domain.findOrCreate(callback: { (domain , error ) in
            if let error = error {
                error.append(message: "In \(self.classForCoder).getUserProfile, got error")
                callback(nil, error)
                return
            } else if let domain = domain {
                self.domain = domain
                print("In \(self.classForCoder).getDomain have domain: \(domain.modelType.rawValue), \(domain.title!)")
                callback(domain, nil)
            } else {
                print("In \(self.classForCoder).getUserProfile, no error but no domain")
                callback(nil, nil)
            }
        })
    }
}
