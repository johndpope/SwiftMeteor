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
    class var findMethod: RVMeteorMethods { get { return RVMeteorMethods.FindBase}}
    class func createInstance(fields: [String : AnyObject])-> RVBaseModel { return RVBaseModel(fields: fields) }
    static var noID = "No_ID"
    var notSavedOnServer: Bool = false
    var listeners = [String]()
    var instanceType: String { get { return String(describing: type(of: self)) } }
    var rvFields: [String : AnyObject] { get { return getRVFields(onlyDirties: false) } }
    var initializing: Bool = true
    func getRVFields(onlyDirties: Bool) -> [String : AnyObject] {
        var dict = [String : AnyObject]()
        dict[RVKeys._id.rawValue] = self._id as AnyObject
        if !onlyDirties || (onlyDirties && self._modelType.dirty) {
            dict[RVKeys.modelType.rawValue] = self.modelType.rawValue as AnyObject
            self._modelType.dirty = false
        }
        if !onlyDirties || (onlyDirties && self._collection.dirty) {
            dict[RVKeys.collection.rawValue] = self.collection.rawValue as AnyObject
            self._collection.dirty = false
        }
        if !onlyDirties || (onlyDirties && self._parentModelType.dirty) {
            if let type = self.parentModelType {
                dict[RVKeys.parentModelType.rawValue] = type.rawValue as AnyObject
            } else {  dict[RVKeys.parentModelType.rawValue] = NSNull() }
            self._parentModelType.dirty = false
        }
        if !onlyDirties || (onlyDirties && self._ownerId.dirty) {
            if let ownerId = self.ownerId { dict[RVKeys.ownerId.rawValue] = ownerId as AnyObject
            } else {dict[RVKeys.ownerId.rawValue] = NSNull() }
            self._ownerId.dirty = false
        }
        if !onlyDirties || (onlyDirties && self._owner.dirty) {
            if let owner = self.owner { dict[RVKeys.owner.rawValue] = owner as AnyObject}
            else { dict[RVKeys.owner.rawValue] = NSNull()}
            self._owner.dirty = false
        }
        if !onlyDirties || (onlyDirties && self._username.dirty) {
            if let username = self.username { dict[RVKeys.owner.rawValue] = username as AnyObject }
            else { dict[RVKeys.username.rawValue] = NSNull() }
            self._username.dirty = false
        }
        if !onlyDirties || (onlyDirties && self._title.dirty) {
            if let title = self.title { dict[RVKeys.title.rawValue] = title as AnyObject }
            else { dict[RVKeys.title.rawValue] = NSNull() }
            self._title.dirty = false
        }
        if !onlyDirties || (onlyDirties && self._text.dirty) {
            if let text = self.text { dict[RVKeys.text.rawValue] = text as AnyObject }
            else { dict[RVKeys.text.rawValue] = NSNull() }
            self._text.dirty = false
        }
        if !onlyDirties || (onlyDirties && self._regularDescription.dirty) {
            if let regularDescription = self.regularDescription { dict[RVKeys.description.rawValue] = regularDescription as AnyObject }
            else { dict[RVKeys.description.rawValue] = NSNull() }
            self._regularDescription.dirty = false
        }
        if !onlyDirties || (onlyDirties && self._parentId.dirty) {
            if let parentId = self.parentId { dict[RVKeys.parentId.rawValue] = parentId as AnyObject }
            else { dict[RVKeys.parentId.rawValue] = NSNull() }
            self._parentId.dirty = false
        }
        if !onlyDirties {
            if let createdAt = self.createdAt { dict[RVKeys.createdAt.rawValue] = EJSON.convertToEJSONDate(createdAt) as AnyObject }
        }
        self._createdAt.dirty = false
        if !onlyDirties {
            if let updatedAt = self.updatedAt { dict[RVKeys.updatedAt.rawValue] = EJSON.convertToEJSONDate(updatedAt) as AnyObject }
        }
        self._updatedAt.dirty = false
        self._updatedAt.dirty = false
        if !onlyDirties || (onlyDirties && self._image.dirty) {
            if let image = self.image {
                dict[RVKeys.image.rawValue] = image.rvFields as AnyObject
            } else {
                dict[RVKeys.image.rawValue] = NSNull()
            }
            self._image.dirty = false
        }
        return dict
    }
    var dirties: [String: AnyObject] { get { return getRVFields(onlyDirties: true)} }

    init() {
        super.init(_id: Meteor.client.getId())
        initializeProperties()
        notSavedOnServer = true
        let me = type(of: self)
        self.collection = me.collectionType()
        self.modelType = self.collection
        setupCallback()
    }
    init(fields: [String : AnyObject]) {
        self.initializing = false
        var _id = RVBaseModel.noID
        if let actualId = fields[RVKeys._id.rawValue] as? String { _id = actualId
        } else {
            print("Error.......... \(type(of: self)).init(objects no ID provided")
        }
        super.init(_id: _id)
        self.update(fields as NSDictionary, cleared: nil)
        let me = type(of: self)
        if self.collection != me.collectionType() {
            self.collection = me.collectionType()
            self.modelType = self.collection
        }
        setupCallback()
    }
    
    required init(id: String, fields: NSDictionary?) {
        super.init(_id: id)
        self.initializing = false
        if let fields = fields {
            self.update(fields, cleared: nil)
        } else {
            print("Error initializing \(type(of: self)) fields did not cast as [String : AnyObject]")
        }
        setupCallback()
    }
    func initializeProperties() {
        
    }
    func setupCallback() {
        self._username.model = self
        self._ownerId.model = self
        self._owner.model = self
        self._parentId.model = self
        self._title.model = self
        self._text.model = self
        self._regularDescription.model = self
        self._createdAt.model = self
        self._updatedAt.model = self
        self._collection.model = self
        self._modelType.model = self
        self._parentModelType.model = self
    }
    override func update(_ fields: NSDictionary?, cleared: [String]?) {
        if let fields = fields as? [String : AnyObject] {
            for (key, value) in fields {
                if let key = RVKeys(rawValue: key) {
                   // print("In RVBaseModel.update \(key) to \(value)")
                   // if let value = value as? String { print("Value is a string: \(value)") }
                   // else { print("Value is not a string \(String(describing: value))") }
                    if !innerUpdate(key: key, value: value as AnyObject?) {
                        print("In \(instanceType).update, failed updating key: \(key) with value: \(value)")
                    }
                } else {
                    print("Erroneous field \(key) in updating a model")
                }
            }
        }
        if let cleared = cleared {
            for field in cleared {
                if let key = RVKeys(rawValue: field) {
                    let _ = innerUpdate(key: key, value: nil)
                }
            }
        }
    }
    func innerUpdate(key: RVKeys, value: AnyObject?) -> Bool {
        var found: Bool = true
        switch (key) {
        case ._id:
            found = true
            //print("In \(instanceType).innerUpdate, attempted to update _id (with \(value)). This should not happen")
            //found = false
        case .username:
            let _ = self._username.updateString(newValue: value)
        case .ownerId:
            let _ = self._ownerId.updateString(newValue: value)
        case .owner:
            let _ = self._owner.updateString(newValue: value)
        case .parentId:
            let _ = self._parentId.updateString(newValue: value)
        case .title:
            let _ = self._title.updateString(newValue: value)
        case .text:
            let _ = self._text.updateString(newValue: value)
        case .description:
            let _ = self._regularDescription.updateString(newValue: value)
        case .createdAt:
         //   print("Have Created at \(value)")
            let _ = self._createdAt.updateDateArray(newValue: value)
        case .updatedAt:
            let _ = self._updatedAt.updateDateArray(newValue: value)
        case .collection:
            if let rawValue = value as? String {
                if let _ = RVModelType(rawValue: rawValue) {
                    let _ = self._collection.updateString(newValue: value)
                }
            }
        case .modelType:
            if let rawValue = value as? String {
                if let _ = RVModelType(rawValue: rawValue) {
                    let _ = self._modelType.updateString(newValue: value)
                }
            }
        case .parentModelType:
            if let rawValue = value as? String {
                if let _ = RVModelType(rawValue: rawValue) {
                    let _ = self._parentModelType.updateString(newValue: value)
                }
            }
        case .image:
            if let value = value as? [String : AnyObject] {
               // let image = RVImage(objects: value)
               // print("Image source array = \(value)")
               // print("Image fields array = \(image.rvFields)")
                //self.image = image
                let _ = self._image.updateArray(newValue: value as AnyObject)
            } else if let value = value {
                if value as! NSObject == NSNull() {
                    let _ = self._image.updateArray(newValue: NSNull())
                } else {
                    print("In RVBaseModel.innerUpdate, value is not an Array. key: \(key), value: \(value)")
                }
            } else {
                let _ = self._image.updateArray(newValue: NSNull())
            }
        default:
            found = false
        }
        return found
    }

    var _modelType = RVRecord(fieldName: RVKeys.modelType)
    var modelType: RVModelType {
        get {
            if let rawValue = _modelType.value as? String {
                if let modelType = RVModelType(rawValue: rawValue) {
                    return modelType
                }
            }
            return RVModelType.unknownModel
        }
        set {
            let _ = _modelType.changeString(newValue: newValue.rawValue as AnyObject)
        }
    }
    var _ownerId = RVRecord(fieldName: RVKeys.ownerId)
    var ownerId: String? {
        get {
            if let string = _ownerId.value as? String { return string}
            return nil
        }
        set { let _ = _ownerId.changeString(newValue: newValue as AnyObject)}
    }
    var _owner = RVRecord(fieldName: RVKeys.owner)
    var owner: String? {
        get {
            if let string = _owner.value as? String { return string}
            return nil
        }
        set { let _ = _owner.changeString(newValue: newValue as AnyObject)}
    }
    var _parentId = RVRecord(fieldName: RVKeys.parentId)
    var parentId: String? {
        get {
            if let string = _parentId.value as? String { return string}
            return nil
        }
        set { let _ = _parentId.changeString(newValue: newValue as AnyObject)}
    }
    var _parentModelType = RVRecord(fieldName: RVKeys.parentModelType)
    var parentModelType: RVModelType? {
        get {
            if let rawValue = _parentModelType.value as? String {
                if let modelType = RVModelType(rawValue: rawValue) {
                    return modelType
                }
            }
            return nil
        }
        set {
            if let newValue = newValue {
                let _ = _parentModelType.changeString(newValue: newValue.rawValue as AnyObject)
            } else {
                let _ = _parentModelType.changeString(newValue: nil)
            }
            
        }
    }
    var _collection = RVRecord(fieldName: RVKeys.collection)
    var collection: RVModelType {
        get {
            if let rawValue = _collection.value as? String {
                if let modelType = RVModelType(rawValue: rawValue) {
                    return modelType
                }
            }
            return RVModelType.unknownModel
        }
        set {
            let _ = _collection.changeString(newValue: newValue.rawValue as AnyObject)
        }
    }
    var _title = RVRecord(fieldName: RVKeys.title)
    var title: String? {
        get {
            if let string = _title.value as? String { return string}
            return nil
        }
        set { let _ = _title.changeString(newValue: newValue as AnyObject)}
    }
    var _text = RVRecord(fieldName: RVKeys.text)
    var text: String? {
        get {
            if let string = _text.value as? String { return string}
            return nil
        }
        set { let _ = _text.changeString(newValue: newValue as AnyObject)}
    }
    var _regularDescription = RVRecord(fieldName: RVKeys.description)
    var regularDescription: String? {
        get {
            if let string = _regularDescription.value as? String { return string}
            return nil
        }
        set { let _ = _regularDescription.changeString(newValue: newValue as AnyObject)}
    }
    var _username = RVRecord(fieldName: RVKeys.username)
    var username: String? {
        get {
            if let string = _username.value as? String { return string}
            return nil
        }
        set { let _ = _username.changeString(newValue: newValue as AnyObject)}
    }
    var _image = RVRecord(fieldName: RVKeys.image)
    var image: RVImage? {
        get {
            if let imageArray = _image.value as? [String : AnyObject] {
                return RVImage(fields: imageArray)
            }
            return nil
        }
        set {
            if let image = newValue {
                let _ = _image.changeArray(newValue: image.rvFields as AnyObject?)
            } else {
                let _ = _image.changeArray(newValue: NSNull())
            }
            
        }
    }
    
    var _createdAt = RVRecord(fieldName: RVKeys.createdAt)
    var createdAt: Date? {
        get {
            if let dateArray = _createdAt.value as? [String: Double] {
                if let interval = dateArray[RVKeys.JSONdate.rawValue] {
                    return Date(timeIntervalSince1970: interval / 1000.0 )
                }
            }
            return nil
        }
        set {
            if let date = newValue {
                let dateArray: [String: Double] = EJSON.convertToEJSONDate(date)
                let _ = _createdAt.changeDateArray(newValue: dateArray as AnyObject)
            } else {
                let _ = _createdAt.changeDateArray(newValue: NSNull())
            }
        }

    }
    var _updatedAt = RVRecord(fieldName: RVKeys.updatedAt)
    var updatedAt: Date? {
        get {
            if let dateArray = _updatedAt.value as? [String: NSNumber] {
                if let interval = dateArray[RVKeys.JSONdate.rawValue] {
                    return Date(timeIntervalSince1970: interval.doubleValue / 1000.0 )
                }
            }
            return nil
        }
        set {
            if let date = newValue {
                let dateArray: [String: Double] = EJSON.convertToEJSONDate(date)
                let _ = _updatedAt.changeDateArray(newValue: dateArray as AnyObject)
            } else {
                let _ = _updatedAt.changeDateArray(newValue: nil)
            }
        }
    }
    func setParent(parent:RVBaseModel) {
        self.parentId = parent._id
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
                print("In \(classForCoder()).findInstance \(#line), no error but no result. id = \(id)")
                callback(nil, nil)
            }
        }
    }
    func create(callback: @escaping (_ error: RVError?) -> Void ) {
        var fields = self.rvFields
        fields.removeValue(forKey: RVKeys.createdAt.rawValue)
        fields.removeValue(forKey: RVKeys.updatedAt.rawValue)
        Meteor.call(type(of: self).insertMethod.rawValue, params: [fields]) {(result, error: DDPError?) in
            if let error = error {
                let rvError = RVError(message: "In \(self.instanceType).insert \(#line) got DDPError for id: \(self._id)", sourceError: error)
                callback(rvError)
            } else if let _ = result {
                self.initializing = false
                callback(nil)
            } else {
                print("In \(self.instanceType).insert \(#line), no error but no result. id = \(self._id)")
                callback(nil)
            }
        }
    }
    func update(callback: @escaping(_ error: RVError?) -> Void) {
        let dirties = self.dirties
    //    print("In \(self.instanceType).update, id: \(self._id) and dirties = \(dirties)")
    //    let updateDictionary = ["text": "updated description 555"]
        //[ self._id as AnyObject, self.dirties as AnyObject]
        if dirties.count <= 1 {
            callback(nil)
        } else {
            Meteor.call(type(of: self).updateMethod.rawValue, params: [ self._id as AnyObject, dirties as AnyObject]) { (result: Any? , error: DDPError?) in
                if let error = error {
                    let rvError = RVError(message: "In \(self.instanceType).update \(#line) got DDPError for id: \(self._id)", sourceError: error)
                    callback(rvError)
                } else if let _ = result {
                   // print("In \(self.instanceType).update result is \(result)")
                    callback(nil)
                } else {
                    print("In \(self.instanceType).update \(#line), no error but no result. id = \(self._id)")
                    callback(nil)
                }
            }
        }

    }
    func delete(callback: @escaping(_ error: RVError?) -> Void) {
        print("--------------------   In delete ---------------------------------")
        Meteor.call(type(of: self).deleteMethod.rawValue, params: [ self._id as AnyObject]) { (result: Any?, error: DDPError?) in
            if let error = error {
                let rvError = RVError(message: "In \(self.instanceType).delete \(#line) got DDPError for id: \(self._id)", sourceError: error)
                callback(rvError)
            } else if let _ = result {
                callback(nil)
            } else {
                print("In \(self.instanceType).delete \(#line), no error but no result. id = \(self._id)")
                callback(nil)
            }
        }
    }
    func toString() -> String {
        var output = "-------------------------------\(instanceType) instance --------------------------------\n"
        let id = self._id
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
            output = "\(output)ownerId = <nil>, "
        }
        if let regularDescription = regularDescription {
            output = "\(output)\nDescription = \(regularDescription)\n"
        } else {
            output = "\(output)\nDescription < no description>\n"
        }
        output = output + additionalToString()
        if let image = image {
            output = "\(output)image = id: \(image._id), \(image.rvFields), "
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
