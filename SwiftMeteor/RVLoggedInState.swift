//
//  RVLoginState.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 2/2/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation

class RVLoggedInState: RVBaseAppState {
    override func configure() {
        super.configure()
        self.state = .LoggedIn
        self.showSearchBar = false
        self.showTopView = false
        self.installRefreshControl = false
        self.installSearchController = false
    }
}
