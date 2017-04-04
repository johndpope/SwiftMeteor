//
//  RVModelType.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 12/11/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import Foundation

enum RVModelType: String  {
    case baseModel      = "BaseModel" // "baseModel"
    case domain         = "Domains"
    case follow         = "Follows" // "follow"
    case Group          = "Groups"
    case household      = "Household" // "household"
    case image          = "Images" // "image"
    case location       = "Locations" // "location"
    case Message        = "Messages"
    case privateChat    = "PrivateChats" // "privateChat"
    case userProfile    = "UserProfiles" // "userProfile"
    case setting        = "Settings" // "settings"
    case task           = "Tasks" // "tasks"
    case topics         = "Topics"
    case transaction    = "Transactions"
    case unknown        = "Unknown" // "unknown"
    case watchgroup     = "WatchGroups" // "WatchGroup"
}

