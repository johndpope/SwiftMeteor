//
//  RVMenuAppState.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 2/5/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit

class RVMenuAppState: RVBaseAppState {
    override func configure() {
        self.state = .Menu
        navigationBarTitle = "Menu"
        topInTopAreaHeight = 0
        controllerOuterSegmentedViewHeight = 0.0
        bottomInTopAreaHeight = 0
        scopes = [[String: RVKeys]]()
        segmentViewFields = []
        showTopView = false
        showSearchBar = false
    }
    override func initialize(scrollView: UIScrollView?, callback: @escaping (RVError?) -> Void) {
        // do nothing
    }
}
