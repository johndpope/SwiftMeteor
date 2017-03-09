//
//  RVTaskCollection2.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/5/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
import SwiftDDP
class RVTaskCollection2: AbstractCollection {
    override func documentWasRemoved(_ collection: String, id: String) {
        print("In Document was removed")
    }
    override func documentWasAdded(_ collection: String, id: String, fields: NSDictionary?) {
        print("In Document was added")
    }
}
