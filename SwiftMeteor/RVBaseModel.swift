//
//  BaseModel.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 12/11/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import UIKit
import SwiftDDP

class RVBaseModel: MeteorDocument {
    class func collectionType() -> RVModelType { return RVModelType.baseModel }
    class var insertMethod: RVMeteorMethods { get { return RVMeteorMethods.InsertBase } }
    class var updateMethod: RVMeteorMethods { get { return RVMeteorMethods.UpdateBase } }
    class var deleteMethod: RVMeteorMethods { get { return RVMeteorMethods.DeleteBase } }
    class var bulkQueryMethod: RVMeteorMethods { get { return RVMeteorMethods.BulkTask } }
    class var findMethod: RVMeteorMethods { get { return RVMeteorMethods.FindBase}}
    class func createInstance(fields: [String : AnyObject])-> RVBaseModel { return RVBaseModel(fields: fields) }
    static var noID = "No_ID"
    var listeners = [String]()
    var instanceType: String { get { return String(describing: type(of: self)) } }
    var initializing: Bool = true
    var objects = [String: AnyObject]()
    var dirties = [String: AnyObject]()

    init() {
        let id = RVSwiftDDP.sharedInstance.getId()
        super.init(id: id, fields: self.objects as NSDictionary? )
        self.localId = id
        let me = type(of: self)
        self.collection = me.collectionType()
        self.modelType = self.collection
        initializeProperties()
    }
    func initializeProperties() {
        
    }
    func checkModelType() {
        if self.modelType == RVModelType.unknownModel || self.modelType != type(of: self).collectionType() {
            print("In \(instanceType).init invalid model type. Expected \(type(of: self).collectionType()), but received \(self.modelType.rawValue)")
        }
    }
    init(fields: [String : AnyObject]) {
        var _id = RVBaseModel.noID
        self.objects = fields
        if let actualId = fields[RVKeys._id.rawValue] as? String {
            _id = actualId
        } else {
            print("Error.......... \(type(of: self)).init(objects no ID provided")
        }
        super.init(id: _id, fields: self.objects as NSDictionary? )
        checkModelType()

    }
    required init(id: String, fields: NSDictionary?) {
        super.init(id: RVSwiftDDP.sharedInstance.getId(), fields: self.objects as NSDictionary? )
        if let objects = fields as? [String : AnyObject] {
            self.objects = objects
        } else {
            print("In \(instanceType).init fields did not cast as [String:AnyObject")
        }
        self.localId = id
        checkModelType()
    }


    var image: RVImage? {
        get {
            if let fields = objects[RVKeys.image.rawValue] as? [String: AnyObject] {
                return RVImage(fields: fields)
            }
            return nil
        }
        set {
            if let rvImage = newValue {
                updateDictionary(key: .image , value: rvImage.objects, setDirties: true)
            } else {
                updateDictionary(key: .image, value: nil, setDirties: true)
            }
        }
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
            return RVModelType.unknownModel
        }
        set {updateString(key: .modelType, value: newValue.rawValue, setDirties: true)}
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
    
    func updateDictionary(key: RVKeys, dictionary: [String: AnyObject]?, setDirties: Bool = false) {
        if let dictionary = dictionary {
            objects[key.rawValue] = dictionary as AnyObject?
            dirties[key.rawValue] = dictionary as AnyObject?
        } else {
            let existing = objects[key.rawValue]
            if let _ = existing as? NSNull {
                // do nothing
            } else {
                objects[key.rawValue] = NSNull()
                dirties[key.rawValue] = NSNull()
            }
        }
    }
    func updateAnyObject(key: RVKeys, value: AnyObject = NSNull(), setDirties: Bool = false) {
        objects[key.rawValue] = value
        if setDirties { dirties[key.rawValue] = value }
    }
    func updateDictionary(key: RVKeys, value: [String: AnyObject]? = nil, setDirties: Bool = false) {
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
                    self.updateBool(key: key, value: value , setDirties: setDirties)
                }
            } else {
                self.updateBool(key: key, value: value , setDirties: setDirties)
            }
        } else {
            if let _ = getBool(key: key) {
                // current a non-null value
                self.updateBool(key: key, value: nil, setDirties: setDirties)
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
                self.updateAnyObject(key: key, value: NSNull(), setDirties: setDirties)
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
                self.updateAnyObject(key: key, value: NSNull(), setDirties: setDirties)
            } else {
                // both new and existing are nil or non-existent; don't do anything
            }
        }
    }
    var localId: String? {
        get { return getString(key: RVKeys._id) }
        set { updateString(key: RVKeys._id, value: newValue, setDirties: true)}
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
            return RVModelType.unknownModel
        }
        set { updateString(key: RVKeys.parentModelType, value: newValue.rawValue, setDirties: true)}
    }
    
    var collection: RVModelType {
        get {
            if let rawValue = getString(key: .collection) {
                if let type = RVModelType(rawValue: rawValue) { return type}
            }
            return RVModelType.unknownModel
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
        set { updateString(key: RVKeys.commentLowercase, value: newValue, setDirties: true)}
    }

    var numberOfLikes: Int {
        get {
            if let number = getNSNumber(key: .numberOfLikes) { return number.intValue }
            return 0
        }
        set {
            updateNumber(key: .numberOfLikes, value: NSNumber(value:newValue), setDirties: true)
        }
    }
    var numberOfFollowers: Int {
        get {
            if let number = getNSNumber(key: .numberOfFollowers) { return number.intValue }
            return 0
        }
        set {
            updateNumber(key: .numberOfFollowers, value: NSNumber(value:newValue), setDirties: true)
        }
    }
    var numberOfObjections: Int {
        get {
            if let number = getNSNumber(key: .numberOfObjections) { return number.intValue }
            return 0
        }
        set {
            updateNumber(key: .numberOfObjections, value: NSNumber(value:newValue), setDirties: true)
        }
    }
    var score: Double {
        get {
            if let number = getNSNumber(key: .score) { return number.doubleValue }
            return 0.0
        }
        set {
            updateNumber(key: .score, value: NSNumber(value:newValue), setDirties: true)
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
    var handleLowercase: String? {
        get { return getString(key: RVKeys.handleLowercase) }
        set { updateString(key: RVKeys.handleLowercase, value: newValue, setDirties: true)}
    }
    var createdAt: Date? {
        get {
            if let dateDictionary = getDictionary(key: .createdAt) as? [String : Double] {
                if let interval = dateDictionary[RVKeys.JSONdate.rawValue] {
                    return Date(timeIntervalSince1970: interval / 1000.0 )
                }
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
                if let interval = dateDictionary[RVKeys.JSONdate.rawValue] {
                    return Date(timeIntervalSince1970: interval / 1000.0 )
                }
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
    func setParent(parent:RVBaseModel) {
        self.parentId = parent.localId
        self.parentModelType = parent.modelType
    }
}
extension RVBaseModel {
    class func retrieveInstance(id: String, callback: @escaping (_ item: RVBaseModel? , _ error: RVError?) -> Void) {
        Meteor.call(findMethod.rawValue, params: [ id as AnyObject]) { (result: Any?, error: DDPError?) in
            if let error = error {
                let rvError = RVError(message: "In \(classForCoder()).findInstance \(#line) got DDPError for id: \(id)", sourceError: error)
                callback(nil, rvError)
            } else if let fields = result as? [String : AnyObject] {
                callback(createInstance(fields: fields), nil)
            } else {
                print("In \(classForCoder()).findInstance \(#line), no error but no result for id = \(id)")
                callback(nil, nil)
            }
        }
    }
    func create(callback: @escaping (_ error: RVError?) -> Void ) {
        var fields = self.dirties
        self.dirties = [String : AnyObject]()
        fields.removeValue(forKey: RVKeys.createdAt.rawValue)
        fields.removeValue(forKey: RVKeys.updatedAt.rawValue)
        Meteor.call(type(of: self).insertMethod.rawValue, params: [fields]) {(result, error: DDPError?) in
            if let error = error {
                let rvError = RVError(message: "In \(self.instanceType).insert \(#line) got DDPError for id: \(self.localId)", sourceError: error)
                callback(rvError)
            } else if let result = result {
                print("In \(self.instanceType).created \(#line) successfully created \(self.localId) and result returned is \(result)")
                callback(nil)
            } else {
                print("In \(self.instanceType).insert \(#line), no error but no result. id = \(self.localId)")
                callback(nil)
            }
        }
    }
    func update(callback: @escaping(_ error: RVError?) -> Void) {
        let dirties = self.dirties
        self.dirties = [String: AnyObject]()
        print("------------- In \(self.instanceType).update, id: \(self.localId) and dirties = \(dirties)")
    //    let updateDictionary = ["text": "updated description 555"]
        //[ self._id as AnyObject, self.dirties as AnyObject]
        if dirties.count < 1 {
            callback(nil)
        } else {
            Meteor.call(type(of: self).updateMethod.rawValue, params: [ self.localId as AnyObject, dirties as AnyObject]) { (result: Any? , error: DDPError?) in
                if let error = error {
                    let rvError = RVError(message: "In \(self.instanceType).update \(#line) got DDPError for id: \(self.localId)", sourceError: error)
                    callback(rvError)
                } else if let _ = result {
                   // print("In \(self.instanceType).update result is \(result)") // typically get ["numberAffected": 1]
                    callback(nil)
                } else {
                    print("In \(self.instanceType).update \(#line), no error but no result. id = \(self.localId)")
                    callback(nil)
                }
            }
        }

    }
    class func modelFromFields(fields: [String: AnyObject]) -> RVBaseModel {
        return RVBaseModel(fields: fields)
    }
    class func bulkQuery(query: RVQuery, callback: @escaping(_ items: [RVBaseModel]?, _ error: RVError?)-> Void) {
        let (filters, projection) = query.query()
        Meteor.call(bulkQueryMethod.rawValue, params: [filters as AnyObject, projection as AnyObject]) { (result: Any?, error : DDPError?) in
            if let error = error {
                let rvError = RVError(message: "In RVBaseModel.bulkQuery, got Meteor Error", sourceError: error)
                callback(nil , rvError)
                return
            } else if let items = result as? [[String: AnyObject]] {
                var models = [RVBaseModel]()
                for fields in items {
                    models.append(modelFromFields(fields: fields))
                }
                callback(models, nil)
                return
            } else if let results = result {
                print("In RVBaseModel.bulkQuery, no error, but results are: \n\(results)")
                callback(nil, nil)
            } else {
                print("In RVBaseModel.bulkQuery, no error but no results")
                callback(nil, nil)
            }
        }
    }
    func delete(callback: @escaping(_ error: RVError?) -> Void) {
     //   print("--------------------   In \(self.instanceType) delete ---------------------------------")
        Meteor.call(type(of: self).deleteMethod.rawValue, params: [ self.localId as AnyObject]) { (result: Any?, error: DDPError?) in
            if let error = error {
                let rvError = RVError(message: "In \(self.instanceType).delete \(#line) got DDPError for id: \(self.localId)", sourceError: error)
                callback(rvError)
            } else if let _ = result {
                callback(nil)
            } else {
                print("In \(self.instanceType).delete \(#line), no error but no result. id = \(self.localId)")
                callback(nil)
            }
        }
    }
    func toString() -> String {
        var output = "-------------------------------\(instanceType) instance --------------------------------\n"
        let id = self.localId
            output = output + "_id = \(id), "

        output = "\(output) modelType = \(modelType.rawValue), collection = \(collection.rawValue) \n"
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
        if let ownerId = ownerId {
            output = "\(output)ownerId = \(ownerId), "
        } else {
            output = "\(output)ownerId = <nil>, \n"
        }
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
        output = output + additionalToString()
        if let image = image {
            output = "\(output)image = id: \(image.localId), \(image.objects), "
        } else {
            output = "\(output)\nimage = <no image>,"
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
        self.update { (error) in
            if let error = error {
                print("In \(self.instanceType).valueChanged error changingn \(field.rawValue) \(value). \n\(error)")
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
}
