//
//  RVActivityIndicator.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 12/3/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import UIKit

class RVActivityIndicator: NSObject {
    
    private var count: Int = 0
    static var sharedInstance: RVActivityIndicator {
        return RVActivityIndicator()
    }
    public func incrementIndicatorCount() {
        if count == 0 {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        count = count + 1
    }
    public func decrementIndicatorCount() {
        if count <= 1 {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        count = 0
    }
}
