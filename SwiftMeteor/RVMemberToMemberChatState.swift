//
//  RVMemberToMemberChatState.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 2/18/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
class RVMemberToMemberChatState: RVBaseAppState {
    override func configure() {
        super.configure()
        self.state = .MemberToMemberChat
        self.showSearchBar = false
        self.showTopView = false
        self.installRefreshControl = false
        self.installSearchController = false
    }
    
}
