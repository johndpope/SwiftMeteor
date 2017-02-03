//
//  RVWatchGroupState.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/28/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation

class RVWatchGroupInfoState: RVMainViewControllerState {
    override func configure() {
        segmentViewFields = [.WatchGroupInfo, .WatchGroupMembers, .WatchGroupMessages]
        showTopView = true
        self.state = .WatchGroupInfo
       // print("In \(self.instanceType).configure, ")
    }
}
