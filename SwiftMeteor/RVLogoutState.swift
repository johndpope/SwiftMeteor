//
//  RVLogoutState.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 2/2/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
class RVLogoutState: RVBaseAppState {
    override func configure() {
        super.configure()
        self.state = .LoggedOut
        self.showSearchBar = false
        self.showTopView = false
        self.installRefreshControl = false
        self.installSearchController = false
    }
    
}
