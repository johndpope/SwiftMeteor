//
//  RVRecord.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 12/14/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import Foundation
import SwiftDDP

class RVRecord {
    var value: AnyObject?
    var dirty: Bool = false
    var fieldName: RVKeys
    weak var model: RVBaseModel? = nil
    var instanceType: String {
        get {
            return String(describing: type(of: self))
        }
    }
    init(fieldName: RVKeys) {
        self.fieldName = fieldName
    }
    func update(value: AnyObject?, dirty: Bool) {
        self.value = value
        self.dirty = dirty
    }
    func changeString(newValue: AnyObject?) -> Bool {
        return updateString(newValue: newValue, dirty: true)
    }
    func changeNumber(newValue: AnyObject?) -> Bool {
        return updateNumber(newValue: newValue, dirty: true)
    }
    func changeDateArray(newValue: AnyObject?) -> Bool {
        return updateDateArray(newValue: newValue, dirty: true)
    }
    func changeBool(newValue: AnyObject?) -> Bool {
        return updateBool(newValue: newValue, dirty: true)
    }
    func changeArray(newValue: AnyObject?) -> Bool {
        return updateArray(newValue: newValue, dirty: true)
    }
    func updateString(newValue: AnyObject?) -> Bool {
        return updateString(newValue: newValue, dirty: false)
    }
    func updateNumber(newValue: AnyObject?) -> Bool {
        return updateNumber(newValue: newValue, dirty: false)
    }
    func updateDateArray(newValue: AnyObject?) -> Bool {
        return updateDateArray(newValue: newValue, dirty: false)
    }
    func updateBool(newValue: AnyObject?) -> Bool {
        return updateBool(newValue: newValue, dirty: false)
    }
    func updateArray(newValue: AnyObject?) -> Bool {
        return updateArray(newValue: newValue, dirty: false)
    }
    func valueChanged() {
     //  print("\(instanceType) valueChanged for \(self.fieldName.rawValue), to [\(self.value)]")
        if let model = model {
            model.valueChanged(field: self.fieldName, value: self.value)
        }
    }
    func updateString(newValue: AnyObject?, dirty: Bool) -> Bool {
        //print("Updating String \(self.fieldName) to \(newValue)")
        if let newValue = newValue {
            if let newValue = newValue as? String {
                if let current = self.value as? String {
                    if current != newValue {
                        value = newValue as AnyObject?
                        self.dirty = dirty
                        if (dirty) { valueChanged() }
                        return true
                    } else {
                        // same value so don't do anything
                        return false
                    }
                } else {
                    value = newValue as AnyObject?
                    self.dirty = dirty
                    if dirty {valueChanged()}
                    return true
                }
            } else if newValue as! NSObject == NSNull() {
                if let value = self.value {
                    if value as! NSObject == NSNull() {
                        // same value. Don't do anything
                        return false
                    }
                }
                value = NSNull()
                self.dirty = dirty
                if dirty {valueChanged()}
                return true
            } else {
                print("Error. Attempted to update \(fieldName.rawValue) to a value that is not a String. Value: \(value)")
                return false
            }
        } else {
            value = NSNull()
            self.dirty = dirty
            if dirty {valueChanged()}
            return false
        }

    }
    func updateNumber(newValue: AnyObject?, dirty: Bool) -> Bool {
        if let newValue = newValue {
            if let newValue = newValue as? NSNumber {
                if let current = self.value as? NSNumber {
                    if current != newValue {
                        self.value = newValue as AnyObject?
                        self.dirty = dirty
                        if dirty {valueChanged()}
                        return true
                    } else {
                        // same value so don't do anything
                        return false
                    }
                } else {
                    self.value = newValue as AnyObject?
                    self.dirty = dirty
                    if dirty { valueChanged() }
                    return true
                }
            } else if newValue as! NSObject == NSNull() {
                if let value = self.value {
                    if value as! NSObject == NSNull() {
                        // same value. Don't do anything
                        return false
                    }
                }
                value = NSNull()
                self.dirty = dirty
                if dirty { valueChanged() }
                return true
            } else {
                print("Error. Attempted to update \(fieldName.rawValue) to a value that is not a NSNumber. Value: \(value)")
                return false
            }
        } else {
            value = NSNull()
            self.dirty = dirty
            if dirty { valueChanged() }
            return true
        }
    }
    func updateArray(newValue: AnyObject?, dirty: Bool) -> Bool {
        if let newValue = newValue {
            if let _ = newValue as? [String : AnyObject] {
                self.value = newValue
                self.dirty = dirty
                if dirty { valueChanged() }
                return true
            } else if newValue as! NSObject == NSNull() {
                if let value = self.value {
                    if value as! NSObject == NSNull() {
                        // Both NSNull(). Don't do anything
                        return false
                    }
                }
                self.value = NSNull()
                self.dirty = dirty
                if dirty { valueChanged() }
                return true
            } else {
                print("Error. Attempted to update \(fieldName.rawValue) to a value that is not an Array. Value: \(value ?? " no vlaue")")
                return false
            }
        } else {
            self.value = NSNull()
            self.dirty = dirty
            if dirty { valueChanged() }
            return true
        }

    }
    func updateDateArray(newValue: AnyObject?, dirty: Bool) -> Bool {
        if let newValue = newValue {
            if let newValue = newValue as? [String : Double] {
                if let newNumber = newValue[RVKeys.JSONdate.rawValue] {
                    if let currentValue = self.value as? [String : Double] {
                        if let currentNumber = currentValue[RVKeys.JSONdate.rawValue]  {
                            if newNumber != currentNumber {
                                self.value = newValue as AnyObject
                                self.dirty = dirty
                                if dirty { valueChanged() }
                                return true
                            } else {
                                // same value. Do nothing.
                                return false
                            }
                        } else {
                            // currentNumber doesn't exist. Shouldn't be able to happen
                            self.value = newValue as AnyObject
                            self.dirty = dirty
                            if dirty { valueChanged() }
                            return true
                        }
                    } else {
                        // nothing current that is valid or exists
                        self.value = newValue as AnyObject
                        self.dirty = dirty
                        if dirty { valueChanged() }
                        return true
                    }
                } else {
                    // bad entry; ignore
                    return false
                }
            } else if newValue as! NSObject == NSNull() {
                if let value = self.value {
                    if value as! NSObject == NSNull() {
                        // Both NSNull(). Don't do anything
                        return false
                    }
                }
                self.value = NSNull()
                self.dirty = dirty
                if dirty { valueChanged() }
                return true
            } else {
                print("Error. Attempted to update \(fieldName.rawValue) to a value that is not a Date Array. Value: \(value)")
                return false
            }
        } else {
            self.value = NSNull()
            self.dirty = dirty
            if dirty { valueChanged() }
            return true
        }
    }
    func updateBool(newValue: AnyObject?, dirty: Bool) -> Bool {
        if let newValue = newValue {
            if let newValue = newValue as? Bool {
                if let current = self.value as? Bool {
                    if current != newValue {
                        value = newValue as AnyObject?
                        self.dirty = dirty
                        if dirty { valueChanged() }
                        return true
                    } else {
                        // same value so don't do anything
                        return false
                    }
                } else {
                    self.value = newValue as AnyObject?
                    self.dirty = dirty
                    if dirty { valueChanged() }
                    return true
                }
            } else if newValue as! NSObject == NSNull() {
                if let value = self.value {
                    if value as! NSObject == NSNull() {
                        // Both NSNull(). Don't do anything
                        return false
                    }
                }
                self.value = NSNull()
                self.dirty = dirty
                if dirty { valueChanged()}
                return true
            } else {
                print("Error. Attempted to update \(fieldName.rawValue) to a value that is not a Bool. Value: \(value)")
                return false
            }
        } else {
            self.value = NSNull()
            self.dirty = dirty
            if dirty { valueChanged() }
            return true
        }
    }
}
