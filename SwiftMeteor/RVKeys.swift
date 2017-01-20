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
    case fullName       = "fullName"  // Need to add to Meteor
    case fullNameLowercase = "fullNameLowercase"
    case modelType      = "modelType"
    case ownerId        = "ownerId"
    case owner          = "owner"   // Need to fix
    case parentId       = "parentId"
    case parentModelType = "parentModelType"
    case title          = "title"
    case text           = "text"
    case regularDescription  = "description"
   // case lowerCaseRegularDescription = "lowerCaseRegularDescription"
    case comment        = "comment"
    case commentLowercase = "lowerCaseComment"
    case JSONdate       = "$date"
    case image          = "image"
    case special        = "special"
    case deleted        = "deleted"
    
    case numberOfLikes  = "numberOfLikes"
    case numberOfObjections = "numberOfObjections"
    case numberOfFollowers = "numberOfFollowers"
    
    
    case score          = "score" // Need to add to Meteor
    // task
    case checked        = "checked"
    
    // User
    case first          = "first"
    case last           = "last"
    case yob            = "yob"
    case gender         = "gender"
    case cell           = "cell"
    case settings       = "setting"
    case email          = "email"
    case watchGroupIds  = "watchGroupIds"
    
    // image
    case height         = "height"
    case width          = "width"
    case bytes          = "bytes"
    case urlString      = "urlString" // is url in Meteor
    case filetype       = "filetype"
    
    case photo_reference = "photo_reference" // New
    case url = "url"  // New


    
    // location
    case geometry = "geometry"
    case latitude = "lat"
    case longitude = "lng"
    case fullAddress   = "fullAddress"
    case reference = "reference"
    case iconURL = "iconURL"
    case record_id = "record_id"
    case place_id = "placeId"
    case types = "types"
    case thoroughfare = "thoroughfare"
    case locality = "locality"
    case subLocality = "subLocality"
    case administrativeArea = "administrativeArea"
    case city = "city"
    case state = "state"
    case postalCode = "zip"
    case country = "country"
    case lines = "lines"
    case website = "website"
    case phoneNumber = "phoneNumber"
    case neighborhood = "neighborhood"
    case street_number = "street_number"
    case route = "route"
    case geocoded = "geocoded"
    case geoIndex = "geoIndex"
    
    case street = "street"  // in Meteor
    case maps_url = "maps_url" // in Meteor

    
    case metaQueryTerm  = "$meta"
}
