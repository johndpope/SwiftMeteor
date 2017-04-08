//
//  RVSectionManager4.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/8/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
class RVSectionManager4 {
    var instanceType: String { get { return String(describing: type(of: self)) } }
    fileprivate let queue = RVOperationQueue()
    fileprivate var sections = [RVBaseDatasource4]()
}


