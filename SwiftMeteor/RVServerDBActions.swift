//
//  RVServerDBActions.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/8/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
enum RVServerDBActions: String {
    case create = "create"
    case read   = "read"  // via ID
    case update = "update"
    case delete = "delete" // via ID
    case list   = "list"

}
