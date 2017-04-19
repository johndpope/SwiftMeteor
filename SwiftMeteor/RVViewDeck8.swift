//
//  RVViewDeck8.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/16/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
import ViewDeck
enum RVViewDeckSide {
    case left
    case right
    case center
    var description: String {
        switch(self){
        case .left:
            return "Left"
        case .right:
            return "Right"
        case .center:
            return "Center"
        }
    }
}

class RVViewDeck8: NSObject {
    static let previousStateKey: String = "previousStateKey"
    static let newStateKey: String = "newStateKey"
    static let MeteorConnected: Notification.Name = Notification.Name("MeteorConnected")
    static let MeteorDisconnected: Notification.Name = Notification.Name("MeteorDisconnected")
    var instanceType: String { get { return String(describing: type(of: self)) } }
    static let shared: RVViewDeck8 = { return RVViewDeck8()  }()
    var core: RVBaseCoreInfo8 { return RVBaseCoreInfo8.sharedInstance }
    var deckController: IIViewDeckController = IIViewDeckController()
    var statePriorToMenu: RVBaseAppState8? = nil
    
    var leftViewController: UIViewController! {
        get { return deckController.leftViewController }
        set { deckController.leftViewController = newValue }
    }
    var centerViewController: UIViewController! {
        get { return deckController.centerViewController }
        set { deckController.centerViewController = newValue}
    }
    func initialize(appDelegate: AppDelegate) {
        let _ = core
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

        if !RVSwiftDDP.sharedInstance.connected {RVSwiftDDP.sharedInstance.connect() }
    }
    /*
    func ddpConnected(notification: NSNotification) {
        print("In \(self.classForCoder).ddpConnected ")
    }
    func ddpDisconnected(notification: NSNotification) {
        print("In \(self.classForCoder).ddpDisconnected")
        
    }
 */
    func generateControllerStack() -> IIViewDeckController {
        var leftController = UIViewController()
        var centerController =  leftController
        if let controller = RVControllers8.shared.getController(identifier: RVTop.leftMenu.rawValue) as? RVLeftMenuNavController4 {
            leftController = controller
        } else {
            print("In \(self.instanceType).generateControllerStack, failed to get LeftController for \(RVTop.leftMenu.rawValue)")
        }
        if let controller = RVControllers8.shared.getController(identifier: RVTop.loggedOut.rawValue) {
            centerController = controller
        } else {
            print("In \(self.instanceType).generateControllerStack, failed to get CenterController for \(RVTop.loggedOut.rawValue)")
        }
        let deckController      = IIViewDeckController(center: centerController, leftViewController: leftController)
        deckController.preferredContentSize = CGSize(width: 200, height: centerController.view.bounds.height)
        self.deckController = deckController
        deckController.delegate = self
        return deckController
    }
    func openSide(side: IIViewDeckSide, animated: Bool = true) { self.deckController.open(side, animated: animated) }
    func closeSide(animated: Bool = true) { self.deckController.closeSide(animated) }
    
    func toggleSide(side: RVViewDeckSide, animated: Bool = true) {
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
    func returnToCenter(callback: @escaping ()-> Void ) {
        if let prior = self.statePriorToMenu { RVStateDispatcher8.shared.changeState(newState: prior, returnToCenter: true) }
    }
    func viewDeckChangeState(newState: RVBaseAppState8, previousState: RVBaseAppState8, returnToCenter: Bool, callback: @escaping()-> Void) {
      //  print("In \(self.classForCoder).viewDeckChangeState \(newState) and previousState is: \(previousState)")
        if !returnToCenter {
            let newPath = newState.path
            let previousPath = previousState.path
            if newPath.top != previousPath.top {
                switch (newPath.top) {
                case .leftMenu:
                   // print("In \(self.classForCoder).viewDeckChangeState, previousState is \(previousState)")
                    self.statePriorToMenu = previousState
                    self.toggleSide(side: .left)
                case .loggedOut:
                    evaluateNewController(targetTop: .loggedOut)
                    self.toggleSide(side: .center)
                case .main:
                    evaluateNewController(targetTop: .main)
                    self.toggleSide(side: .center)

                }
            }
        } else {
            self.toggleSide(side: .center)
        }
        finishup(newState: newState, previousState: previousState, callback: callback)
    }
    func finishup(newState: RVBaseAppState8, previousState: RVBaseAppState8, callback: @escaping() -> Void) {
        NotificationCenter.default.post(name: NSNotification.Name(RVNotification.AppStateChanged.rawValue), object: self, userInfo: [RVViewDeck8.previousStateKey: previousState, RVViewDeck8.newStateKey: newState])
        DispatchQueue.main.async {
            callback()
        }
    }
    func evaluateNewController(targetTop: RVTop) {
        if !RVControllers8.shared.sameController(targetTop: targetTop, controller: self.centerViewController) {
            if let controller = RVControllers8.shared.getController(identifier: targetTop.rawValue) {
                self.centerViewController = controller
            } else {
                print("In \(self.classForCoder).evaluateNewController, failed to get controller \(targetTop.rawValue)")
            }
        }
    }
}
extension RVViewDeck8: IIViewDeckControllerDelegate {
    /// @name Open and Close Sides
    
    /**
     Tells the delegate that the specified side will open.
     
     @param viewDeckController The view deck controller informing the delegate.
     @param side               The side that will open. Either `IIViewDeckSideLeft` or `IIViewDeckSideRight`.
     
     @return `YES` if the View Deck Controller should open the side in question, `NO` otherwise.
     */
    func viewDeckController(_ viewDeckController: IIViewDeckController, willOpen side: IIViewDeckSide) -> Bool { return true }
    
    
    /**
     Tells the delegate that the specified side did open.
     
     @param viewDeckController The view deck controller informing the delegate.
     @param side               The side that did open. Either `IIViewDeckSideLeft` or `IIViewDeckSideRight`.
     */
    func viewDeckController(_ viewDeckController: IIViewDeckController, didOpen side: IIViewDeckSide) {
        // print("In \(self.classForCoder).didOpen, side: \(side.rawValue)")
        switch(self.deckController.openSide) {
        default:
            let _ = 1
        }
    }
    
    
    /**
     Tells the delegate that the specified side will close.
     
     @param viewDeckController The view deck controller informing the delegate.
     @param side               The side that will close. Either `IIViewDeckSideLeft` or `IIViewDeckSideRight`.
     
     @return `YES` if the View Deck Controller should close the side in question, `NO` otherwise.
     */
    func viewDeckController(_ viewDeckController: IIViewDeckController, willClose side: IIViewDeckSide) -> Bool {
        //   print("In \(self.classForCoder).viewDeckController WillClose \(side.rawValue)--------------")
        return true
    }
    
    
    /**
     Tells the delegate that the specified side did close.
     
     @param viewDeckController The view deck controller informing the delegate.
     @param side               The side that did close. Either `IIViewDeckSideLeft` or `IIViewDeckSideRight`.
     */
    func viewDeckController(_ viewDeckController: IIViewDeckController, didClose side: IIViewDeckSide) {

        switch(self.deckController.openSide) {
        default:
            let _ = 0
        }
    }
}
