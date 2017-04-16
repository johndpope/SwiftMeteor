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
    var instanceType: String { get { return String(describing: type(of: self)) } }
    var storyboard: String
    var identifier: String
    init(storyboard: String, identifier: String) {
        self.storyboard = storyboard
        self.identifier = identifier
    }
}
class RVControllers8 {
    var instanceType: String { get { return String(describing: type(of: self)) } }
    static let shared = { return RVControllers8() }()
    fileprivate var controllers = [String: RVControllerProfile8]()
    init() {
        self.controllers = [
            RVTop.leftMenu.rawValue : RVControllerProfile8(storyboard: "Main4",      identifier: RVLeftMenuNavController4.identifier),
            RVTop.loggedOut.rawValue: RVControllerProfile8(storyboard: "LoginScene", identifier: RVLoginNavController8.identifier),
            RVTop.main.rawValue     : RVControllerProfile8(storyboard: "Main8",      identifier: RVMainTabBarController8.identifier)
        ]
    }
    func sameController(targetTop: RVTop, controller: UIViewController) -> Bool {
        return sameController(targetIdentifier: targetTop.rawValue, controller: controller)
    }
    func sameController(targetIdentifier: String, controller: UIViewController) -> Bool {
        if let controller = controller as? RVIdentifierProtocol {
            let candidate = self.controllers[targetIdentifier]
            if let candidate = candidate {
                if candidate.identifier == controller.staticIdentifier { return true }
            } else {
                print("In \(self.instanceType).sameController no entry for \(targetIdentifier)")
            }
        } else {
            print("In \(self.instanceType).sameController controller \(controller) does not support RVIdentifierProtocol")
        }
        return false
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

