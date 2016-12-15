//
//  Task.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 12/11/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import UIKit

class RVTask: RVBaseModel {
    override class func collectionType() -> RVModelType { return RVModelType.task }
    override class var insertMethod: RVMeteorMethods { get { return RVMeteorMethods.InsertTask } }
    override class var updateMethod: RVMeteorMethods { get { return RVMeteorMethods.UpdateTask } }
    override class var deleteMethod: RVMeteorMethods { get { return RVMeteorMethods.DeleteTask } }

    var _checked = RVRecord(fieldName: RVKeys.checked)
    var checked: Bool? {
        get {
            if let checked = _checked.value as? Bool { return checked}
            return nil
        }
        set {
            if let newValue = newValue {
                let _ = _checked.changeBool(newValue: newValue as AnyObject)
            } else {
                let _ = _checked.changeBool(newValue: NSNull())
            }

        }
    }
    override func innerUpdate(key: RVKeys, value: AnyObject?) -> Bool {
        if super.innerUpdate(key: key, value: value) == true {
            return true
        } else {
          //  print("In RVTasks.innerUpdate \(key.rawValue), \(value)")
            switch(key) {
            case .checked:
                let _ = self._checked.updateBool(newValue: value)
                return true
            default:
                print("In \(instanceType).innerUpdate, did not find key \(key)")
                return false
            }
        }
    }
}
