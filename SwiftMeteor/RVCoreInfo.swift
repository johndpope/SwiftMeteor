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
                    let domain = RVDomain()
                    domain.domainName = RVDomainName.PortolaValley
                    domain.title = "Portola Valley WatchGroup"
                    domain.findOrCreate(callback: { (domain , error ) in
                        if let error = error {
                            error.append(message: "In \(self.classForCoder).getUserProfile, got error")
                            error.printError()
                            return
                        } else if let domain = domain {
                            self.domain = domain
                        } else {
                            print("In \(self.classForCoder).getUserProfile, no error but no domain")
                        }
                    })
                } else {
                    print("In \(self.classForCoder).getUserInfo(), no error but no profile")
                }
            })
        }
    }
}
