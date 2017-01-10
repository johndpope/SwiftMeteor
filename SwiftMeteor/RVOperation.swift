//
//  RVOperation.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/10/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation

class RVOperation {
    var cancelled: Bool = false
    let identifier = NSDate().timeIntervalSince1970
    var name: String = ""
    var active: Bool = false {
        didSet {
            //print("RVDSOperation \(name), \(identifier) with id: \(identifier), active set to \(active)")
        }
    }
    init(active: Bool, name: String = "NoName") {
        self.active = active
        self.name = name
    }
    func sameOperation(operation: RVOperation) -> Bool {
        if self.identifier == operation.identifier { return true }
        return false
    }
    func sameOperationAndNotCancelled(operation: RVOperation) -> Bool {
        if sameOperation(operation: operation) { return !self.cancelled }
        return false
    }
}
