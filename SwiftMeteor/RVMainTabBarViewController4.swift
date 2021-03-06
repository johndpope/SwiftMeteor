//
//  RVMainTabBarViewController.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/19/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
class RVMainTabBarViewController4: UITabBarController {
    static let identifier = "RVMainTabBarViewController4"
    var coreInfo: RVCoreInfo2 { get { return RVBaseCoreInfo8.shared }}
    var currentAppState: RVBaseAppState4 { get { return coreInfo.currentAppState }}
    var priorAppState: RVBaseAppState4   { get { return coreInfo.priorAppState }}
    var myCurrentAppState: RVBaseAppState4 = RVBaseAppState4(appState: .defaultState)
    var instanceType: String { get { return String(describing: type(of: self)) } }
    var deck: RVViewDeck4 { get { return RVViewDeck4.shared }}
    var priorTabIndex: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }

}
extension RVMainTabBarViewController4: RVAppStateChangeProtocol {
    internal func updateState(callback: @escaping (RVError?) -> Void) {
        let match = myCurrentAppState == currentAppState ? true : false
        print("In \(self.classForCoder).updateState and match to prior is : \(match)")
        callback(nil)
    }
}

extension RVMainTabBarViewController4: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if self.priorTabIndex == self.selectedIndex { return }
        self.priorTabIndex = self.selectedIndex
        if self.selectedIndex == 0 {
            print("In \(self.classForCoder).didSelect, changing to transactionList")
            deck.changeIntraState(currentState: coreInfo.currentAppState, newIntraState: .transactionList, callback: {
                print("In \(self.classForCoder).didSelect return from changeIntraState \(self.coreInfo.currentAppState.appState)")
            })
        } else if self.selectedIndex == 1 {
                        print("In \(self.classForCoder).didSelect, changing to groupList")
            deck.changeIntraState(currentState: coreInfo.currentAppState, newIntraState: .groupList, callback: {
                print("In \(self.classForCoder).didSelect return from changeIntraState \(self.coreInfo.currentAppState.appState)")
            })
        }

    }
}
