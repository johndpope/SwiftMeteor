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
    override class var findMethod: RVMeteorMethods { get { return RVMeteorMethods.FindTask}}
    override class func createInstance(fields: [String : AnyObject])-> RVBaseModel { return RVTask(fields: fields) }
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
    override func getRVFields(onlyDirties: Bool) -> [String : AnyObject] {
        var dict = super.getRVFields(onlyDirties: onlyDirties)
        if !onlyDirties || (onlyDirties && self._checked.dirty) {
            if let checked = self.checked { dict[RVKeys.checked.rawValue] = checked as AnyObject }
            else { dict[RVKeys.checked.rawValue] = NSNull() }
            self._checked.dirty = false
        }
        return dict
    }
    override func setupCallback() {
        super.setupCallback()
        self._checked.model = self
    }
}
