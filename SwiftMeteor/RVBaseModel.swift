//
//  BaseModel.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 12/11/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import UIKit
import SwiftDDP

class RVBaseModel: RVSubbaseModel {


    func searchCountryForModel() -> RVCountry { return RVCountry.UnitedStates }
    static let UpdateNotificationName = Notification.Name("RVModelUpdated")
    class var insertMethod: RVMeteorMethods { get { return RVMeteorMethods.InsertBase } }
    class var updateMethod: RVMeteorMethods { get { return RVMeteorMethods.UpdateBase } }
    class var deleteMethod: RVMeteorMethods { get { return RVMeteorMethods.DeleteBase } }
    class var deleteAllMethod: RVMeteorMethods { get { return RVMeteorMethods.DeleteAllBase}}
    class var findOneMethod: RVMeteorMethods { get { return RVMeteorMethods.domainFindOne}}
    class var bulkQueryMethod: RVMeteorMethods { get { return RVMeteorMethods.BulkTask } }
    class var findMethod: RVMeteorMethods { get { return RVMeteorMethods.FindBase}}
//    class func createInstance(fields: [String : AnyObject])-> RVBaseModel { return RVBaseModel(fields: fields) }

    //static var noID = "No_ID"
    var listeners = [String]()
    var instanceType: String { get { return String(describing: type(of: self)) } }
    var initializing: Bool = true
    var objects = [String: AnyObject]()
    var dirties = [String: AnyObject]()
    var unsets  = [String: AnyObject]()
    var imageUpdated = false
    var locationInitiallyNull = false
    var userProfile: RVUserProfile? = nil
    var zeroCellModel: Bool = false
    var initialized: Bool = false
    static var coreInfo: RVBaseCoreInfo8    { return RVBaseCoreInfo8.sharedInstance }

    static var loggedInUser: RVUserProfile? { return coreInfo.loggedInUserProfile}
    static var loggedInUserId: String?      { return coreInfo.loggedInUserProfileId }
    static var appDomain: RVDomain?         { return coreInfo.domain }
    static var appDomainId: String?         { return coreInfo.domainId }

    init() {
        let id = RVSwiftDDP.sharedInstance.getId()
        super.init(id: id, fields: self.objects as NSDictionary? )
        self.localId = id
        initializeProperties()
        self.initialized = true
    }
    func initializeProperties() {
        self.modelType = type(of: self).collectionType()
        self.collection = self.modelType
        self.visibility = .publicVisibility
        self.validRecord = true
        self.deleted = false
        self.special = .regular
        self.archived = false
        self.searchCountry = self.searchCountryForModel()
        self.everywhere = false
        if let domain = RVBaseModel.appDomain {
            self.domainId = domain.localId
        } else {
            if self.modelType != .domain { print("In \(instanceType).init, don't have domain, model") }
        }
        if let profile = RVBaseModel.loggedInUser {
            self.setOwner(owner: profile)
        }
        checkEmbeddeds()
    }
    var basicQuery: (RVQuery, RVError?) {
        get {
            let query = RVQuery()
            var error: RVError? = nil
            query.addAnd(term: .modelType, value: self.modelType.rawValue as AnyObject, comparison: .eq)
            if let loggedInUserId = RVTransaction.loggedInUserId {
                query.addAnd(term: .ownerId, value: loggedInUserId as AnyObject, comparison: .eq)
            } else {
                error = RVError(message: "In \(self.classForCoder).basicQuery, no loggedInUserId")
            }
            if let domainId = RVTransaction.appDomainId {
                query.addAnd(term: .domainId, value: domainId as AnyObject, comparison: .eq)
            } else {
                error = RVError(message: "In \(self.classForCoder).basicQuery, no domainId")
            }
            return (query, error)
        }
    }
    func checkEmbeddeds() {
     //   if objects[RVKeys.image.rawValue] == nil {imageInitiallyNull = true}
        if objects[RVKeys.location.rawValue] == nil { locationInitiallyNull = true }
    }
    func checkModelType() {
        if self.modelType == RVModelType.unknown || self.modelType != type(of: self).collectionType() {
           // print("In \(instanceType).init with ID: \(self.localId), invalid model type. Expected \(type(of: self).collectionType()), but received \(self.modelType.rawValue), objectArray = \(self.objects[RVKeys.modelType.rawValue])\n\(objects)")
        }
    }
    init(fields: [String : AnyObject]) {
        var _id = RVSwiftDDP.sharedInstance.getId()
        var badId = true
        self.objects = fields
        if let actualId = fields[RVKeys._id.rawValue] as? String {
            _id = actualId
            badId = false
           // print("Have actual ID")
        } else {
            //print("In model init, don't have actual ID \(fields)")
        }
        //super.init(id: _id, fields: self.objects as NSDictionary? )
        super.init(id: _id, fields: NSDictionary() ) // Just neutralizing the parent class.
        self.localId = _id
        if badId && validRecord {
            print("Error.......... \(type(of: self)).init(objects no ID provided\n\(self.toString())")
        }

        checkModelType()
        checkEmbeddeds()
        self.initialized = true
    }
    required init(id: String, fields: NSDictionary?) {
        //super.init(id: id, fields: fields )
        super.init(id: id, fields: NSDictionary() ) // Just neutralizing the parent class.
        if let objects = fields as? [String : AnyObject] {
            self.objects = objects
        } else {
            print("In \(instanceType).init fields did not cast as [String:AnyObject")
        }
        self.localId = id
        checkModelType()
        checkEmbeddeds()
        self.initialized = true
    }

    override  func fields() -> NSDictionary  {
        return self.getFields() as NSDictionary
    }
    var archived: Bool {
        get {
            if let archived = getBool(key: .archived) { return archived }
            return false
        }
        set {
            updateBool(key: .archived, value: newValue, setDirties: true)
        }
    }
    private var _image: RVImage?
    var image: RVImage? {
        get {
            if let image = _image { return image }
            if let fields = objects[RVKeys.image.rawValue] as? [String: AnyObject] {
                let image = RVImage(fields: fields)
                if image.validRecord && !image.deleted {
                    print("In \(self.classForCoder).image valid")
                    self._image = image
                    self.objects.removeValue(forKey: RVKeys.image.rawValue)
                    return image
                } else if !image.deleted {
                    print("In \(self.classForCoder).image not deleted")
                    self._image = image
                    self.objects.removeValue(forKey: RVKeys.image.rawValue)
                    return image
                }
                return nil
            }
            return nil
        }
        set {
            if let rvImage = newValue {
                self.imageUpdated = true
                rvImage.setParent(parent: self)
                if let userProfile = RVBaseModel.loggedInUser {
                    rvImage.setOwner(owner: userProfile)
                    rvImage.fullName = userProfile.fullName
                }
                rvImage.domainId = RVBaseModel.appDomainId
               // rvImage.parentField = .image
                self._image = updateEmbeddedImage(current: self.image, newImage: rvImage)
                objects.removeValue(forKey: RVKeys.image.rawValue)
                dirties.removeValue(forKey: RVKeys.image.rawValue)
                unsets.removeValue(forKey: RVKeys.image.rawValue)
            } else {
                updateDictionary(key: .image, dictionary: nil, setDirties: true)
                _image = nil
            }
        }
    }

    var deleted: Bool {
        get {
            if let deleted = getBool(key: .deleted) { return deleted}
            return false
        }
        set { updateBool(key: .deleted, value: newValue, setDirties: true)}
    }
    var title: String? {
        get { return getString(key: RVKeys.title) }
        set { updateString(key: RVKeys.title, value: newValue, setDirties: true)}
    }
    var modelType: RVModelType {
        get {
            if let rawValue = getString(key: .modelType) {
                if let type = RVModelType(rawValue: rawValue) { return type}
            }
            return RVModelType.unknown
        }
        set {
            updateString(key: .modelType, value: newValue.rawValue, setDirties: true)
            self.collection = newValue
        }
    }
    var ownerModelType: RVModelType {
        get {
            if let rawValue = getString(key: .ownerModelType) {
                if let type = RVModelType(rawValue: rawValue) { return type}
            }
            return RVModelType.unknown
        }
        set {
            if (newValue != RVModelType.userProfile) { print("In \(self.classForCoder). ownerModelType being improperly set to : \(newValue.rawValue)") }
            updateString(key: .ownerModelType, value: newValue.rawValue, setDirties: true)
        }
    }
    func getString(key: RVKeys) -> String? {
        if let string = objects[key.rawValue] as? String { return string }
        return nil
    }
    func getDictionary(key: RVKeys) -> [String: AnyObject]? {
        if let dictionary = objects[key.rawValue] as? [String : AnyObject] { return dictionary }
        return nil
    }
    func getNSNumber(key: RVKeys) -> NSNumber? {
        if let number = objects[key.rawValue] as? NSNumber { return number }
        return nil
    }
    func getBool(key: RVKeys) -> Bool? {
        if let bool = objects[key.rawValue] as? Bool { return bool }
        return nil
    }
    func getArray(key: RVKeys) -> [AnyObject]? {
        if let array = objects[key.rawValue] as? [AnyObject] {return array }
        return nil
    }
    func updated(key: RVKeys, value: AnyObject?) {
        if !self.initialized { return }
       // print("In \(self.classForCoder).updated: \(key.rawValue) : \(String(describing: value))")
        let element : AnyObject = value != nil ? value! : NSNull()
        let userInfo = [key : element]
        NotificationCenter.default.post(name: RVBaseModel.UpdateNotificationName, object: self, userInfo: userInfo)
    }
    func updateDictionary(key: RVKeys, dictionary: [String: AnyObject]?, setDirties: Bool = false) {
        if let dictionary = dictionary {
            objects[key.rawValue] = dictionary as AnyObject?
            self.updated(key: key, value: dictionary as AnyObject)
            if setDirties {
                dirties[key.rawValue] = dictionary as AnyObject?
                unsets.removeValue(forKey: key.rawValue)
            }
        } else {
            if let _ = objects[key.rawValue] as? NSNull {
                unsetAnyObject(key: key, setDirties: setDirties)
                 self.updated(key: key, value: nil)
            } else if let _ = objects[key.rawValue] {
                updateAnyObject(key: key, value: NSNull() as AnyObject, setDirties: true)
            } else {
                self.updated(key: key, value: nil)
                if setDirties {
                    dirties.removeValue(forKey: key.rawValue)
                    unsets[key.rawValue] = "" as AnyObject
                }
            }
        }
    }
    func updateAnyObject(key: RVKeys, value: AnyObject = NSNull(), setDirties: Bool = false) {
        if let _ = value as? NSNull {
           unsetAnyObject(key: key, setDirties: setDirties)
        } else {
            objects[key.rawValue] = value
            self.updated(key: key, value: value)
            if setDirties {
                dirties[key.rawValue] = value
                unsets.removeValue(forKey: key.rawValue)
                
            }
        }

    }

    func updateArray(key: RVKeys, value: [AnyObject]? = nil, setDirties: Bool = false) {
        if let value = value {
            if let _ = objects[key.rawValue] {
                // Not going to do an actual compare
                self.updateAnyObject(key: key, value: value as AnyObject, setDirties: setDirties)
            } else {
                self.updateAnyObject(key: key, value: value as AnyObject, setDirties: setDirties)
            }
        } else {
            if let _ = objects[key.rawValue] {
                // currently a non-null value
                self.updateAnyObject(key: key, value: NSNull(), setDirties: setDirties)
            } else {
                // both new and existing are nil or non-existent; don't do anything
            }
        }
    }
    func updateBool(key: RVKeys, value: Bool? = nil, setDirties: Bool = false) {
        if let value = value {
            if let current = getBool(key: key) {
                if current != value {
                    self.updateAnyObject(key: key, value: value as AnyObject, setDirties: setDirties)
                }
            } else {
                self.updateAnyObject(key: key, value: value as AnyObject , setDirties: setDirties)
            }
        } else {
            if let _ = getBool(key: key) {
                // current a non-null value
                //self.updateAnyObject(key: key, value: NSNull(), setDirties: setDirties)
                self.unsetAnyObject(key: key, setDirties: setDirties)
            } else {
                // both new and existing are nil or non-existent; don't do anything
            }
        }
    }
    func updateString(key: RVKeys, value: String? = nil, setDirties: Bool = false) {
        if let value = value {
            if let current = getString(key: key) {
                if current == value {
                    // same value so do nothing
                } else {
                    self.updateAnyObject(key: key, value: value as AnyObject, setDirties: setDirties)
                }
            } else {
                // new value is non-null but existing value doesn't exist
                self.updateAnyObject(key: key, value: value as AnyObject, setDirties: setDirties)
            }
        } else {
            // new value is nil
            if let _ = getString(key: key) {
                // currently a non-null value
                //self.updateAnyObject(key: key, value: NSNull(), setDirties: setDirties)
                self.unsetAnyObject(key: key, setDirties: setDirties)
            } else {
                // both new and existing are nil or non-existent; don't do anything
            }
        }
    }
    func updateNumber(key: RVKeys, value: NSNumber? = nil, setDirties: Bool = false) {
        if let value = value {
            if let current = getNSNumber(key: key) {
                if current == value {
                    // same value so do nothing
                } else {
                    self.updateAnyObject(key: key, value: value as AnyObject, setDirties: setDirties)
                }
            } else {
                // new value is non-null but existing value doesn't exist
                self.updateAnyObject(key: key, value: value as AnyObject, setDirties: setDirties)
            }
        } else {
            // new value is nil
            if let _ = getString(key: key) {
                // currently a non-null value
                //self.updateAnyObject(key: key, value: NSNull(), setDirties: setDirties)
                self.unsetAnyObject(key: key, setDirties: setDirties)
            } else {
                // both new and existing are nil or non-existent; don't do anything
            }
        }
    }
    func unsetAnyObject(key: RVKeys, setDirties: Bool) {
        objects.removeValue(forKey: key.rawValue)
        self.updated(key: key, value: nil)
        if setDirties {
            dirties.removeValue(forKey: key.rawValue)
            unsets[key.rawValue] = "" as AnyObject
        }
    }
    var localId: String? {
        get { return getString(key: RVKeys._id) }
        set {
            updateString(key: RVKeys._id, value: newValue, setDirties: true)
            self.shadowId = newValue
        }
    }
    var value: String? {
        get { return getString(key: RVKeys.value) }
        set { updateString(key: RVKeys.value, value: newValue, setDirties: true)}
    }
    var ownerId: String? {
        get { return getString(key: RVKeys.ownerId) }
        set { updateString(key: RVKeys.ownerId, value: newValue, setDirties: true)}
    }
    
    var owner: String? {
        get { return getString(key: RVKeys.owner) }
        set { updateString(key: RVKeys.owner, value: newValue, setDirties: true)}
    }

    var parentId: String? {
        get { return getString(key: RVKeys.parentId) }
        set { updateString(key: RVKeys.parentId, value: newValue, setDirties: true)}
    }
    var parentModelType: RVModelType {
        get {
            if let rawValue = getString(key: .parentModelType) {
                if let type = RVModelType(rawValue: rawValue) { return type }
            }
            return RVModelType.unknown
        }
        set { updateString(key: RVKeys.parentModelType, value: newValue.rawValue, setDirties: true)}
    }
    var topParentId: String? {
        get { return getString(key: RVKeys.topParentId) }
        set { updateString(key: RVKeys.topParentId, value: newValue, setDirties: true)}
    }
    var topParentModelType: RVModelType {
        get {
            if let rawValue = getString(key: .topParentModelType) {
                if let type = RVModelType(rawValue: rawValue) { return type }
            }
            return RVModelType.unknown
        }
        set { updateString(key: RVKeys.topParentModelType, value: newValue.rawValue, setDirties: true)}
    }
    
    var collection: RVModelType {
        get {
            if let rawValue = getString(key: .collection) {
                if let type = RVModelType(rawValue: rawValue) { return type}
            }
            return RVModelType.unknown
        }
        set {updateString(key: .collection, value: newValue.rawValue, setDirties: true)}
    }

    var text: String? {
        get { return getString(key: RVKeys.text) }
        set { updateString(key: RVKeys.text, value: newValue, setDirties: true)}
    }
    
    var regularDescription: String? {
        get { return getString(key: RVKeys.regularDescription) }
        set { updateString(key: RVKeys.regularDescription, value: newValue, setDirties: true)}
    }

    var username: String? {
        get { return getString(key: RVKeys.username) }
        set { updateString(key: RVKeys.username, value: newValue, setDirties: true)}
    }
    var fullName: String? {
        get { return getString(key: RVKeys.fullName) }
        set {
            updateString(key: RVKeys.fullName, value: newValue, setDirties: true)
            if let value = newValue { self.fullNameLowercase = value.lowercased() }
            else { self.fullNameLowercase = nil }
            if let image = self.image {
                image.fullName = newValue
            }
            if let location = self.location {
                location.fullName = newValue
            }
        }
    }
    var fullNameLowercase: String? {
        get { return getString(key: RVKeys.fullNameLowercase) }
        set { updateString(key: RVKeys.fullNameLowercase, value: newValue, setDirties: true)}
    }
    var comment: String? {
        get { return getString(key: RVKeys.comment) }
        set {
            updateString(key: RVKeys.comment, value: newValue, setDirties: true)
            if let value = newValue { self.commentLowercase = value.lowercased() }
            else { self.commentLowercase = nil }
        }
    }
    var commentLowercase: String? {
        get { return getString(key: RVKeys.commentLowercase) }
        set {
            if let string = newValue {
                updateString(key: RVKeys.commentLowercase, value: string.lowercased(), setDirties: true)
            } else {
                updateString(key: RVKeys.commentLowercase, value: nil, setDirties: true)
            }
            
        }
    }
    func setLoggedInUserAsOwner() {
        if let userProfile = RVBaseModel.loggedInUser {
            self.setOwner(owner: userProfile)
        }
    }
    /*
    var parentField: RVKeys? {
        get {
            if let rawValue = getString(key: RVKeys.parentField) {
                if let field = RVKeys(rawValue: rawValue) { return field }
            }
            return nil
        }
        set {
            if let field = newValue {
                updateString(key: RVKeys.parentField, value: field.rawValue, setDirties: true)
            } else {
                updateString(key: RVKeys.parentField, value: nil, setDirties: true)
            }
        }
    }
 */
    var shadowId: String? {
        get { return getString(key: RVKeys.shadowId) }
        set { updateString(key: RVKeys.shadowId, value: newValue, setDirties: true)}
    }
    var numberOfMessages: Int? {
        get {
            if let number = getNSNumber(key: .numberOfMessages) { return number.intValue }
            return nil
        }
        set {
            let number: NSNumber? = (newValue != nil) ? NSNumber(value: newValue!) : nil
            updateNumber(key: .numberOfMessages, value: number, setDirties: true)
        }
    }
    var numberOfLikes: Int? {
        get {
            if let number = getNSNumber(key: .numberOfLikes) { return number.intValue }
            return nil
        }
        set {
            let number: NSNumber? = (newValue != nil) ? NSNumber(value: newValue!) : nil
            updateNumber(key: .numberOfLikes, value: number, setDirties: true)
        }
    }
    var numberOfFollowers: Int? {
        get {
            if let number = getNSNumber(key: .numberOfFollowers) { return number.intValue }
            return nil
        }
        set {
            let number: NSNumber? = (newValue != nil) ? NSNumber(value: newValue!) : nil
            updateNumber(key: .numberOfFollowers, value: number, setDirties: true)
        }
    }
    var numberOfObjections: Int? {
        get {
            if let number = getNSNumber(key: .numberOfObjections) { return number.intValue }
            return nil
        }
        set {
            let number: NSNumber? = (newValue != nil) ? NSNumber(value: newValue!) : nil
            updateNumber(key: .numberOfObjections, value: number, setDirties: true)
        }
    }
    var schemaVersion: Double? {
        get {
            if let number = getNSNumber(key: .schemaVersion) { return number.doubleValue }
            return nil
        }
        set {
            let number: NSNumber? = (newValue != nil) ? NSNumber(value: newValue!) : nil
            updateNumber(key: .schemaVersion, value: number, setDirties: true)
        }
    }
    var updateCount: Int? {
        get {
            if let number = getNSNumber(key: .updateCount) { return number.intValue }
            return nil
        }
        set {
            let number: NSNumber? = (newValue != nil) ? NSNumber(value: newValue!) : nil
            updateNumber(key: .updateCount, value: number, setDirties: true)
        }
    }
    var score: Double? {
        get {
            if let number = getNSNumber(key: .score) { return number.doubleValue }
            return nil
        }
        set {
            let number: NSNumber? = (newValue != nil) ? NSNumber(value: newValue!) : nil
            updateNumber(key: .score, value: number, setDirties: true)
        }
    }
    var tags: [String] {
        get {
            if let array = getArray(key: .tags) as? [String] { return array }
            return [String]()
        }
        set {
            updateArray(key: .tags, value: newValue as [AnyObject], setDirties: true)
        }
    }
    var special: RVSpecial {
        get {
            if let rawValue = getString(key: .special) {
                if let type = RVSpecial(rawValue: rawValue) { return type }
            }
            return RVSpecial.unknown
        }
        set { updateString(key: RVKeys.special, value: newValue.rawValue, setDirties: true)}
    }
    var handle: String? {
        get { return getString(key: RVKeys.handle) }
        set {
            updateString(key: RVKeys.handle, value: newValue, setDirties: true)
            if let value = newValue { self.handleLowercase = value.lowercased() }
            else { self.handleLowercase = nil }
        }
    }
    var specialCode: String? {
        get { return getString(key: RVKeys.specialCode) }
        set { updateString(key: RVKeys.specialCode, value: newValue, setDirties: true)}
    }
    var handleLowercase: String? {
        get { return getString(key: RVKeys.handleLowercase) }
        set { updateString(key: RVKeys.handleLowercase, value: newValue, setDirties: true)}
    }
    var searchCountry: RVCountry {
        get {
            if let rawValue = getString(key: .searchCountry) {
                if let country = RVCountry(rawValue: rawValue) { return country}
            }
            return RVCountry.Unknown
        }
        set { updateString(key: RVKeys.searchCountry, value: newValue.rawValue, setDirties: true) }
    }
    var everywhere: Bool {
        get {
            if let everywhere = getBool(key: .everywhere) { return everywhere }
            return false
        }
        set { updateBool(key: .everywhere, value: newValue, setDirties: true)}
    }
    var _location: RVLocation? = nil
    var location: RVLocation? {
        get {
            if let location = self._location { return location}
            if let fields = getDictionary(key: .location) {
                let location = RVLocation(fields: fields)
                if location.validRecord && !location.deleted {
                    self._location = location
                    return location
                }
                return nil
            }
            return nil
        }
        set {
            if let location = newValue {
                location.setParent(parent: self)
                location.domainId = RVBaseModel.appDomainId

                if let userProfile = RVBaseModel.loggedInUser {
                    location.fullName = userProfile.fullName
                    location.setOwner(owner: userProfile)
                }
  //              location.parentField = RVKeys.location
                _location = self.updateEmbeddedLocation(current: self.location, newLocation: location)
                objects.removeValue(forKey: RVKeys.location.rawValue)
                dirties.removeValue(forKey: RVKeys.location.rawValue)
                unsets.removeValue(forKey: RVKeys.location.rawValue)
            } else {
                updateDictionary(key: .location, dictionary: nil , setDirties: true)
                _location = nil
            }
        }
    }
    var createdAt: Date? {
        get {
            if let dateDictionary = getDictionary(key: .createdAt) as? [String : Double] {
                return EJSON.convertToNSDate(dateDictionary as NSDictionary)
            }
            return nil
        }
        set {
            if let date = newValue {
                let dateDictionary: [String: Double] = EJSON.convertToEJSONDate(date)
                updateDictionary(key: .createdAt, dictionary: dateDictionary as [String : AnyObject]?, setDirties: true)
            } else {
                updateDictionary(key: .createdAt, dictionary: nil, setDirties: true)
            }
        }

    }
    var updatedAt: Date? {
        get {
            if let dateDictionary = getDictionary(key: .updatedAt) as? [String : Double] {
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
    var visibility: RVVisibility {
        get {
            if let rawValue = getString(key: .visibility) {
                if let visibility = RVVisibility(rawValue: rawValue) { return visibility }
            }
            return RVVisibility.publicVisibility
        }
        set { updateString(key: .visibility, value: newValue.rawValue, setDirties: true)}
    }
    var orientation: RVImageOrientation? {
        get {
            if let rawValue = getString(key: .orientation) {
                if let orientation = RVImageOrientation(rawValue: rawValue) { return orientation}
            }
            return nil
        }
        set {
            if let orientation = newValue {
                updateString(key: .orientation, value: orientation.rawValue, setDirties: true)
            } else {
                updateString(key: .orientation, value: nil, setDirties: true)
            }
        }
    }
    var validRecord: Bool {
        get {
            if let valid = getBool(key: .validRecord) { return valid }
            return false
        }
        set {
            updateBool(key: .validRecord, value: newValue, setDirties: true)
        }
    }
    var domainId: String? {
        get { return getString(key: .domainId) }
        set {updateString(key: .domainId, value: newValue, setDirties: true) }
    }

    func setDomainId() { self.domainId = RVBaseModel.appDomainId }
    func getAppDomainId()-> String? { return RVBaseModel.appDomainId }
    func setParent(parent:RVBaseModel) {
        self.parentId = parent.localId
        self.parentModelType = parent.modelType
    }
    func setTopParent(topParent:RVBaseModel) {
        self.topParentId = topParent.localId
        self.topParentModelType = topParent.modelType
    }
    func setOwner(owner: RVBaseModel){
        self.ownerId = owner.localId
        if let rawValue = owner.objects[RVKeys.modelType.rawValue] as? String {
            if rawValue == "userProfile" {
                owner.modelType = RVModelType.userProfile
                owner.updateById(callback: { (model , error ) in
                    if let error = error {
                        error.append(message: "In \(self.classForCoder).setOwner")
                        error.printError()
                    } 
                })
            }
        }
        self.ownerModelType = owner.modelType
        if owner.modelType != RVModelType.userProfile {
            print("In \(self.classForCoder).setOwner, ownerModelTYpe is \(owner.modelType.rawValue)")
        }
    }
    override class var baseQuery: (RVQuery, RVError?) {
       // let query = RVQuery()
       // query.addAnd(term: .deleted, value: false as AnyObject, comparison: .eq)
       // return query
        
        
        get {
            let query = RVQuery()
            var error: RVError? = nil
            //query.addAnd(term: .modelType, value: RVModelType.transaction.rawValue as AnyObject, comparison: .eq)
            query.addAnd(term: .deleted, value: false as AnyObject, comparison: .eq)
            //query.addAnd(term: .deleted, value: false as AnyObject, comparison: .eq)
            //query.limit = 10
            if let loggedInUserId = RVTransaction.loggedInUserId {
                query.addAnd(term: .targetUserProfileId, value: loggedInUserId as AnyObject, comparison: .eq)
            } else {
                error = RVError(message: "In \(self.classForCoder).basicQuery, no loggedInUserId")
            }
            if let domainId = RVTransaction.appDomainId {
                query.addAnd(term: .domainId, value: domainId as AnyObject, comparison: .eq)
            } else {
                error = RVError(message: "In \(self.classForCoder).basicQuery, no domainId")
            }
            return (query, error)
        }
        
        
    }
    override func update(_ fields: NSDictionary?, cleared: [String]? ) {
        
        if let fields = fields as? [String : AnyObject] {
            for (rawValue, value) in fields {
                if let property = RVKeys(rawValue: rawValue) {
                    setProperty(key: property, value: value)
                }
            }
            
        }
        if let cleared = cleared {
            for index in (0..<cleared.count) {
                let rawValue = cleared[index]
                if let property = RVKeys(rawValue: rawValue) {
                    setProperty(key: property, value: nil)
                }
            }
        }
    }
}
extension RVBaseModel {
    class func retrieveInstance(id: String, callback: @escaping (_ item: RVBaseModel? , _ error: RVError?) -> Void) {
        print("In \(self.classForCoder()).retrieve meteorMethod: \(meteorMethod(request: .read))")
        Meteor.call(meteorMethod(request: .read), params: [ id as AnyObject]) { (result: Any?, error: DDPError?) in
     //   Meteor.call(findMethod.rawValue, params: [ id as AnyObject]) { (result: Any?, error: DDPError?) in
            if let error = error {
                let rvError = RVError(message: "In \(classForCoder()).findInstance \(#line) got DDPError for id: \(id)", sourceError: error)
                callback(nil, rvError)
            } else if var fields = result as? [String : AnyObject] {
 
                 //   print("In RVBaseModel.retrieve.... Image is \(fields ["image"])")
                if let rawValue = fields[RVKeys.modelType.rawValue] as? String {
                    if rawValue == "userProfile" {
                        fields[RVKeys.modelType.rawValue] = RVModelType.userProfile.rawValue as AnyObject
                    }
                }
                callback(modelFromFields(fields: fields), nil)
            } else {
                print("In RVBaseModel.findInstance \(#line), no error but no result for id = \(id)")
                callback(nil, nil)
            }
        }
    }
    /*
    class func deleteAll(callback: @escapideeeeeeng (_ error: RVError?) -> Void ) {
        Meteor.call(meteorMethod(request: .deleteAll), params: [Any]()) { (results, error) in

            if let error = error {
                let rvError = RVError(message: "In \(self.classForCoder()).deleteAll, got DDP Error", sourceError: error, lineNumber: #line)
                callback(error: rvError)
            } else {
                callback(nil)
            }
            
        }
 
    }
 */
    
    class func findOne(query: RVQuery, callback: @escaping(_ domain: RVBaseModel?, _ error: RVError?) -> Void) {
        //print("In \(self.classForCoder()).findOne, findOne method is: \(self.findOneMethod.rawValue)")
        let (filters, projection) = query.query()
        Meteor.call(meteorMethod(request: .read), params: [filters as AnyObject, projection as AnyObject]) { (result: Any?, error : DDPError?) in
        //Meteor.call(findOneMethod.rawValue, params: [filters as AnyObject, projection as AnyObject]) { (result: Any?, error : DDPError?) in
            if let error = error {
                let rvError = RVError(message: "In \(classForCoder()).findOne, got error", sourceError: error, lineNumber: #line, fileName: "")
                callback(nil, rvError)
                return
            } else if var fields = result as? [String: AnyObject] {
                if let rawValue = fields[RVKeys.modelType.rawValue] as? String {
                    if rawValue == "userProfile" {
                        fields[RVKeys.modelType.rawValue] = RVModelType.userProfile.rawValue as AnyObject
                    }
                }
                callback(modelFromFields(fields: fields), nil)
                return
            } else {
                print("In \(classForCoder()).findOne, no error but no result")
                callback(nil, nil)
            }
        }
    }
    func getFields() -> [String : AnyObject] {
        var fields = self.objects
        if let location = self.location { fields[RVKeys.location.rawValue] = location.getFields() as AnyObject }
        if let image = self.image { fields[RVKeys.image.rawValue] = image.getFields() as AnyObject }
        return fields
    }
    func dotNotation(topField: String, dictionary: inout [String: AnyObject], sourceDictionary: inout [String: AnyObject]) -> Void {
        sourceDictionary.removeValue(forKey: RVKeys.createdAt.rawValue)
        sourceDictionary.removeValue(forKey: RVKeys.updatedAt.rawValue)
        if topField == "" {
            for (key, value) in sourceDictionary {
                dictionary[key] = value
            }
        } else {
            for (key, value) in sourceDictionary {
                let dotKey = "\(topField).\(key)"
                dictionary[dotKey] = value
            }
        }
        //return dictionary
    }
    func returnDirtiesAndUnsets() -> ([String: AnyObject], [String: AnyObject]) {
        var dirties = [String: AnyObject]()
        var unsets = [String: AnyObject]()
        getDirtiesAndUnsets(topField: "", dirties: &dirties , unsets: &unsets)
        return (dirties, unsets)
    }
    func getDirtiesAndUnsets(topField: String, dirties: inout [String: AnyObject], unsets: inout [String: AnyObject]) -> Void {
        if (self.dirties.count > 0) || (self.unsets.count > 0) {
            if self.updateCount == nil { self.updateCount = 0 }
            else { self.updateCount = self.updateCount! + 1 }
        }
        var sourceDirties = self.dirties
        self.dirties = [String: AnyObject]()
        var sourceUnsets = self.unsets
        self.unsets = [String: AnyObject]()
        dotNotation(topField: topField, dictionary: &dirties, sourceDictionary: &sourceDirties)
        dotNotation(topField: topField, dictionary: &unsets, sourceDictionary: &sourceUnsets)
        
        if let location = self.location {
            if locationInitiallyNull {
                dirties[RVKeys.location.rawValue] = location.objects as AnyObject
            } else {
                let nextField = topField == "" ? RVKeys.location.rawValue : "\(topField).$.\(RVKeys.location.rawValue)"
                location.getDirtiesAndUnsets(topField: nextField, dirties: &dirties, unsets: &unsets)
            }
        }
        if let image = self.image {
            if imageUpdated {
                dirties[RVKeys.image.rawValue] = image.objects as AnyObject

            }
            /*
            if imageInitiallyNull {
                print("IN \(self.instanceType).getDirtiesAndUnsets, image is initially null. \(image.objects)")
                dirties[RVKeys.image.rawValue] = image.objects as AnyObject
            } else {
                print("In \(self.instanceType).getDirtiesAndUnsets haveImage")
                let nextField = topField == "" ? RVKeys.image.rawValue : "\(topField).$.\(RVKeys.image.rawValue)"
                print("NextField = \(nextField)")
                //image.getDirtiesAndUnsets(topField: nextField, dirties: &dirties, unsets: &unsets)
                dirties[RVKeys.image.rawValue] = image.objects as AnyObject
            }
 */
        }
    }
    func createTransaction(title: String) -> RVTransaction {
        let transaction = RVTransaction()
        transaction.title = title 
        transaction.topParentId = self.topParentId
        transaction.topParentModelType = self.topParentModelType
        transaction.parentId = self.parentId
        transaction.parentModelType = self.parentModelType
        transaction.transactionType = .added
        transaction.ownerId = self.ownerId
        transaction.fullName = self.fullName
        transaction.handle = self.handle
        transaction.domainId = self.domainId
        transaction.entityId = self.localId
        transaction.entityModelType = self.modelType
        transaction.entityTitle = self.title
        transaction.readState = .unread
        return transaction
    }
    func create(callback: @escaping (_ model: RVBaseModel?, _ error: RVError?) -> Void ) {
        if let loggedInUser = RVBaseModel.loggedInUser { self.setOwner(owner: loggedInUser) }
        else {
            callback(nil, RVError(message: "In \(self.classForCoder).create, no loggedInUser"))
            return
        }
        if let domainID = RVBaseModel.appDomainId { self.domainId = domainID }
        else {
            callback(nil, RVError(message: "In \(self.classForCoder).create, no domainId"))
            return
        }
        //self.setDomainId()
        var dirties = [String: AnyObject]()
        var unsets = [String: AnyObject]()
        getDirtiesAndUnsets(topField: "", dirties: &dirties , unsets: &unsets)
        let (tdirties, _) = createTransaction(title: "").returnDirtiesAndUnsets()
        if dirties.count <= 0 {print("In \(self.classForCoder).create, dirtiess count is erroneously zero")}
       // print("DIrties = \(dirties)")
        
        Meteor.call(type(of: self).meteorMethod(request: .create), params: [dirties, tdirties]) {(result, error: DDPError?) in
        // Meteor.call(type(of: self).insertMethod.rawValue, params: [dirties, tdirties]) {(result, error: DDPError?) in
            DispatchQueue.main.async {
                if let error = error {
                    let rvError = RVError(message: "In \(self.instanceType).insert \(#line) got DDPError for id: \(self.localId ?? " no localId")", sourceError: error)
                    callback(nil, rvError)
                } else if var field = result as? [String: AnyObject] {
                  //  print("In \(self.instanceType).created line \(#line) of RVBaseModel, successfully created \(self.localId)")
                    if let rawValue = field[RVKeys.modelType.rawValue] as? String {
                        if rawValue == "userProfile" {
                            field[RVKeys.modelType.rawValue] = RVModelType.userProfile.rawValue as AnyObject
                        }
                    }
                    callback(type(of: self).modelFromFields(fields: field),  nil)
                } else {
                    print("In \(self.instanceType).insert \(#line), no error but no casted result. id = \(self.localId ?? "No localId"). Result if any: \(result ?? "No result")")
                    callback(nil, nil)
                }
            }

        }
    }

    func setProperty(key: RVKeys, value: AnyObject?) {
        switch(key) {
        case .collection, ._id, .private, .username, .handle, .handleLowercase, .fullName, .fullNameLowercase, .owner, .ownerId, .parentId:
            print("In \(self.classForCoder).setProperty. Need to finish implementation")
 
        case .modelType, .parentModelType:
            if let rawValue = value as? String {
                if let type = RVModelType(rawValue: rawValue) {
                    if key == .modelType { self.modelType = type }
                    else if key == .parentModelType { self.parentModelType = type }
                    else {print("In \(self.instanceType).setProperty, key \(key.rawValue) no handled") }
                    return
                }
            }
            if value == nil {
                if key == .modelType {
                    print("In \(self.classForCoder).setProperty, erroneously attempted to set modelType to nil")
                }
                else if key == .parentModelType { self.parentModelType = RVModelType.unknown }
                else {print("In \(self.instanceType).setProperty, key \(key.rawValue) no handled") }
            }
        case .createdAt:
            if let dictionary = value as? [String : AnyObject] {
                let date = EJSON.convertToNSDate(dictionary as NSDictionary)
                self.createdAt = date
            } else if value == nil {
                self.createdAt = nil
            }
        case .updatedAt:
            if let dictionary = value as? [String : AnyObject] {
                let date = EJSON.convertToNSDate(dictionary as NSDictionary)
                self.updatedAt = date
            } else if value == nil {
                self.updatedAt = nil
            }
        default:
            print("")
        }

    }
    func embed(key: RVKeys, model: RVBaseModel) {
        
    }
    
    private func getUpdateFieldsInner() -> ([String: AnyObject], [String: AnyObject]) {
        let dirties = self.dirties
        let unsets = self.unsets
        self.dirties = [String: AnyObject]()
        self.unsets = [String: AnyObject]()
        return (dirties, unsets)
    }
    func getUpdateFields() -> ([String: AnyObject], [String: AnyObject]) {
        var (dirties, unsets) = getUpdateFieldsInner()
        if let image = self.image {
            let (imageDirties, imageUnsets) = image.getUpdateFields()
            print("In \(self.classForCoder), imageDirties = \(imageDirties.count) and unsets are \(imageUnsets.count)")
            if imageDirties.count > 0 { dirties[RVKeys.image.rawValue] = imageDirties as AnyObject }
            if imageUnsets.count > 0 { unsets[RVKeys.image.rawValue] = imageUnsets as AnyObject }
        } else {
            
        }
        if let location = self.location {
            let (locationDirties, locationUnsets) = location.getUpdateFields()
            if locationDirties.count > 0 { dirties[RVKeys.location.rawValue] = locationDirties as AnyObject }
            if locationUnsets.count > 0 { unsets[RVKeys.location.rawValue] = locationUnsets as AnyObject }
        } else {
            
        }
        return (dirties, unsets)
    }
    func updateById(callback: @escaping(_ updatedModel: RVBaseModel?, _ error: RVError?) -> Void) {
        var dirties = [String: AnyObject]()
        var unsets = [String: AnyObject]()
        getDirtiesAndUnsets(topField: "", dirties: &dirties , unsets: &unsets)
  //      dirties["location.title"] = "location title attempt" as AnyObject?
        if (dirties.count < 1) && (unsets.count < 1) {
            callback(self, nil)
        } else {
            Meteor.call(type(of: self).meteorMethod(request: .update), params: [ self.localId as AnyObject, dirties as AnyObject, unsets as AnyObject]) { (result: Any? , error: DDPError?) in
                DispatchQueue.main.async {
                    if let error = error {
                        let rvError = RVError(message: "In \(self.instanceType).updateById \(#line) got DDPError for id: \(self.localId ?? "NO LocalID")", sourceError: error)
                        callback(nil, rvError)
                        return
                    } else if var fields = result as? [String : AnyObject] {
                        // print("In \(self.instanceType).updateById result is \(result)\n------------------")
                        if let rawValue = fields[RVKeys.modelType.rawValue] as? String {
                            if rawValue == "userProfile" {
                                fields[RVKeys.modelType.rawValue] = RVModelType.userProfile.rawValue as AnyObject
                            }
                        }
                        callback(type(of: self).modelFromFields(fields: fields), nil)
                        return
                    } else {
                        print("In \(self.instanceType).updateById \(#line), no error but no result. id = \(self.localId ?? "No localId") \(result ?? " no result")")
                        callback(nil, nil)
                    }
                }
            }
        }

    }

    class func bulkQuery2<T>(query: RVQuery, callback: @escaping RVCallback<T>) {
        if let appDomainId = RVBaseModel.appDomainId { query.addAnd(term: .domainId, value: appDomainId as AnyObject, comparison: .eq) }
        
        let (filters, projection) = query.query()
        //print("In RVBaseModel.bulkQuery")
        Meteor.call(meteorMethod(request: .list), params: [filters as AnyObject, projection as AnyObject]) { (result: Any?, error : DDPError?) in
            //        Meteor.call(bulkQueryMethod.rawValue, params: [filters as AnyObject, projection as AnyObject]) { (result: Any?, error : DDPError?) in
            // print("In RVBaseModel.bulkQuery has response \(error), \(result)")
            DispatchQueue.main.async {
                var models = [T]()
                if let error = error {
                    let rvError = RVError(message: "In RVBaseModel.bulkQuery, got Meteor Error", sourceError: error)
                    callback(models , rvError)
                    return
                } else if let items = result as? [[String: AnyObject]] {
                    for fields in items {
                        if let model = modelFromFields(fields: fields) as? T {
                            models.append(model)
                        } else {
                            print("In \(self.classForCoder()).bulkQuery<T>, model did not match type \(T.self)")
                        }
                    }
                    callback(models, nil)
                    return
                } else if let results = result {
                    let rvError = RVError(message: "In RVBaseModel.bulkQuery, no error, but results are not array type. \nResults are: \(results)")
                    callback(models, rvError)
                } else {
                    print("In RVBaseModel.bulkQuery, no error but no results")
                    callback(models, nil)
                }
            }
        }
    }

    class func deleteAll( callback: @escaping(_ error: RVError?) -> Void ) {
        Meteor.call(meteorMethod(request: .deleteAll), params: [[RVKeys.specialCode.rawValue: RVBaseModel.coreInfo.specialCode]]) { (result, error: DDPError?) in
            DispatchQueue.main.async {
                if let error = error {
                    let rvError = RVError(message: "In RVBaseModel.deleteAll() got DDPError", sourceError: error, lineNumber: #line, fileName: "")
                    //rvError.printError()
                    callback(rvError)
                    return
                } else if let result = result {
                    print("In RVBaseModel.deleteAll(), result is \(result)")
                    callback(nil)
                } else {
                    print("In RVBaseModelGruop.deleteAll(), no error but no result")
                    callback(nil)
                }
            }

        }
    }
    func delete(callback: @escaping(_ number: Int, _ error: RVError?) -> Void) {
     //   print("--------------------   In \(self.instanceType) delete ---------------------------------")
        Meteor.call(type(of: self).meteorMethod(request: .delete), params: [ self.localId as AnyObject]) { (result: Any?, error: DDPError?) in
            DispatchQueue.main.async {
                if let error = error {
                    let rvError = RVError(message: "In \(self.instanceType).delete \(#line) got DDPError for id: \(self.localId ?? " no LocxalId")", sourceError: error)
                    callback(-1, rvError)
                } else if let count = result as? Int {
                    callback(count, nil)
                } else {
                    print("In \(self.instanceType).delete \(#line), no error but no result. id = \(self.localId ?? " no localId")")
                    callback(-1, nil)
                }
            }
        }
    }
    func addTerm(term: String, input: String, value: String?) -> String {
        if let value = value {
            return "\(input) \(term)= \(value), "
        } else {
            return "\(input) <no \(term)>, "
        }
    }
    func toString() -> String {
        var output = "-------------------------------\(instanceType) instance --------------------------------\n"
        let id = self.localId
            output = output + "_id = \(id ?? " no id"), "

        output = "\(output) modelType = \(modelType.rawValue), collection = \(collection.rawValue) \n"
        output = addTerm(term: "Shadow ID", input: output, value: self.shadowId)
        if let createdAt = self.createdAt {
            output = "\(output)createdAt = \(formatDate(date: createdAt as Date)), "
        } else {
            output = "\(output)createdAt = <nil>, "
        }
        if let updatedAt = self.updatedAt {
            output = "\(output)updatedAt = \(formatDate(date: updatedAt as Date))\n"
        } else {
            output = "\(output)updatedAt = <nil>\n"
        }
        if let title = title {
            output = "\(output)title = \(title), "
        } else {
            output = "\(output)title = <nil>, "
        }
        if let text = text  {
            output = "\(output)text = \(text)\n "
        } else {
            output = "\(output)text = <nil>\n"
        }
        if let username = username  {
            output = "\(output)username = \(username), "
        } else {
            output = "\(output)username = <nil>"
        }
        output = addTerm(term: "fullName", input: output, value: self.fullName)
        if let ownerId = ownerId {
            output = "\(output)ownerId = \(ownerId), "
        } else {
            output = "\(output)ownerId = <nil>, "
        }
        output = "\(output) ownerModelType = \(self.ownerModelType)\n"
        if let parentId = self.parentId {
            output = "\(output)parentId = \(parentId), "
            output = "\(output)parentModelType = \(self.parentModelType.rawValue)\n"
        } else {
            output = "\(output)parentId = <nil>\n"
        }
            output = "\(output)special = \(special.rawValue), "
        if let handle = handle {
            output = "\(output)handle = \(handle), "
        } else {
            output = "\(output)handle = <nil>, "
        }
        if let regularDescription = regularDescription {
            output = "\(output)\nDescription = \(regularDescription)\n"
        } else {
            output = "\(output)\nDescription < no description>\n"
        }
        if let comment = self.comment {
            output = "\(output)comment = \(comment)\n"
        } else {
            output = "\(output)comment <no comment>\n"
        }
        output = addTerm(term: "schemaVersion", input: output, value: "\(self.schemaVersion?.description ?? "No schemaVersion")")
        output = addTerm(term: "Update count", input: output, value: "\(self.updateCount?.description ?? " no updateCount")")
        output = "\(output), deleted: \(deleted), "
        output = "\(output), validRecord: \(validRecord), "
        output = addTerm(term: "domainId", input: output, value: self.domainId)
        output = output + additionalToString() + "\n"
        if let image = image {
            output = "\(output)image = \(image.toString()), "
        } else {
            output = "\(output)\nimage = <no image>,"
        }
        if let location = self.location {
            output = "\(output) \nLocation: \(location.toString())"
        } else {
            output = "\(output) <no location>"
        }
        output = output + "\n---------------------------------------------------------------------------------\n"
        return output
    }
    func additionalToString() -> String {
        return ""
    }
    func valueChanged(field: RVKeys, value: AnyObject?) {
       // print("IN value changed ------------------------")
        if initializing { return }
        self.updateById { (result, error) in
            if let error = error {
                print("In \(self.instanceType).valueChanged error changingn \(field.rawValue) \(value ?? " no value" as AnyObject). \n\(error)")
            }
        }
    }
    func addListener(name: String) {
        if let _ = listeners.index(where: {notification in return notification == name}) {
            // do nothing
        } else {
            var newListeners = self.listeners.map { $0 }
            newListeners.append(name)
            self.listeners = newListeners
        }
    }
    func removeListener(name: String) {
        var newListeners = self.listeners.map { $0 }
        newListeners.append(name)
        self.listeners = newListeners
        if let index = newListeners.index(where: {notification in return notification == name}) {
            newListeners.remove(at: index)
            self.listeners = newListeners
        } else {
            // do nothing
        }
    }
    func publish() {
        let listeners = self.listeners
        for listener in listeners {
            NotificationCenter.default.post(name: Notification.Name(rawValue: listener), object: nil, userInfo: ["model": self])
        }
    }
    func formatDate(date: Date) -> String {
        return "\(date)"
    }
    func printAllSubgroup() {
        var output = "AllSubgroup {"
        let domainId = self.domainId != nil ? "domainId: \(self.domainId!), " : "no DomainId"
        output = output + domainId
        let id = self.localId != nil ? "id: \(self.localId!), " : "noId, "
        output = output + id
        let title = self.title != nil ? "title: \(self.title!), " : "no Title, "
        output = output + title
        let createdAt = self.createdAt != nil ? "createdAt: \(self.createdAt!), " : "no CreatedAt, "
        output = output + createdAt
        output = output + "Special: \(self.special.rawValue), "
        output = output + "}\n"
        print(output)
    }
    
}
