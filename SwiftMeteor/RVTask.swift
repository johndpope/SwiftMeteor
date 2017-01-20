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
    override class var bulkQueryMethod: RVMeteorMethods { get { return RVMeteorMethods.BulkTask } }
    override class func createInstance(fields: [String : AnyObject])-> RVBaseModel { return RVTask(fields: fields) }

    
    
    var `private`: Bool? {
        get { return getBool(key: .private) }
        set { updateBool(key: .private, value: newValue, setDirties: true)
        }
    }

    var checks: Bool? {
        get { return getBool(key: .checked) }
        set { updateBool(key: .checked, value: newValue, setDirties: true)
        }
    }
    override class func modelFromFields(fields: [String: AnyObject]) -> RVBaseModel {
        return RVTask(fields: fields)
    }
}
