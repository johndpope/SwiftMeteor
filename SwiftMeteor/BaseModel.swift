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
    enum key: String {
        case _id = "_id"
        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
        case `private` = "private"
        case username  = "username"
        case modelType = "modelType"
        case ownerId   = "ownerId"
        case parentId  = "parentId"
        case parentModelType = "parentModelType"
        case title     = "title"
        case `description` = "description"
        case JSONdate     = "$date"
        case image     = "image"
    }
    class var insertMethod: RVMeteorMethods {
        get {
            return RVMeteorMethods.InsertBase
        }
    }
    var badID: Bool = true
    var objects = [String : AnyObject]()
    var dirties = [String : AnyObject]()

    init(objects: [String : AnyObject]) {
        self.objects = objects
        if let id = self.objects[RVBaseModel.key._id.rawValue] as? String {
            self.objects[RVBaseModel.key._id.rawValue] = id as AnyObject
            super.init(id: id, fields: NSDictionary(dictionary: objects))
        } else {
            super.init(id: "NO_ID", fields: NSDictionary(dictionary: objects))
            self.badID = true
        }
    }
    
    required init(id: String, fields: NSDictionary?) {
        if let fields = fields as? [String: AnyObject] {
            self.objects = fields
            self.objects[RVBaseModel.key._id.rawValue] = id as AnyObject 
        } else {
            print("Error initializing RVBaseModel")
        }
        super.init(id: id, fields: fields)
    }
    private func scrubbedFields(fields: [RVBaseModel.key: AnyObject]) -> [String: AnyObject] {
        var scrubbed = [String : AnyObject ]()
        for (key, value) in fields {
            if let value = value as? [RVBaseModel.key: AnyObject] {
                let scrubbedValue = self.scrubbedFields(fields: value) as AnyObject
                scrubbed[key.rawValue] = scrubbedValue
            } else {
                scrubbed[key.rawValue] = value
            }
        }
        return scrubbed
    }
    var _id: String? {
        get { return getString(key: RVBaseModel.key._id) }
        set { updateString(key: RVBaseModel.key._id, value: newValue) }
    }
    var modelType: RVModelType {
        get {
            if let rawValue = getString(key: RVBaseModel.key.modelType) {
                if let modelType = RVModelType(rawValue: rawValue) { return modelType }
                return RVModelType.unknownModel
            } else {
                return RVModelType.unknownModel
            }
        }
        set { updateString(key: RVBaseModel.key.modelType, value: newValue.rawValue) }
    }
    var ownerId: String? {
        get { return getString(key: RVBaseModel.key.ownerId) }
        set { updateString(key: RVBaseModel.key.ownerId, value: newValue) }
    }
    var parentId: String? {
        get { return getString(key: RVBaseModel.key.parentId) }
        set { updateString(key: RVBaseModel.key.parentId, value: newValue) }
    }
    var parentModelType: RVModelType {
        get {
            if let rawValue = getString(key: RVBaseModel.key.parentModelType) {
                if let modelType = RVModelType(rawValue: rawValue) { return modelType }
                return RVModelType.unknownModel
            } else {
                return RVModelType.unknownModel
            }
        }
        set { updateString(key: RVBaseModel.key.parentModelType, value: newValue.rawValue) }
    }
    var title: String? {
        get { return getString(key: RVBaseModel.key.title) }
        set { updateString(key: RVBaseModel.key.title, value: newValue) }
    }
    var regularDescription: String? {
        get { return getString(key: RVBaseModel.key.description) }
        set { updateString(key: RVBaseModel.key.description, value: newValue) }
    }
    func getString(key: RVBaseModel.key) -> String? {
        if let value = objects[key.rawValue] as? String { return value }
        else { return nil }
    }
    func setToNSNull(key: String) {
        objects[key] = NSNull()
        dirties[key] = NSNull()
        super.update(nil, cleared: [key])
    }
    func setToValue(key: String, value: AnyObject) {
        objects[key] = value
        dirties[key] = value
        super.update([key: value], cleared: nil)
    }
    func updateString(key: RVBaseModel.key, value: String? ) {
        updateString(key: key.rawValue, value: value)
    }
    override func update(_ fields: NSDictionary?, cleared: [String]?) {
        if let dictionary = fields {
            for(key, value) in dictionary {
                if let key = key as? String {
                    self.objects[key] = value as AnyObject
                }
            }
        }
        super.update(fields, cleared: cleared)
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
                if let currentNumber = current[RVBaseModel.key.JSONdate.rawValue] {
                    if let newValue = value[RVBaseModel.key.JSONdate.rawValue] {
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
            if let image = objects[RVBaseModel.key.image.rawValue] as? [String: AnyObject] {
                return RVImage(objects: image)
            }
            return nil
        }
        set {
            if let value = newValue {
                setArray(key: RVBaseModel.key.image.rawValue, value: value.objects )
            } else {
                setArray(key: RVBaseModel.key.image.rawValue, value: nil)
            }
        }
    }
    var createdAt: NSDate? {
        get {
            if let dateArray = objects[RVBaseModel.key.createdAt.rawValue] as? [String : NSNumber] {
                if let interval = dateArray[RVBaseModel.key.JSONdate.rawValue] {
                    return NSDate(timeIntervalSince1970: interval.doubleValue / 1000.0 )
                }
            }
            return nil
        }
    }
    var updatedAt: Date? {
        get {
            if let dateArray = objects[RVBaseModel.key.updatedAt.rawValue] as? [String : NSNumber] {
                if let interval = dateArray[RVBaseModel.key.JSONdate.rawValue] {
                    return Date(timeIntervalSince1970: interval.doubleValue / 1000.0 )
                }
            }
            return nil
        }
        set {
            if let dateValue = newValue {
                updateDateTime(key: RVBaseModel.key.updatedAt.rawValue, value: EJSON.convertToEJSONDate(dateValue))
            }
        }
    }

    
}
extension RVBaseModel {
    func insert(callback: @escaping (_ error: RVError?) -> Void ) {
        objects.removeValue(forKey: RVBaseModel.key._id.rawValue)
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
}
