//
//  RVViewDeck4.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/19/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
import ViewDeck
class RVViewDeck4: RVViewDeck {
    static let shared: RVViewDeck4 = { return RVViewDeck4()  }()
    var core: RVBaseCoreInfo8 { get { return RVBaseCoreInfo8.sharedInstance }}
    func instantiateController(storyBoard: String, controller: String) -> UIViewController {
        return UIStoryboard(name: storyBoard, bundle: nil).instantiateViewController(withIdentifier: controller)
    }
    override var leftViewController: UIViewController! {
        get { return deckController.leftViewController }
        set { deckController.leftViewController = newValue }
    }
    override var centerViewController: UIViewController! {
        get { return deckController.centerViewController }
        set { deckController.centerViewController = newValue}
    }
    override func initialize(appDelegate: AppDelegate) {
        print("IN \(self.classForCoder).initialize. SHOULD NOT BE USED ANY MORE")
        let window = UIWindow(frame: UIScreen.main.bounds)
        appDelegate.window = window
        window.tintColor = UIColor(red: 0.071, green: 0.42, blue: 0.694, alpha: 1.0)
        window.rootViewController = generateControllerStack()
        UITabBar.appearance().tintColor = UIColor().tabBarTintColor()
        window.makeKeyAndVisible()
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        UISearchBar.appearance().barTintColor = UIColor.facebookBlue()
        UISearchBar.appearance().tintColor = UIColor.white
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = UIColor.facebookBlue()
        let _ = RVBaseCoreInfo8.sharedInstance
    }
    override func generateControllerStack() -> IIViewDeckController {
        let leftController = RVControllers.shared.getController(appState: .leftMenu)
        let centerController = RVControllers.shared.getController(appState: .loggedOut)
        let deckController = IIViewDeckController(center: centerController, leftViewController: leftController)
        deckController.preferredContentSize = CGSize(width: 200, height: centerController.view.bounds.height)
        self.deckController = deckController
        deckController.delegate = self
        return deckController
    }
    override func changeState(newState: RVBaseAppState4, callback: @escaping () -> Void) {
        //print("In \(self.instanceType).changeState, with newState \(newState.appState.rawValue)")
        core.currentAppState = newState
        if newState.appState == .leftMenu {
            self.toggleSide(side: .left)

        } else {
            let controller = RVControllers.shared.getController(appState: newState.appState)
            self.centerViewController = controller
           // print("In \(self.classForCoder).changeState, prior appState is \(core.priorAppState.appState.rawValue)")
            if core.priorAppState.appState == .leftMenu  {
               // print("IN \(self.classForCoder).changeState, about to Toggle to center")
                self.toggleSide(side: .center)
            }
        }
        finishup(newState: newState, callback: callback)
    }
    func finishup(newState: RVBaseAppState4, callback: @escaping() -> Void) {
        NotificationCenter.default.post(name: NSNotification.Name(RVNotification.AppStateChanged.rawValue), object: self, userInfo: ["newAppState": newState])
        callback()
    }
    func changeIntraState(currentState: RVBaseAppState4, newIntraState: RVAppState4, callback: @escaping () -> Void) {
        //print("In \(self.instanceType).changeState, with newState \(newState.appState.rawValue)")
        if core.currentAppState == currentState {
            core.currentAppState = currentState
            print("In \(self.classForCoder).changeIntraState from \(core.currentAppState.appState.rawValue) to \(newIntraState.rawValue)")
            core.currentAppState.appState = newIntraState
        } else {
            print("In \(self.classForCoder), inconsistent change. Actually current state is \(core.currentAppState.appState.rawValue), whereas incoming current State is: \(currentState.appState.rawValue) and trying to go to: \(newIntraState.rawValue)")
        }
        finishup(newState: core.currentAppState, callback: callback)
    }
    
    
    override func openSide(side: IIViewDeckSide, animated: Bool = true) { self.deckController.open(side, animated: animated) }
    override func closeSide(animated: Bool = true) { self.deckController.closeSide(animated) }

    override func toggleSide(side: RVViewDeck.Side, animated: Bool = true) {
        //print("In \(self.classForCoder).toggleSide \(side.description)")
        let position: IIViewDeckSide = self.deckController.openSide
        if (position == IIViewDeckSide.none) {
            switch(side) {
            case .left:
                self.openSide(side: IIViewDeckSide.left, animated: animated)
            case .right:
                self.openSide(side: IIViewDeckSide.right, animated: animated)
            case .center:
                self.closeSide(animated: animated)
            }
        } else {
            self.closeSide()
        }
    }

}
