//
//  RVLeftMenuAppState8.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/16/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
class RVLeftMenuAppState8: RVBaseAppState8 {
    override init() {
        super.init()
        self.path = RVStatePath8(top: .leftMenu, modelType: .baseModel, crud: .list )
    }
    
}
