//
//  RVUser.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/20/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
import SwiftDDP
class RVUserProfile: RVInterest {
    override class func collectionType() -> RVModelType { return RVModelType.userProfile }
    override class var insertMethod: RVMeteorMethods { get { return RVMeteorMethods.userProfileCreate } }
    override class var updateMethod: RVMeteorMethods { get { return RVMeteorMethods.userProfileUpdateById } }
    override class var deleteMethod: RVMeteorMethods { get { return RVMeteorMethods.userProfileDelete } }
    override class var findMethod: RVMeteorMethods { get { return RVMeteorMethods.userProfileFind}}
    override class var bulkQueryMethod: RVMeteorMethods { get { return RVMeteorMethods.userProfileBulkQuery } }

    override class func modelFromFields(fields: [String: AnyObject]) -> RVBaseModel { return RVUserProfile(fields: fields) }
    
    var firstName: String? {
        get { return getString(key: .firstName) }
        set {
            updateString(key: .firstName, value: newValue, setDirties: true)
            createFullName()
        }
    
    }
    var middleName: String? {
        get { return getString(key: .middleName) }
        set {
            updateString(key: .middleName, value: newValue, setDirties: true)
            createFullName()
        }
    }
    var lastName: String? {
        get { return getString(key: .lastName) }
        set {
            updateString(key: .lastName, value: newValue, setDirties: true)
            createFullName()
        }
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
                updateDictionary(key: .settings, dictionary: settings.objects, setDirties: true)
            } else {
                updateDictionary(key: .settings, dictionary: nil, setDirties: true)
            }
        }
    }
    var clientRole: RVClientRole {
        get {
            if let rawValue = getString(key: .clientRole) {
                if let role = RVClientRole(rawValue: rawValue) { return role }
            }
            return RVClientRole.regular
        }
        set { updateString(key: .clientRole, value: newValue.rawValue , setDirties: true)}
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
    var adminCodeZero: String? {
        get { return getString(key: .adminCodeZero) }
        set { updateString(key: .adminCodeZero, value: newValue, setDirties: true) }
    }
    var adminCodeOne: String? {
        get { return getString(key: .adminCodeOne) }
        set { updateString(key: .adminCodeOne, value: newValue, setDirties: true) }
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
    func createFullName() {
        var name = ""
        if let first = self.firstName {
            name = first
        }
        if let middle = self.middleName {
            if name == "" { name = middle }
            else {name = "\(name) \(middle)" }
        }
        if let last = self.lastName {
            if name == "" { name = last }
            else {name = "\(name) \(last)"}
        }
        if name == "" {
            if let email = self.email {
                self.fullName = email
            } else if let handle = self.handle {
                self.fullName = handle
            } else {
                self.fullName = "No Name"
            }
        } else {self.fullName = name}

    }
    override func additionalToString() -> String {
        
        var output = addTerm(term: "firstName", input: "", value: self.firstName)
        output = addTerm(term: "middleName", input: output, value: self.middleName)
        output = addTerm(term: "lastName", input: output, value: self.lastName) + "\n"
        if let yob = yob { output = addTerm(term: "yob", input: output, value: "\(yob)") }
        else { output = addTerm(term: "yob", input: output, value: nil) }
        output = addTerm(term: "clientRole", input: output, value: self.clientRole.rawValue)
        output = addTerm(term: "gender", input: output , value: self.gender.rawValue)
        output = addTerm(term: "email", input: output , value: self.email) + "\n"
        output = addTerm(term: "cellPhone", input: output, value: self.cellPhone)
        output = addTerm(term: "homePhone", input: output, value: self.homePhone)
        if self.watchGroupIds.count == 0 {
            output = "\(output) <zero WatchGroupIds>"
        } else {
            output = "\(output)\nWatchGroupIds: \(self.watchGroupIds)\n"
        }
        if let date = self.lastLogin { output = addTerm(term: "lastLogin", input: output, value: "\(date)") }
        else {output = addTerm(term: "lastLogin", input: output, value: nil)}
        return output
    }
    class func fakeIt() -> RVUserProfile {
        let profile = RVUserProfile()
        profile.firstName = "John"
        profile.middleName = "Neil"
        profile.lastName = "Weintraut"
        profile.fullName = "John Neil Weintraut"
        profile.handle = "someHandle"
        profile.username = "someUserName"
        profile.regularDescription = "Some regular description"
        profile.title = "A Title"
        profile.comment = "A comment"
        profile.text = "Some text"
        profile.value = "Some value"
        profile.yob = 1958
        profile.gender = .male
        profile.watchGroupIds = ["ABCD", "zyxw", "555"]
        profile.lastLogin = Date()
        profile.clientRole = .admin
        profile.parentId = "parentId###"
        profile.parentModelType = RVModelType.task
        profile.domainId = "domainId###"
        profile.schemaVersion = 15
        profile.special = RVSpecial.root
        profile.deleted = false
        profile.cellPhone = "6503946345"
        profile.homePhone = "6508515212"
        profile.email = "neil.weintraut@gmail.com"
        let image = RVImage.fakeIt()
        //print(image.toString())
        profile.image = image
        let location = RVLocation.fakeIt()
        profile.location = location
        return profile
    }
    class func findById(id: String, callback: @escaping (_ profile: RVUserProfile?, _ error: RVError?) -> Void ) {
        let minimumLength = 9
        let maximumLength = 30
        if (id.characters.count < minimumLength) || (id.characters.count > maximumLength) {
            let error = RVError(message: "In RVUserProfile.findById, id [\(id)] is erroneously less than \(minimumLength) or more than maximum length \(maximumLength)")
            callback(nil, error)
            return
        } else {
            Meteor.call(RVMeteorMethods.userProfileFind.rawValue, params: [id], callback: { (result, error) in
                if let error = error {
                    let rvError = RVError(message: "In RVUserProfile.findById, got error", sourceError: error, lineNumber: #line, fileName: "")
                    callback(nil, rvError)
                    return
                } else if let fields = result as? [String : AnyObject] {
                    callback(RVUserProfile(fields: fields), nil)
                    return
                } else {
                    callback(nil, nil)
                }
            })
        }
    }
    class func getOrCreateUsersUserProfile(callback: @escaping (_ profile: RVUserProfile?, _ error: RVError?) -> Void ) {
        let profile = RVUserProfile()
        profile.username = RVCoreInfo.sharedInstance.username
        var fields = profile.dirties
        fields.removeValue(forKey: RVKeys.createdAt.rawValue)
        fields.removeValue(forKey: RVKeys.updatedAt.rawValue)
        profile.dirties = [String : AnyObject]()
        Meteor.call(RVMeteorMethods.getOrCreateUserUserProfile.rawValue, params: [fields]) {(result, error: DDPError?) in
            if let error = error {
                let rvError = RVError(message: "In RVUserProfile.getOrCreateUsersUserProfile \(#line) got DDPError for id: \(profile.localId)", sourceError: error)
                callback(nil, rvError)
            } else if let fields = result as? [String: AnyObject] {
                if let _ = fields["newProfile"] as? Bool {
                    print("In \(type(of: self)).getOrCreate, have a new Profile")
                    if let id = fields["_id"] as? String {
                        RVUserProfile.retrieveInstance(id: id, callback: { (model, error ) in
                            if let error = error {
                                let rvError = RVError(message: "In RVUserProfile.got error retrieving \(id)", sourceError: error, lineNumber: #line, fileName: "")
                                callback(nil, rvError)
                            } else if let profile = model as? RVUserProfile {
                                callback(profile, nil)
                                return
                            } else {
                                let error = RVError(message: "In RVUserProfile.getOrCreate... failed to retrieve profile with id \(id)")
                                callback(nil, error)
                                return
                            }
                        })
                        return
                    } else {
                        let rvError = RVError(message: "In RVUserProfile.getOrCreate.... got indication of new Profile, but no id provided")
                        callback(nil, rvError)
                        return
                    }
                } else {
                   // print("Existing profile")
                    callback(RVUserProfile(fields: fields), nil)
                    return
                }
            } else {
                print("In RVUserProfile.getOrCreateUsersUserProfile \(#line), no error but no result. id = \(profile.localId)")
                callback(nil, nil)
            }
        }
    }
}
extension RVUserProfile {
    class func clearAll() {
        Meteor.call("userProfile.clear", params: nil) { (result, error: DDPError?) in
            if let error = error {
                let rvError = RVError(message: "In RVUserProfile.clearAll() got DDPError", sourceError: error, lineNumber: #line, fileName: "")
                rvError.printError()
            } else if let result = result {
                print("In RVUserProfile.clearAll(), result is \(result)")
            } else {
                print("In RVUserProfile.clearAll(), no error but no result")
            }
        }
    }
}
