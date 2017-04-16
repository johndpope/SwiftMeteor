//
//  RVBaseViewController8.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/16/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
class RVBaseViewController8: UIViewController {
    var operation: RVOperation = RVOperation(active: false) // outdated method
    var instanceType: String { get { return String(describing: type(of: self)) } }
    var core: RVBaseCoreInfo8 { return RVBaseCoreInfo8.sharedInstance }
    var userProfile: RVUserProfile? { return core.loggedInUserProfile }
    var userProfileId: String? { return core.loggedInUserProfileId }
    func hideView(view: UIView?) { if let view = view { view.isHidden = true } }
    func showView(view: UIView?) {
        if let view = view { view.isHidden = false}
        else {print("In \(self.classForCoder).showView, view doesn't exist") }
    }
}
