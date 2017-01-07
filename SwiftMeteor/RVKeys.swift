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
    case handle         = "handle"
    case handleLowercase = "handleLowercase"
    case modelType      = "modelType"
    case ownerId        = "ownerId"
    case owner          = "owner"   // Need to fix
    case parentId       = "parentId"
    case parentModelType = "parentModelType"
    case title          = "title"
    case text           = "text"
    case regularDescription  = "regularDescription"
    case lowerCaseRegularDescription = "lowerCaseRegularDescription"
    case comment        = "comment"
    case lowerCaseComment = "lowerCaseComment"
    case JSONdate       = "$date"
    case image          = "image"
    
    case numberOfLikes  = "numberOfLikes"
    case numberOfObjections = "numberOfObjections"
    case numberOfFollowers = "numberOfFollowers"
    
    // task
    case checked        = "checked"
    
    // imagme
    case height         = "height"
    case width          = "width"
    case bytes          = "bytes"
    case urlString      = "urlString"
    case filetype       = "filetype"
    
    
    case metaQueryTerm  = "$meta"
}
