//
//  RVNotification.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/20/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
class RVNotification {
    static let userDidLogin         = Notification.Name("RVUserDidLogin")
    static let userDidLogout        = Notification.Name("RVUserDidLogout")
    static let collectionDidChange  = Notification.Name("RVCollectionDidChange")
    static let connected            = Notification.Name("Connected")
    static let StateUninstalled     = Notification.Name("StateUninstalled")
    static let StateInstalled       = Notification.Name("StateInstalled")
    static let AppStateChanged      = Notification.Name("AppStateChanged")
}
