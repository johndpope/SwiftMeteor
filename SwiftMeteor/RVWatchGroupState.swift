//
//  RVWatchGroupState.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/28/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation

class RVWatchGroupState: RVMainViewControllerState {
    override func configure() {
        segmentViewFields = [.WatchGroup, .Members, .Forum]
        showTopView = true
    }
}
