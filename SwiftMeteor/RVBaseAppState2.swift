//
//  RVBaseAppState2.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/5/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
class RVAppStateManager {
    private var states = [RVBaseAppState2]()
    let MAX = 10
    static let shared: RVAppStateManager = { return RVAppStateManager() }()
    private func pushState(newState: RVBaseAppState2) {
        var clone = [RVBaseAppState2]()
        for state in states { clone.append(state) }
        clone.append(newState)
        if clone.count > 10 { clone.remove(at: 0) }
        states = clone
    }
    var installing: Bool = false
    var topState: RVBaseAppState2 {
        get {
            if states.count > 0 { return states[states.count - 1] }
            return RVLoggedOutState2()
        }
    }
    func changeState(newState: RVBaseAppState2, callback: @escaping() -> Void) {
        if !installing {
            installing = true
            topState.uninstall {
                NotificationCenter.default.post(name: RVNotification.StateUninstalled, object: nil, userInfo: ["UninstalledState": RVAppStateManager.shared.topState])
                RVAppStateManager.shared.pushState(newState: newState)
                newState.uninstall(callback: {
                    newState.install {
                        RVAppStateManager.shared.installing = false
                        callback()
                        NotificationCenter.default.post(name: RVNotification.StateInstalled, object: nil, userInfo: ["InstalledState": RVAppStateManager.shared.topState])
                    }
                })
            }
        } else {
           // print("In \(self.instanceType).changeState, in the middle of changing state")
            callback()
        }
        
    }
}
class RVBaseAppState2: RVBaseAppState {
    var state2: RVAppState2 = RVAppState2.loggedOut
    var installedTime: Date = Date()
    var uninstalledTime: Date = Date()



    func install(callback: @escaping() -> Void) {
        self.installedTime = Date()
        callback()
    }
    func uninstall(callback: @escaping() -> Void) {
        self.uninstalledTime = Date()
        callback()
    }
}
