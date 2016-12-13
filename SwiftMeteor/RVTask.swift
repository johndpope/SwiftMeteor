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
}
