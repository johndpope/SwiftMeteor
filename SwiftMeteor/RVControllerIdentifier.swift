//
//  RVControllerIdentifier.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/19/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
class RVControllerIdentifier {
    var storyboard: String
    var identifier: String
    init(storyboard: String, identifier: String) {
        self.storyboard = storyboard
        self.identifier = identifier
    }
}
class RVControllers {
    static let shared = { return RVControllers() }()
    private var controllers = [RVAppState4 : RVControllerIdentifier]()
    init() {
        controllers[.leftMenu]          = RVControllerIdentifier(storyboard: "Main4",       identifier: RVLeftMenuNavController4.identifier)
        controllers[.loggedOut]         = RVControllerIdentifier(storyboard: "LoginScene",  identifier: "LoginNavigationController")
//        controllers[.transactionList]   = RVControllerIdentifier(storyboard: "Main3",       identifier: RVMainTabBarController.identifier)
        controllers[.transactionList]   = RVControllerIdentifier(storyboard: "Main4",       identifier: RVMainTabBarViewController4.identifier)
    }
    func getController(appState: RVAppState4) -> UIViewController {
        if let identifier = controllers[appState] {
           return instantiateController(identifier: identifier)
        } else {
            print("In RVControllers.getController, failed to find match for \(appState.rawValue)")
            return UIViewController()
        }
    }
    func instantiateController(identifier: RVControllerIdentifier) -> UIViewController {
        return UIStoryboard(name: identifier.storyboard, bundle: nil).instantiateViewController(withIdentifier: identifier.identifier)
    }
}
