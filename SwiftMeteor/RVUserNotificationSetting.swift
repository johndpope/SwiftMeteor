//
//  RVUserNotificationSetting.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/20/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation

enum RVUserNotificationSetting: Int {
    case none = 0
    case high = 5
    
    var description: String {
        switch(self) {
        case .none:
            return "None"
        case .high:
            return "High"
        }
    }
}
