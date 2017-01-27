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
            getUserProfile()
        }
    }
    var mainStoryboard = "Main"
    var loginCredentials: [String: AnyObject]? = nil
    var rootTask: RVTask?
    var userId: String? = nil
    var userProfile: RVUserProfile? = nil
    var domain: RVDomain? = nil
    var specialCode = "NotValid"
    
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
                    self.userProfile = profile
                    self.getDomain(callback: { (domain , error) in
                        if let error = error {
                            error.append(message: "In \(self.classForCoder).getUserProfile, got error getting Domain")
                            error.printError()
                            return
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
