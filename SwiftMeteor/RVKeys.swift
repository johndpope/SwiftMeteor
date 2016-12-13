//
//  RVKeys.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 12/12/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import Foundation
enum RVKeys: String {
    case collection     = "collection"
    case _id            = "_id"
    case createdAt      = "createdAt"
    case updatedAt      = "updatedAt"
    case `private`      = "private"
    case username       = "username"
    case modelType      = "modelType"
    case ownerId        = "ownerId"
    case owner          = "owner"   // Need to fix
    case parentId       = "parentId"
    case parentModelType = "parentModelType"
    case title          = "title"
    case text           = "text"
    case `description`  = "description"
    case JSONdate       = "$date"
    case image          = "image"
}
