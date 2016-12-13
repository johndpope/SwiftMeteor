//
//  Task.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 12/11/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import UIKit

class RVTask: RVBaseModel {

    override class var insertMethod: RVMeteorMethods {
        get {
            return RVMeteorMethods.InsertTask
        }
    }
    override class func collectionType() -> RVModelType {
       return RVModelType.task
    }
    
    var checked: Bool? {
        get {
            if let checked = objects[RVKeys.checked.rawValue] as? Bool {
                return checked
            } else {
                return nil
            }
        }
        set {
            updateBool(key: RVKeys.checked, value: newValue)
        }
    }
    override func innerUpdate(key: RVKeys, value: AnyObject?) -> Bool {
        if super.innerUpdate(key: key, value: value) == true {
            return true
        } else {
            switch(key) {
            case .checked:
                if let value = value as? Bool? {
                    self.checked = value
                }
                return true
            default:
                print("In \(instanceType).innerUpdate, did not find key \(key)")
                return false
            }
        }
    }
}
