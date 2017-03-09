
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
    case DeleteAllBase = "base.deleteAll"
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
    
    // WatchGroup
    case watchGroupCreate = "watchGroup.create"
    case watchGroupFindById = "watchGroup.findById"
    case watchGroupUpdate = "watchGroup.update"
    case watchGroupBulkQuery = "watchGroup.bulkQuery"
    case watchGroupDelete = "watchGroup.delete"
    case watchGroupDeleteAll = "watchGroup.clear"
    
    // Message
    case messageCreate = "message.create"
    case messageUpdate = "message.update"
    case messageFindById = "message.findById"
    case messageBulkQuery = "message.bulkQuery"
    case messageDelete = "message.delete"
    case messageGroupDeleteAll = "message.clear"
    case messagesWQuery = "messagesWQuery"
    case messageSubscribe = "message.subscribe"
    
    // Follow
    case followCreate = "follow.create"
    case followUpdate = "follow.update"
    case followFindById = "follow.findById"
    case followBulkQuery = "follow.bulkQuery"
    case followDelete = "follow.delete"
    case followDeleteAll = "follow.deleteAll"
    
    
    // PrivateChat
    case privateChatCreate = "privateChat.create"
    case privateChatUpdate = "privateChat.update"
    case privateChatFindById = "privateChat.findById"
    case privateChatBulkQuery = "privateChat.bulkQuery"
    case privateChatDelete = "privateChat.delete"
    case privateChatDeleteAll = "privateChat.deleteAll"
    case privateChatSpecialLookup = "privateChat.specialLookup"
    
    // Transaction
    case transactionBulkQuery = "transaction.bulkQuery"
    case transactionCreate = "transaction.create"
    case transactionUpdate = "transaction.update"
    case transactionFindById = "transaction.findById"
    case transactionDelete = "transaction.delete"
    case transactionDeleteAll = "transaction.deleteAll"
    
    // Group
    case GroupCreate    = "Group.create"
    case GroupRead      = "Group.read"
    case GroupUpdate    = "Group.update"
    case GroupDelete    = "Group.delete"
    case GroupList      = "Group.list"
    case GroupRoot      = "Group.root"
    case GroupDeleteAll = "Group.deleteAll"
    
}
