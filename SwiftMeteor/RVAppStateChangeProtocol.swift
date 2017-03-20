//
//  RVAppStateChangeProtocol.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/19/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
protocol RVAppStateChangeProtocol: class {
    func updateState(callback: @escaping(RVError?) -> Void) -> Void
}
