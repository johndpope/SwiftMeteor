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
    case shadowId       = "shadowId"
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
    case ownerModelType = "ownerModelType"
    case owner          = "owner"   // Need to fix
    case parentId       = "parentId"
    case parentModelType = "parentModelType"
    case title          = "title"
    case text           = "text"
    case parentField    = "parentField"
    case regularDescription  = "regularDescription"
   // case lowerCaseRegularDescription = "lowerCaseRegularDescription"
    case comment        = "comment"
    case commentLowercase = "lowerCaseComment"
    case JSONdate       = "$date"
    case image          = "image"
    case special        = "special"
    case deleted        = "deleted"
    case domainId       = "domainId"
    case tags           = "tags"
    case location       = "location"
    case value          = "value"
    case schemaVersion  = "schemaVersion"
    case clientRole     = "clientRole"
    case visibility     = "visibility"
    case validRecord    = "validRecord"
    case updateCount    = "updateCount"
    
    case numberOfLikes  = "numberOfLikes"
    case numberOfObjections = "numberOfObjections"
    case numberOfFollowers = "numberOfFollowers"
    
    // Domain
    case domainName     = "domainName"
    case score          = "score" // Need to add to Meteor
    
    // Follow
    case followedId     = "followedId"
    case followedModelType = "followedModelType"
    // task
    case checked        = "checked"
    
    // User
    case firstName      = "first"
    case middleName     = "middle"
    case lastName       = "last"
    case yob            = "yob"
    case gender         = "gender"
    case cellPhone      = "cellPhone"
    case homePhone      = "homePhone"
    case settings       = "setting"
    case email          = "email"
    case watchGroupIds  = "watchGroupIds"
    case lastLogin      = "lastLogin"
    
    // image
    case height         = "height"
    case width          = "width"
    case bytes          = "bytes"
    case urlString      = "urlString" // is url in Meteor
    case filetype       = "filetype"
    
    case photo_reference = "photo_reference" // New
    case url = "url"  // New

    // settings
    case emailVisibility = "emailVisibilty"
    case emailVerified = "emailVerified"
    case cellVisibility = "cellVisibility"
    case cellVerified = "cellVerified"
    case homeVisibility = "homeVisibility"
    case homeVerified = "homeVerified"
    
    // location
    case geometry = "geometry"
    case latitude = "lat"
    case longitude = "lng"
    case fullAddress   = "fullAddress"
    case reference = "reference"
    case iconURL = "iconURL"
    case iconURLString = "iconURLString"
    case record_id = "record_id"
    case placeId = "placeId"
    case types = "types"
    case thoroughfare = "thoroughfare"
    case locality = "locality"
    case subLocality = "subLocality"
    case administrativeArea = "administrativeArea"
    case administrativeArea2 = "administrativeArea2"
    case city = "city"
    case state = "state"
    case postalCode = "zip"
    case postalCodeSuffix = "postalCodeSuffix"
    case country = "country"
    case lines = "lines"
    case website = "website"
    case websiteString = "websiteString"
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
