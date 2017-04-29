//
//  RVBaseConfiguration8.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/15/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
class RVBaseConfiguration8<T: RVSubbaseModel>: RVBaseConfiguration4<T> {
    var core: RVBaseCoreInfo8 { return RVBaseCoreInfo8.sharedInstance }
}
