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
            getUserInfo()
        }
    }
    var loginCredentials: [String: AnyObject]? = nil
    var rootTask: RVTask?
    var userId: String? = nil
    private var _userProfile: RVUserProfile? = nil
    
    
    
    func getUserInfo() {
        print("----------- In \(self.classForCoder).getUserInfo()")
        if username == nil {
            self._userProfile = nil
            self.userId = nil
        } else {
            RVMeteorUser.sharedInstance.userId { (userId, error: RVError?) in
                if let error = error {
                    error.append(message: "In \(self.classForCoder).getUserInfo line \(#line), got error ")
                    error.printError()
                } else if let userId = userId {
                    print("In \(self.classForCoder).getUserInfo, got userID: \(userId)")
                    self.userId = userId
                    Meteor.call("userProfile.findUser", params: nil, callback: { (result, error: DDPError?) in
                        if let error = error {
                            let rvError = RVError(message: "In RVUser.userId userProfile.findUser got Meteor Error", sourceError: error)
                            rvError.printError()
                           // callback(nil, rvError)
                            return
                        } else if let result = result as? [String : String] {
                            print("In \(self.classForCoder).getUserInfo(), Result is \(result)")
                        } else {
                         //   callback(nil, nil)
                        }
                    })
                } else {
                    print("In \(self.classForCoder).getUserInfo, no user but no userId")
                    
                }
            }
        }

    }
}
