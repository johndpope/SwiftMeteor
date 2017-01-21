
//
//  RVMessage.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/20/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
class RVMessage: RVBaseModel {
    override class func collectionType() -> RVModelType { return RVModelType.message }
    //    override class var insertMethod: RVMeteorMethods { get { return RVMeteorMethods.InsertTask } }
    //    override class var updateMethod: RVMeteorMethods { get { return RVMeteorMethods.UpdateTask } }
    //    override class var deleteMethod: RVMeteorMethods { get { return RVMeteorMethods.DeleteTask } }
    //    override class var findMethod: RVMeteorMethods { get { return RVMeteorMethods.FindTask}}
    //    override class var bulkQueryMethod: RVMeteorMethods { get { return RVMeteorMethods.BulkTask } }
    override class func createInstance(fields: [String : AnyObject])-> RVBaseModel { return RVMessage(fields: fields) }
    var followedId: String? {
        get { return getString(key: RVKeys.followedId) }
        set { updateString(key: RVKeys.followedId, value: newValue, setDirties: true)}
    }
    var followedModelType: RVModelType {
        get {
            if let rawValue = getString(key: .followedModelType) {
                if let type = RVModelType(rawValue: rawValue) { return type}
            }
            return RVModelType.unknown
        }
        set {
            updateString(key: .followedModelType, value: newValue.rawValue, setDirties: true)
            self.collection = newValue
        }
    }
}
