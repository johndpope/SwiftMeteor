//
//  RVCallbackAliases.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/22/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
typealias RVEmptyCallback = () -> Void
typealias RVErrorCallback = (RVError?) -> Void
typealias RVModelCallback<T: NSObject> = ([T], RVError?) -> Void


typealias RVCallback<T:NSObject> = ([T], RVError?) -> Void
typealias DSOperation = () -> Void
