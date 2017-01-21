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
                    let profile = RVUserProfile.fakeIt()
                    profile.create(callback: { (error ) in
                        if let error = error {
                            error.append(message: "In \(self.classForCoder).getUserInfo() error creating \(profile.localId)")
                            error.printError()
                        } else {
                            if let id = profile.localId {
                                RVUserProfile.retrieveInstance(id: id, callback: { (profile, error ) in
                                    if let error = error {
                                        error.append(message: "IN \(self.classForCoder).getUserInfo(), got error retrieving \(id)")
                                        error.printError()
                                    } else if let profile = profile as? RVUserProfile {
                                        print(profile.toString())
                                    } else {
                                        print("In \(self.classForCoder), no error but no result for retrieving \(id)")
                                    }
                                })
                            }
                        }
                    })
                    /*
                        Meteor.call(RVMeteorMethods.userProfileCreate.rawValue, params: [params], callback: { (result, error) in
                            if let error = error {
                                let rvError = RVError(message: "In RVCoreInfo.getUserInfo() error creating UserProfile", sourceError: error, lineNumber: #line, fileName: "")
                                rvError.printError()
                                return
                            } else if let result = result {
                                print("In \(self.classForCoder).getUserInfo, have result of UserProfile \(result)")
                                Meteor.call(RVMeteorMethods.meteoruserFindUserProfileId.rawValue, params: nil, callback: { (result, error) in
                                    if let error = error {
                                        print("In \(self.classForCoder), got error \(error)")
                                    } else if let result = result as? [String : String] {
                                        if let id = result["userProfileId"] {
                                            RVUserProfile.retrieveInstance(id: id, callback: { (model, error) in
                                                if let error = error {
                                                    error.append(message: "In \(self.classForCoder), got error retrieving instance id \(id)")
                                                    error.printError()
                                                } else if let model = model {
                                                    print("In \(self.classForCoder), have userProfile \n\(model.toString())")
                                                } else {
                                                    print("In \(self.classForCoder). no error no result retrieving userProfile id \(id)")
                                                }
                                            })
                                        }
                                        print("In \(self.classForCoder), have result for userProfileId \(result)")

                                    } else {
                                        print("In\(self.classForCoder) no error but no result of userProfileId")
                                    }
                                })
                            } else {
                                print("In \(self.classForCoder).getUserInfo, no error but no result")
                            }
                        })
*/
                } else {
                    print("In \(self.classForCoder).getUserInfo, no user but no userId")
                    
                }
            }
        }

    }
}
