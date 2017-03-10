//
//  RVAdminCode.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/9/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation

class RVAdminCode {
    var adminCodeZero: String = "Replace"
    var adminCodeOne: String = "This"
    static let sharedInstance: RVAdminCode = {
        return RVAdminCode()
    }()
    var fields: [String: String] {
        get {
            return [RVKeys.adminCodeZero.rawValue: self.adminCodeZero, RVKeys.adminCodeOne.rawValue: self.adminCodeOne]
        }
    }
}
