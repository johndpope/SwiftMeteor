//
//  RVSetting.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/20/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
class RVSetting: RVBaseModel {
    override class func collectionType() -> RVModelType { return RVModelType.setting }
    //    override class var insertMethod: RVMeteorMethods { get { return RVMeteorMethods.InsertTask } }
    //    override class var updateMethod: RVMeteorMethods { get { return RVMeteorMethods.UpdateTask } }
    //    override class var deleteMethod: RVMeteorMethods { get { return RVMeteorMethods.DeleteTask } }
    //    override class var findMethod: RVMeteorMethods { get { return RVMeteorMethods.FindTask}}
    //    override class var bulkQueryMethod: RVMeteorMethods { get { return RVMeteorMethods.BulkTask } }

    
    var emailVerified: Bool {
        get {
            if let value = getBool(key: .emailVerified) { return value }
            return false
        }
        set { updateBool(key: .emailVerified, value: newValue, setDirties: true) }
    }
    var emailVisibility: Bool {
        get {
            if let value = getBool(key: .emailVisibility) { return value }
            return false
        }
        set { updateBool(key: .emailVisibility, value: newValue, setDirties: true) }
    }
    var cellVisibility: Bool {
        get {
            if let value = getBool(key: .cellVisibility) { return value }
            return false
        }
        set { updateBool(key: .cellVisibility, value: newValue, setDirties: true) }
    }
    var cellVerified: Bool {
        get {
            if let value = getBool(key: .cellVerified) { return value }
            return false
        }
        set { updateBool(key: .cellVerified, value: newValue, setDirties: true) }
    }
    var homeVisibility: Bool {
        get {
            if let value = getBool(key: .homeVisibility) { return value }
            return false
        }
        set { updateBool(key: .homeVisibility, value: newValue, setDirties: true) }
    }
    var homeVerified: Bool {
        get {
            if let value = getBool(key: .homeVerified) { return value }
            return false
        }
        set { updateBool(key: .homeVerified, value: newValue, setDirties: true) }
    }
}

