//
//  RVMainLandingViewController2.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 2/2/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit

class RVMainLandingViewController2 : RVMainLandingViewController {
    var logoutListener: RVListener? = nil
    func becomeActiveButton(button: UIButton? = nil, barButton: UIBarButtonItem? = nil) -> Bool {
        return RVCoreInfo.sharedInstance.becomeActiveButtonIfNotActive(button, barButton)
    }
    func clearActiveButton(button: UIButton? = nil, barButton: UIBarButtonItem? = nil ) -> Bool {
        return RVCoreInfo.sharedInstance.clearActiveButton(button , barButton)
    }
    @IBAction func loginButtonTouched(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "SegueFromMainToLoginScene", sender: nil)
    }
    @IBAction override func doneButtonTouched(_ sender: UIBarButtonItem) {
        if !self.becomeActiveButton(button: nil, barButton: sender) { return }
        if mainState.state == .WatchGroupMessages {
            if let controller = self.presentedViewController as? RVMessageAuthorViewController {
                controller.performSegue(withIdentifier: RVMessageAuthorViewController.unwindFromMessageCreateSceneWithSegue, sender: ["Menu": true])
            } else {
                print("No controller \(self.presentedViewController)")
            }
            let _ = self.clearActiveButton(button: nil, barButton: sender)
        } else {
            mainState.unwind {
                RVViewDeck.sharedInstance.toggleSide(side: RVViewDeck.Side.left)
                let _ = self.clearActiveButton(button: nil, barButton: sender)
            }
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleState()
        addLogoutListener()
    }
    override func viewWillDisappear(_ animated: Bool) {
        if let listener = self.logoutListener { RVSwiftDDP.sharedInstance.removeListener(listener: listener)}
        super.viewWillDisappear(animated)
    }
    func handleState() {
        if !RVCoreInfo.sharedInstance.isUserLoggedIn {
            performSegue(withIdentifier: "SegueFromMainToLoginScene", sender: nil)
            return
        }
        mainState.unwind {
            
        }
        if let tableView = self.tableView {
            tableView.beginUpdates()
            mainState.manager.sections = [RVBaseDataSource]()
            tableView.reloadData()
            tableView.endUpdates()
        }
       // mainState.unwind {
            let _ = RVCoreInfo.sharedInstance.changeState(newState: RVWatchGroupListState(scrollView: self.dsScrollView, stack: self.mainState.stack))
            if RVSwiftDDP.sharedInstance.connected { DispatchQueue.main.async { self.loadup() } }
            else {
                RVSwiftDDP.sharedInstance.connect {
                    if RVSwiftDDP.sharedInstance.connected { self.loadup() }
                }
            }

       // }
    }
    func addLogoutListener() {
        self.logoutListener = RVSwiftDDP.sharedInstance.addListener(listener: self, eventType: .userDidLogout) { (info) -> Bool in
            print("In \(self.classForCoder). handle Logout Listener")
            self.handleState()
            return true
        }
    }
    func returnFromSideMenu() {
        handleState()
    }
}
