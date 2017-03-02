//
//  RVTransactionType.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 2/21/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
enum RVTransactionType: String {
    case added = "Added"
    case updated = "Updated"
    case imageAdded = "ImageAdded"
    case unknown = "unknown"
}
enum RVReadState: String {
    case unread = "unread"
    case read = "read"
    case unknown = "unknown"
}

