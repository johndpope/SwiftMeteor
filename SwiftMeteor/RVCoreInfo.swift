//
//  RVCoreInfo.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/7/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation

class RVCoreInfo {
    static let sharedInstance: RVCoreInfo = {
        return RVCoreInfo()
    }()
    var username: String? = nil
    var rootTask: RVTask? 
}
