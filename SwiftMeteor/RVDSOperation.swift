//
//  RVDSOperation.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 12/31/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import Foundation

class RVDSOperation {
    var name = "notSet"
    var active: Bool = false {
        didSet {
           //print("RVDSOperation \(name), \(identifier) with id: \(identifier), active set to \(active)")
        }
    }
    init(name: String) {
        self.name = name
    }
    var cancelled: Bool = false
    let identifier = NSDate().timeIntervalSince1970
}
