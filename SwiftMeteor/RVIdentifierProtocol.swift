//
//  RVIdentifierProtocol.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/16/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation

protocol RVIdentifierProtocol: class {
    static var identifier: String { get }
    var staticIdentifier: String { get }
}
