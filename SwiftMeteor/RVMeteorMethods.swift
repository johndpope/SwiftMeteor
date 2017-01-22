
//
//  RVMeteorMethods.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 12/11/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import Foundation

enum RVMeteorMethods: String {
    case QueryBase  = "base.query"
    case InsertBase = "base.insert"
    case UpdateBase = "base.update"
    case FindBase = "base.findInstance"
    case DeleteBase = "base.delete"
    case InsertImage = "images.insert"
    case UpdateImage = "images.update"
    case DeleteImage = "images.delete"
    case FindImage  = "images.find"
    case QueryTask  = "tasksWQuery"
    case InsertTask = "tasks.insert2"
    case UpdateTask = "tasks.update"
    case DeleteTask = "tasks.remove"
    case FindTask   = "tasks.find"
    case GetMeteorUserId = "userId"
    
    
    // MeteorUser 
    case meteoruserFindUserProfileId = "meteorUser.findUserProfileId"
    // UserProfile
    case userProfileCreate      = "userProfile.create"
    case userProfileUpdateById  = "userProfile.updateById"
    case userProfileDelete      = "userProfile.delete"
    case userProfileFind        = "userProfile.find"
    case userProfileBulkQuery   = "userProfile.bulkQuery"
    case getOrCreateUserUserProfile = "userProfile.getOrCreateUserUserProfile"
    
    
    case BulkTask = "tasks.bulk"
    
    // Domain
    case domainCreate = "domain.create"
    case domainFindById = "domain.findById"
    case domainFindOne = "domain.findOne"
    case domainUpdate = "domain.update"
    case domainDelete = "domain.delete"
    case domainBulkQuery = "domain.bulkQuery"
}
