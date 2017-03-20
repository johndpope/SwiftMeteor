//
//  RVNewState.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/19/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
enum RVAppState4: String {
    case leftMenu               = "leftMenu"
    case defaultState           = "/DefaultState"
    case loggedOut              = "/LoggedOut"
    case transactionList        = "/main/transaction/list"
    case groupList              = "/main/group/list"
    case friendList             = "/main/friend/list"
}
class RVBaseAppState4: NSObject {
    var instanceType: String { get { return String(describing: type(of: self)) } }
    var appState: RVAppState4
    init(appState: RVAppState4) {
        self.appState = appState
        super.init()
    }
}
