//
//  RVUser.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/20/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
import SwiftDDP
class RVUserProfile: RVBaseModel {
    override class func collectionType() -> RVModelType { return RVModelType.userProfile }
    override class var insertMethod: RVMeteorMethods { get { return RVMeteorMethods.userProfileInsert } }
    override class var updateMethod: RVMeteorMethods { get { return RVMeteorMethods.userProfileUpdate } }
    override class var deleteMethod: RVMeteorMethods { get { return RVMeteorMethods.userProfileDelete } }
    override class var findMethod: RVMeteorMethods { get { return RVMeteorMethods.userProfileFind}}
    override class var bulkQueryMethod: RVMeteorMethods { get { return RVMeteorMethods.userProfileBulkQuery } }
    override class func createInstance(fields: [String : AnyObject])-> RVBaseModel { return RVUserProfile(fields: fields) }
    override class func modelFromFields(fields: [String: AnyObject]) -> RVBaseModel { return RVUserProfile(fields: fields) }
    
    var first: String? {
        get { return getString(key: .firstName) }
        set { updateString(key: .firstName, value: newValue, setDirties: true) }
    
    }
    var middle: String? {
        get { return getString(key: .middleName) }
        set { updateString(key: .middleName, value: newValue, setDirties: true) }
    }
    var last: String? {
        get { return getString(key: .lastName) }
        set { updateString(key: .lastName, value: newValue, setDirties: true) }
    }
    var email: String? {
        get { return getString(key: .email) }
        set { updateString(key: .email, value: newValue, setDirties: true) }
    }
    var yob: Int? {
        get {
            if let number = getNSNumber(key: .yob) {
                return number.intValue
            } else { return nil}
        }
        set {
            if let value = newValue {
                updateNumber(key: .yob, value: NSNumber(value: value), setDirties: true)
            } else {
                updateNumber(key: .yob, value: nil, setDirties: true)
            }
        }
    }
    
    var gender: RVGender {
        get {
            if let rawValue = getString(key: .gender) {
                if let gender = RVGender(rawValue: rawValue) { return gender}
            }
            return .unknown
        }
        set { updateString(key: .gender, value: newValue.rawValue, setDirties: true) }
    }
    var cellPhone: String? {
        get { return getString(key: .cellPhone) }
        set { updateString(key: .cellPhone, value: newValue, setDirties: true) }
    }
    var homePhone: String? {
        get { return getString(key: .homePhone) }
        set { updateString(key: .homePhone, value: newValue, setDirties: true) }
    }
    var settings: RVSetting? {
        get {
            if let fields = getDictionary(key: .settings) {
                return RVSetting(fields: fields)
            }
            return nil
        }
        set {
            if let settings = newValue {
                updateDictionary(key: .settings, value: settings.objects, setDirties: true)
            } else {
                updateDictionary(key: .settings, value: nil, setDirties: true)
            }
        }
    }
    var watchGroupIds: [String] {
        get {
            if let array = getArray(key: .watchGroupIds) as? [String] { return array}
            return [String]()
        }
        set {
            updateArray(key: .watchGroupIds, value: newValue as [AnyObject], setDirties: true)
        }
    }
    var lastLogin: Date? {
        get {
            if let dateDictionary = getDictionary(key: .lastLogin) as? [String : Double] {
                return EJSON.convertToNSDate(dateDictionary as NSDictionary)
            }
            return nil
        }
        set {
            if let date = newValue {
                let dateDictionary: [String: Double] = EJSON.convertToEJSONDate(date)
                updateDictionary(key: .updatedAt, dictionary: dateDictionary as [String : AnyObject]?, setDirties: true)
            } else {
                updateDictionary(key: .updatedAt, dictionary: nil, setDirties: true)
            }
        }
        
    }
}
