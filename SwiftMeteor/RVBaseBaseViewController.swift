//
//  RVBaseBaseViewController.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 2/4/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
class RVBaseBaseViewController: UIViewController {
    var instanceType: String { get { return String(describing: type(of: self)) } }
    var operation: RVOperation = RVOperation(active: false)
    var appState: RVBaseAppState {
        get { return RVCoreInfo.sharedInstance.appState }
        set { RVCoreInfo.sharedInstance.changeState(newState: newValue) }
    }
    var listeners = [RVListener]()
    var userProfile: RVUserProfile? { get { return RVCoreInfo.sharedInstance.userProfile }}
    func hideView(view: UIView?) { if let view = view { view.isHidden = true } }
    func showView(view: UIView?) { if let view = view { view.isHidden = false} }
}
