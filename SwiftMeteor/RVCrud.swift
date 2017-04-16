//
//  RVCrud.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/15/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
enum RVCrud: String {
    case create     = "create"
    case read       = "read"
    case update     = "udpate"
    case delete     = "delete"
    case deleteAll  = "deleteAll"
    case list       = "list"
    case unknown    = "unknown"
}
