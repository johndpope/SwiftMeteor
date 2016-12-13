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

    class var insertMethod: RVMeteorMethods {
        get {
            return RVMeteorMethods.InsertBase
        }
    }
    static var noID = "No_ID"
    var noID: Bool = true
    var objects = [String : AnyObject]()
    var dirties = [String : AnyObject]()
    var instanceType: String {
        get {
            return String(describing: type(of: self))
        }
    }
    var fieldsAndId: (String, [String: AnyObject]) {
        get {
            var dictionary = [String : AnyObject]()
            for (key, value) in self.objects {
                dictionary[key] = value
            }
            return (self._id, dictionary)
        }
    }
    var fieldsWithId: [String : AnyObject] {
        get {
            var dictionary = [String : AnyObject]()
            for (key, value) in self.objects {
                dictionary[key] = value
            }
            dictionary[RVKeys._id.rawValue] = self._id as AnyObject?
            return dictionary
        }
    }
    init() {
        super.init(_id: RVBaseModel.noID)
        self.noID = true
        let me = type(of: self)
        self.collection = me.collectionType()
        self.modelType = self.collection
    }
    init(objects: [String : AnyObject]) {
        self.objects = objects
        if let _id = objects[RVKeys._id.rawValue] as? String {
            super.init(_id: _id)
        } else {
            self.noID = true
            super.init(_id: RVBaseModel.noID)
        }
        let me = type(of: self)
        if self.collection != me.collectionType() {
            self.collection = me.collectionType()
            self.modelType = self.collection
        }
    }
    
    required init(id: String, fields: NSDictionary?) {
        super.init(_id: id)
        if let fields = fields as? [String: AnyObject] {
            self.objects = fields
        } else {
            print("Error initializing \(type(of: self)) fields did not cast as [String : AnyObject]")
        }
        print(toString())
    }
    override func fields() -> NSDictionary {
        var (id, dictionary) = fieldsAndId
        if (id != RVBaseModel.noID) {
            dictionary[RVKeys._id.rawValue] = id as AnyObject?
        }
        return dictionary as NSDictionary
    }
    override func update(_ fields: NSDictionary?, cleared: [String]?) {
        if let fields = fields {
            for (key, value) in fields {
                if let key = key as? String {
                    if let key = RVKeys(rawValue: key) {
                        let _ = innerUpdate(key: key, value: value as AnyObject?)
                    } else {
                        print("Erroneous field \(key) in updating a model")
                    }
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
        case ._id, .username,.ownerId, .owner, .parentId,.title, .text, .description :
            if let value = value as? String? {
                updateString(key: key, value: value)
            } else {
                print("In RVBaseModel.innerUpdate, value is not a String?. key: \(key), value: \(value)")
            }
        case .createdAt, .updatedAt:
            if let value = value as? [String : Double] {
                updateDateTime(key: key.rawValue, value: value)
            } else if value == nil {
                setToValue(key: key.rawValue, value: NSNull())
            } else {
                print("In RVBaseModel.innerUpdate, value is not an Array. key: \(key), value: \(value)")
            }
        case .collection, .modelType, .parentModelType:
            if let value = value as? String {
                if let type = RVModelType(rawValue: value) {
                    if key == RVKeys.collection {
                        self.collection = type
                    } else if key == RVKeys.modelType {
                        self.modelType = type
                    } else if key == RVKeys.parentModelType {
                        self.parentModelType = type
                    }
                } else {
                    
                }
            } else {
                
            }
        case .image:
            if let value = value as? [String : AnyObject] {
                let image = RVImage(objects: value)
                self.image = image
            } else if value == nil {
                setToValue(key: key.rawValue, value: NSNull())
            } else {
                print("In RVBaseModel.innerUpdate, value is not an Array. key: \(key), value: \(value)")
            }
        default:
            print("In RVBaseModel.innerUpdate, no case for key: \(key.rawValue) with value: \(value)")
            found = false
        }
        return found
    }
    class func collectionType() -> RVModelType {
        return RVModelType.baseModel
    }
    private func scrubbedFields(fields: [RVKeys: AnyObject]) -> [String: AnyObject] {
        var scrubbed = [String : AnyObject ]()
        for (key, value) in fields {
            if let value = value as? [RVKeys: AnyObject] {
                let scrubbedValue = self.scrubbedFields(fields: value) as AnyObject
                scrubbed[key.rawValue] = scrubbedValue
            } else {
                scrubbed[key.rawValue] = value
            }
        }
        return scrubbed
    }

    var modelType: RVModelType {
        get {
            if let rawValue = getString(key: RVKeys.modelType) {
                if let modelType = RVModelType(rawValue: rawValue) { return modelType }
                return RVModelType.unknownModel
            } else {
                return RVModelType.unknownModel
            }
        }
        set { updateString(key: RVKeys.modelType, value: newValue.rawValue) }
    }
    var ownerId: String? {
        get { return getString(key: RVKeys.ownerId) }
        set { updateString(key: RVKeys.ownerId, value: newValue) }
    }
    var owner: String? {
        get { return getString(key: RVKeys.owner) }
        set { updateString(key: RVKeys.owner, value: newValue) }
    }
    var parentId: String? {
        get { return getString(key: RVKeys.parentId) }
        set { updateString(key: RVKeys.parentId, value: newValue) }
    }
    var parentModelType: RVModelType {
        get {
            if let rawValue = getString(key: RVKeys.parentModelType) {
                if let modelType = RVModelType(rawValue: rawValue) { return modelType }
                return RVModelType.unknownModel
            } else {
                return RVModelType.unknownModel
            }
        }
        set { updateString(key: RVKeys.parentModelType, value: newValue.rawValue) }
    }
    var collection: RVModelType {
        get {
            if let rawValue = objects[RVKeys.collection.rawValue] as? String {
                if let type = RVModelType(rawValue: rawValue) {
                    return type
                }
            }
            return RVModelType.unknownModel
        }
        set { updateString(key: RVKeys.collection, value: newValue.rawValue) }
    }
    var title: String? {
        get { return getString(key: RVKeys.title) }
        set { updateString(key: RVKeys.title, value: newValue) }
    }
    var text: String? {
        get { return getString(key: RVKeys.text) }
        set { updateString(key: RVKeys.text, value: newValue) }
    }
    var regularDescription: String? {
        get { return getString(key: RVKeys.description) }
        set { updateString(key: RVKeys.description, value: newValue) }
    }
    var username: String? {
        get { return getString(key: RVKeys.username) }
        set { updateString(key: RVKeys.username, value: newValue) }
    }
    func getString(key: RVKeys) -> String? {
        if let value = objects[key.rawValue] as? String { return value }
        else { return nil }
    }
    func setToNSNull(key: String) {
        objects[key] = NSNull()
        dirties[key] = NSNull()
        ///super.update(nil, cleared: [key])
    }
    func setToValue(key: String, value: AnyObject) {
        objects[key] = value
        dirties[key] = value
       // super.update([key: value], cleared: nil)
    }
    func updateString(key: RVKeys, value: String? ) {
        updateString(key: key.rawValue, value: value)
    }

    func updateString(key: String, value: String?) {
        if let current = objects[key] {
            if let current = current as? String {
                // There is a current value and that value is a String
                if let value = value {
                    if current == value {
                        // do nothing
                    } else {
                        // value exists and not equal to current
                        setToValue(key: key, value: value as AnyObject )
                    }
                } else {
                    // new Value is nil
                    setToNSNull(key: key)
                }
            } else {
                // Current Value assumed to be NSNull
                if let value = value {
                    setToValue(key: key, value: value as AnyObject)
                } else {
                    setToNSNull(key: key)
                }
            }
        } else {
            // No current value so can just update
            if let value = value {
                setToValue(key: key, value: value as AnyObject)
            } else {
                setToNSNull(key: key)
            }
        }
    }
    func updateNumber(key: String, value: NSNumber?) {
        print("In updateNumber: \(key) \(value)")
        if let current = objects[key] {
            if let current = current as? NSNumber {
                // There is a current value and that value is a Number
                if let value = value {
                    if current == value {
                        // do nothing
                    } else {
                        // value exists and not equal to current
                        setToValue(key: key, value: value as AnyObject )
                    }
                } else {
                    // new Value is nil
                    setToNSNull(key: key)
                }
            } else {
                // Current Value assumed to be NSNull
                if let value = value {
                    setToValue(key: key, value: value as AnyObject)
                } else {
                    setToNSNull(key: key)
                }
            }
        } else {
            // No current value so can just update
            if let value = value {
                setToValue(key: key, value: value as AnyObject)
            } else {
                setToNSNull(key: key)
            }
        }
    }
    func updateDateTime(key: String, value: [String: Double]) {
        if let current = objects[key] {
            if let current = current as? [String : Double] {
                // There is a current value and that value is an Array
                if let currentNumber = current[RVKeys.JSONdate.rawValue] {
                    if let newValue = value[RVKeys.JSONdate.rawValue] {
                        if currentNumber == newValue {
                            // do nothing
                        } else {
                            setToValue(key: key, value: value as AnyObject )
                        }
                    } else {
                        // wrong submission
                        print("RVBaseModel Attempted to update a date that isn't a NSNumber")
                    }
                } else {
                    setToValue(key: key, value: value as AnyObject)
                }
            } else {
                // Current Value assumed to be NSNull
                setToValue(key: key, value: value as AnyObject)
            }
        } else {
            // No current value so can just update
            setToValue(key: key, value: value as AnyObject)
        }
    }
    
    func setArray(key: String, value: [String: AnyObject]? ) {
        if let value = value {
            objects[key] = value as AnyObject
            dirties[key] = value as AnyObject
        } else {
            objects[key] = NSNull()
            dirties[key] = NSNull()
        }
    }
    var image: RVImage? {
        get {
            if let image = objects[RVKeys.image.rawValue] as? [String: AnyObject] {
                return RVImage(objects: image)
            }
            return nil
        }
        set {
            if let value = newValue {
                setArray(key: RVKeys.image.rawValue, value: value.objects )
            } else {
                setArray(key: RVKeys.image.rawValue, value: nil)
            }
        }
    }
    var createdAt: Date? {
        get {
            if let dateArray = objects[RVKeys.createdAt.rawValue] as? [String : NSNumber] {
                if let interval = dateArray[RVKeys.JSONdate.rawValue] {
                    return Date(timeIntervalSince1970: interval.doubleValue / 1000.0 )
                }
            }
            return nil
        }
        set {
            // do nothing
        }
    }
    var updatedAt: Date? {
        get {
            if let dateArray = objects[RVKeys.updatedAt.rawValue] as? [String : NSNumber] {
                if let interval = dateArray[RVKeys.JSONdate.rawValue] {
                    return Date(timeIntervalSince1970: interval.doubleValue / 1000.0 )
                }
            }
            return nil
        }
        set {
            if let dateValue = newValue {
                updateDateTime(key: RVKeys.updatedAt.rawValue, value: EJSON.convertToEJSONDate(dateValue))
            }
        }
    }

    
}
extension RVBaseModel {
    func insert(callback: @escaping (_ error: RVError?) -> Void ) {
        objects.removeValue(forKey: RVKeys._id.rawValue)
        Meteor.call(RVMeteorMethods.InsertImage.rawValue , params: [objects]) { (result, error: DDPError? ) in
            if let error = error {
                let rvError = RVError(message: "RVBaseModel.insert, got DDPError", sourceError: error)
                callback(rvError)
            } else if let result = result {
                print("In RVBaseModel.insert, have result \(result)")
                callback(nil)
            } else {
                print("In RVBaseModel.insert no error no result")
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
        if let image = image {
            output = "\n\(output)\nimage = id: \(image._id), \(image.objects), "
        } else {
            output = "\n\(output)\nimage = <no image>,"
        }
        output = output + "\n---------------------------------------------------------------------------------\n"
        return output
    }
    func formatDate(date: Date) -> String {
        return "\(date)"
    }
}
