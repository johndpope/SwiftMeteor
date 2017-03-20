//
//  RVNewState.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/19/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
enum RVNewAppState: String {
    case defaultState   = "DefaultState"
    case loggedIn       = "LoggedIn"
    case loggedOut      = "LoggedOut"
    case mainState      = "MainState"
}
class RVNewBaseState {
    var instanceType: String { get { return String(describing: type(of: self)) } }
    var appState: RVNewAppState
    init(appState: RVNewAppState) {
        self.appState = appState
    }
}
