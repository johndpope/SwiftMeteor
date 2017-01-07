//
//  RVSlackMessage.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/6/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
class RVSlackMessage {
    var username: String = ""
    var text: String = ""
    init() {
        
    }
    init(username: String, text: String) {
        self.username = username
        self.text = text
    }
}
