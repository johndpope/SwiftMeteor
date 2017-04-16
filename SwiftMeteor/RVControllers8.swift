//
//  RVControllers8.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/15/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit

import UIKit
class RVControllerProfile8 {
    var storyboard: String
    var identifier: String
    init(storyboard: String, identifier: String) {
        self.storyboard = storyboard
        self.identifier = identifier
    }
}
class RVControllers8 {
    static let shared = { return RVControllers8() }()
    private var controllers = [String: RVControllerProfile8]()
    init() {
    }
    func getController(identifier: String) -> UIViewController? {
        if let profile = self.controllers[identifier] {
            return instantiateController(identifier: profile)
        }
        return nil
    }
    func instantiateController(identifier: RVControllerProfile8) -> UIViewController {
        return UIStoryboard(name: identifier.storyboard, bundle: nil).instantiateViewController(withIdentifier: identifier.identifier)
    }
}

