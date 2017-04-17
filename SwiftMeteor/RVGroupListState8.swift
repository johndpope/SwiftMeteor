//
//  RVGroupListState8.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/16/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
class RVGroupListState8: RVBaseAppState8 {
    override init() {
        super.init()
        self.path = RVStatePath8(top: .main, modelType: .Group, crud: .list )
    }
}
