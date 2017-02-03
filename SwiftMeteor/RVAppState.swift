//
//  RVAppState.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/21/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit

class RVAppState2 {
    enum State: String {
        case ShowProfile        = "ShowProfile"
        case Regular            = "Regular"
        case WatchGroupDetail   = "WatchGroupDetail"
    }
    var state: State = .Regular {
        didSet {
            self.lastState = oldValue
        }
    }
    var lastState: State = .Regular 
    static let shared: RVAppState2 = {
        RVAppState2()
    }()
}
