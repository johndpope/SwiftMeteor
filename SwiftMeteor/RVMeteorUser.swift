//
//  RVUser.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 12/16/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import Foundation


class RVMeteorUser {
    private var _userId: String? = nil
    static let sharedInstance: RVMeteorUser = {
        RVMeteorUser()
    }()
    
    func userId(callback: @escaping (_ id: String?, _ error: RVError?)-> Void) -> Void {
        if let id = self._userId {
            callback(id, nil)
        } else {
            RVSwiftDDP.sharedInstance.MeteorCall(method: RVMeteorMethods.GetMeteorUserId, params: nil, callback: { (result, error) in
                
            
            // Meteor.call(RVMeteorMethods.GetMeteorUserId.rawValue, params: nil, callback: { (result, error: DDPError?) in
                if let rvError = error {
                    rvError.append(message: "In RVUser.userId got Meteor Error")
                //    let rvError = RVError(message: "In RVUser.userId got Meteor Error", sourceError: error)
                    callback(nil, rvError)
                    return
                } else if let result = result as? [String : String] {
                    if let userId = result["userId"] {
                        self._userId = userId
                        callback(userId, nil)
                        return
                    } else {
                        let rvError = RVError(message: "In RVUser.userId, no error but result returned was [String:String] or matched userId field")
                        callback(nil , rvError)
                        return
                    }
                } else {
                    callback(nil, nil)
                }
            })
        }
    }
}
