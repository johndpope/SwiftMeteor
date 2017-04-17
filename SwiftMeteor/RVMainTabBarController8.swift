//
//  RVMainTabBarController8.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/15/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit


class RVMainTabBarController8: UITabBarController, RVIdentifierProtocol {
    static let identifier = "RVMainTabBarController8"
    var staticIdentifier: String { get { return RVMainTabBarController8.identifier }}
    var coreInfo: RVCoreInfo2 { get { return RVCoreInfo2.shared }}
    var currentAppState: RVBaseAppState4 { get { return coreInfo.currentAppState }}
    var priorAppState: RVBaseAppState4   { get { return coreInfo.priorAppState }}
    var myCurrentAppState: RVBaseAppState4 = RVBaseAppState4(appState: .defaultState)
    var instanceType: String { get { return String(describing: type(of: self)) } }
    var deck: RVViewDeck4 { get { return RVViewDeck4.shared }}
    var priorTabIndex: Int = 0
    let transactionTab = 0
    let groupTab = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(RVMainTabBarController8.appStateChanged(notification:)), name: NSNotification.Name(RVNotification.AppStateChanged.rawValue), object: nil)
    }
    func appStateChanged(notification: Notification) {
        // print("In \(self.classForCoder).appStateChanged")
        if let userInfo = notification.userInfo as? [String : AnyObject] {
         //   let previouState = userInfo[RVViewDeck8.previousStateKey]
            var newIndex = -1
            if let newState =  userInfo[RVViewDeck8.newStateKey] as? RVBaseAppState8 {
                switch (newState.path.modelType) {
                case .transaction:
                    newIndex = transactionTab
                case .Group:
                    newIndex = groupTab
                default:
                    break
                }
                if newIndex >= 0 {
                    if newIndex != self.selectedIndex {
                        self.selectedIndex = newIndex
                    }
                }
            }
        }
    
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


extension RVMainTabBarController8: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if self.priorTabIndex == self.selectedIndex { return }
        self.priorTabIndex = self.selectedIndex
        if self.selectedIndex == 0 {
           // print("In \(self.classForCoder).didSelect, changing to transactionList")
            RVStateDispatcher8.shared.changeState(newState: RVTransactionListState8())
        } else if self.selectedIndex == 1 {
           // print("In \(self.classForCoder).didSelect, changing to groupList")
            RVStateDispatcher8.shared.changeState(newState: RVGroupListState8())
        }
        
    }
}
