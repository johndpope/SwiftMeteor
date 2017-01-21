//
//  RVBaseModel3.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/18/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
class RVBaseModel3: NSObject {
    class var absoluteModelType: RVModelType { return RVModelType.unknown }
    var objects = [String: AnyObject]()
    var dirties = [String: AnyObject]()
    var id: String? = nil
    override init() {
        super.init()
        self.modelType = type(of: self).absoluteModelType
        print("In RVBaseModel.init, need to do ID Create")
    }
    init(objects: [String: AnyObject], id: String? = nil) {
        super.init()
        self.objects = objects
        if let id = id {
            self.id = id
            if let _id = self._id {
                if id != _id {
                    self._id = id
                }
            } else {
                self._id = id
            }
            
        } else {
            print("In \(self.classForCoder).init created ID creator")
        }
        if (self.modelType == RVModelType.unknown) || (self.modelType != type(of: self).absoluteModelType) {
            print("In \(self.classForCoder).init, have invalid model. Expected \(type(of: self).absoluteModelType.rawValue), got \(self.modelType.rawValue)")
        }
    }
    var image: RVImage? {
        get {
            if let dictionary = objects[RVKeys.image.rawValue] as? [String: AnyObject] { return RVImage(fields: dictionary) }
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
    var _id: String? {
        get { return getString(key: RVKeys._id) }
        set { updateString(key: RVKeys._id, value: newValue, setDirties: true)}
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
        set {updateString(key: .modelType, value: newValue.rawValue, setDirties: true)}
    }
    func getString(key: RVKeys) -> String? {
        if let string = objects[key.rawValue] as? String { return string }
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
    
}
