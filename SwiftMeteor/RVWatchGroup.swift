//
//  RVWatchGroup.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/20/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
import SwiftDDP

class RVWatchGroup: RVInterest {
    override class func collectionType() -> RVModelType { return RVModelType.watchgroup }
    override class var insertMethod: RVMeteorMethods { get { return RVMeteorMethods.watchGroupCreate } }
    override class var updateMethod: RVMeteorMethods { get { return RVMeteorMethods.watchGroupUpdate } }
    override class var deleteMethod: RVMeteorMethods { get { return RVMeteorMethods.watchGroupDelete } }
    override class var findMethod: RVMeteorMethods { get { return RVMeteorMethods.watchGroupFindById}}
    override class var deleteAllMethod: RVMeteorMethods { get { return RVMeteorMethods.watchGroupDeleteAll}}
    override class var bulkQueryMethod: RVMeteorMethods { get { return RVMeteorMethods.watchGroupBulkQuery } }

    override class func modelFromFields(fields: [String: AnyObject]) -> RVBaseModel { return RVWatchGroup(fields: fields) }
    

}
