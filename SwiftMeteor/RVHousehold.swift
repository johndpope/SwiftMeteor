//
//  RVHousehold.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/20/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
class RVHousehold: RVBaseModel {

    override class func collectionType() -> RVModelType { return RVModelType.household }
//    override class var insertMethod: RVMeteorMethods { get { return RVMeteorMethods.InsertTask } }
//    override class var updateMethod: RVMeteorMethods { get { return RVMeteorMethods.UpdateTask } }
//    override class var deleteMethod: RVMeteorMethods { get { return RVMeteorMethods.DeleteTask } }
//    override class var findMethod: RVMeteorMethods { get { return RVMeteorMethods.FindTask}}
//    override class var bulkQueryMethod: RVMeteorMethods { get { return RVMeteorMethods.BulkTask } }
    override class func createInstance(fields: [String : AnyObject])-> RVBaseModel { return RVHousehold(fields: fields) }
}
