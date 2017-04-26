//
//  RVUserListState8.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/25/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
import Foundation
class RVUserListState8: RVBaseAppState8 {
    override init() {
        super.init()
        self.path = RVStatePath8(top: .main, modelType: .userProfile, crud: .list )
    }
}
