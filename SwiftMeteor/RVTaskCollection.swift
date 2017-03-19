//
//  RVTaskCollection.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 12/15/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import Foundation
import SwiftDDP

class RVTaskCollection: RVBaseCollection {
    override func populate(id: String, fields: NSDictionary) -> RVBaseModel {
        return RVTask(id: id, fields: fields)
    }
    init() {
        super.init(collection: RVModelType.task)
    }
}
