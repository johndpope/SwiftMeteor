//
//  RVCoreInfo.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/7/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
import SwiftDDP

class RVCoreInfo: NSObject {
    static let sharedInstance: RVCoreInfo = {
        return RVCoreInfo()
    }()
    var username: String? = nil {
        didSet {
            //getUserProfile()
        }
    }
    var defaultState: RVBaseAppState {
        get {
            var stack = [RVBaseModel]()
            if let domain = self.domain { stack.append(domain) }
            return RVMainViewControllerState(scrollView: UIScrollView(), stack: stack)
        }
    }
    var appState: RVBaseAppState = RVMainViewControllerState(scrollView: UIScrollView())
    var mainStoryboard = "Main"
    var loginCredentials: [String: AnyObject]? = nil
    var rootTask: RVTask?
    var userId: String? = nil
    var userProfile: RVUserProfile? = nil
    var domain: RVDomain? = nil
    var specialCode = "NotValid"
    var watchGroupImagePlaceholder: UIImage { get { return UIImage(named: "JNW.png")! } }
    private var activeButton: UIButton? = nil
    private var activeBarButton: UIBarButtonItem? = nil
    func changeState(newState: RVBaseAppState) {
        let currentState = self.appState
        if let _ = currentState as? RVLoggedoutState {
        } else { newState.lastState = currentState }
        self.appState = newState
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
    func completeLogin(username: String, callback: @escaping(_ success: Bool, _ error: RVError?) -> Void) {
        print("In \(self.classForCoder).completeLogin")
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
    func getUserProfile() {
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
        domain.domainName = RVDomainName.PortolaValley
        domain.title = "Portola Valley WatchGroup"
        domain.findOrCreate(callback: { (domain , error ) in
            if let error = error {
                error.append(message: "In \(self.classForCoder).getUserProfile, got error")
                callback(nil, error)
                return
            } else if let domain = domain {
                self.domain = domain
                callback(domain, nil)
            } else {
                print("In \(self.classForCoder).getUserProfile, no error but no domain")
                callback(nil, nil)
            }
        })
    }
}
