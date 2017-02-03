//
//  RVShowProfileState.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 2/2/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation

class RVShowProfileState: RVBaseAppState {
    override func configure() {
        super.configure()
        self.state = .ShowProfile
        self.showSearchBar = false
        self.showTopView = false
        self.installRefreshControl = false
        self.installSearchController = false
        self.doNotInclude = true 
    }
    override func initialize() {}
}
