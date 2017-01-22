//
//  RVAppState.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/21/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit

class RVAppState {
    enum State: String {
        case ShowProfile = "ShowProfile"
        case Regular = "Regular"
    }
    var state: State = .Regular {
        didSet {
            self.lastState = oldValue
        }
    }
    var lastState: State = .Regular 
    static let shared: RVAppState = {
        RVAppState()
    }()
}
