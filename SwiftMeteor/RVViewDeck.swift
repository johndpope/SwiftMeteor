//
//  RVViewDeck.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 11/27/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import UIKit
import ViewDeck

class RVViewDeck: NSObject {
    var listeners = RVListeners()
    enum Side {
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
    var instanceType: String { get { return String(describing: type(of: self)) } }
    static let sharedInstance: RVViewDeck = {RVViewDeck() }()
    static let mainStorybardName: String = "Main"
    static let leftControllerIdentifier: String =  RVLeftMenuNavController.identifier
  //  static let rightControllerIdentifier: String = RVRightMenuViewController.identifier
    static let rightControllerIdentifier: String = RVRightNavigationController.identiifer
    //static let centerControllerIdentifier: String = RVMainTabMenuViewController.identifier
    static let centerControllerIdentifier: String = RVMainLandingNavigationController.identifier
    
    var leftController: UIViewController!
    var rightController: UIViewController!
    var centerController: UIViewController!
    var deckController: IIViewDeckController!
    
    func initialize(appDelegate: AppDelegate) {
        RVSwiftDDP.sharedInstance.connect {
            //print("In \(self.instanceType).initialize, returned from connecting with Meteor")
        }
        let window = UIWindow(frame: UIScreen.main.bounds)
        appDelegate.window = window
        window.tintColor = UIColor(red: 0.071, green: 0.42, blue: 0.694, alpha: 1.0)
        window.rootViewController = generateControllerStack()
        window.makeKeyAndVisible()
        
    }
    func addListener(listener: NSObject, eventType: RVSwiftEvent, callback: @escaping (_ info: [String: AnyObject]? )-> Bool)-> RVListener {
        return listeners.addListener(listener: listener , eventType: eventType, callback: callback)
    }
    func removeListener(listener: RVListener) {
        listeners.removeListener(listener: listener)
    }
    func userDidLogin() {
        print("In RVViewDeck, The user just signed in!")
    }
    func generateControllerStack() -> IIViewDeckController {
        let storyboard = UIStoryboard(name: RVViewDeck.mainStorybardName, bundle: nil)
        let leftViewController = storyboard.instantiateViewController(withIdentifier: RVViewDeck.leftControllerIdentifier)
        let rightViewController = storyboard.instantiateViewController(withIdentifier: RVViewDeck.rightControllerIdentifier)
        let tabBarController = storyboard.instantiateViewController(withIdentifier: RVViewDeck.centerControllerIdentifier)
        
        
        UITabBar.appearance().tintColor = UIColor().tabBarTintColor()
        //let centerController = UINavigationController(rootViewController: tabBarController)
        let deckController = IIViewDeckController(center: tabBarController, leftViewController: leftViewController, rightViewController: rightViewController)
        deckController.preferredContentSize = CGSize(width: 200, height: tabBarController.view.bounds.height)
        self.deckController = deckController
        deckController.delegate = self
        self.leftController = deckController.leftViewController
        self.rightController = deckController.rightViewController
        return deckController
    }
    func openSide(side: IIViewDeckSide, animated: Bool = true) {
        self.deckController.open(side, animated: animated)
    }
    func closeSide(animated: Bool = true) {
        RVViewDeck.sharedInstance.deckController.closeSide(animated)
    }
    var sideBeingShown: RVViewDeck.Side {
        get {
            let position: IIViewDeckSide = self.deckController.openSide
            switch(position) {
            case .left:
                return RVViewDeck.Side.left
            case .right:
                return RVViewDeck.Side.right
            case .none:
                return RVViewDeck.Side.center
            }
        }

    }
    func toggleSide(side: RVViewDeck.Side, animated: Bool = true) {
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
extension RVViewDeck: IIViewDeckControllerDelegate {
    /// @name Open and Close Sides
    
    /**
     Tells the delegate that the specified side will open.
     
     @param viewDeckController The view deck controller informing the delegate.
     @param side               The side that will open. Either `IIViewDeckSideLeft` or `IIViewDeckSideRight`.
     
     @return `YES` if the View Deck Controller should open the side in question, `NO` otherwise.
     */
    func viewDeckController(_ viewDeckController: IIViewDeckController, willOpen side: IIViewDeckSide) -> Bool {
        
       return true
    }
    
    
    /**
     Tells the delegate that the specified side did open.
     
     @param viewDeckController The view deck controller informing the delegate.
     @param side               The side that did open. Either `IIViewDeckSideLeft` or `IIViewDeckSideRight`.
     */
    func viewDeckController(_ viewDeckController: IIViewDeckController, didOpen side: IIViewDeckSide) {
        print("In \(self.classForCoder).viewDeckController didOpen \(side.rawValue)--------------")
        /*
        for listener in listeners.listeners {
            if listener.eventType == .viewDeckDidOpen {
                print("In \(self.classForCoder).didOpen")
                if !listener.handler([RVSwiftEvent.viewDeckDidOpen.rawValue : side as AnyObject  ]) {
                    break
                }
            }
        }
 */
    }
    
    
    /**
     Tells the delegate that the specified side will close.
     
     @param viewDeckController The view deck controller informing the delegate.
     @param side               The side that will close. Either `IIViewDeckSideLeft` or `IIViewDeckSideRight`.
     
     @return `YES` if the View Deck Controller should close the side in question, `NO` otherwise.
     */
    func viewDeckController(_ viewDeckController: IIViewDeckController, willClose side: IIViewDeckSide) -> Bool {
        print("In \(self.classForCoder).viewDeckController WillClose \(side.rawValue)--------------")
        return true
    }
    
    
    /**
     Tells the delegate that the specified side did close.
     
     @param viewDeckController The view deck controller informing the delegate.
     @param side               The side that did close. Either `IIViewDeckSideLeft` or `IIViewDeckSideRight`.
     */
    func viewDeckController(_ viewDeckController: IIViewDeckController, didClose side: IIViewDeckSide) {
        print("In \(self.classForCoder).viewDeckController didClose \(side.rawValue)--------------")
        if self.deckController.openSide == IIViewDeckSide.none {
            print("In \(self.classForCoder).didClose, have side none")
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { (timer) in
                if let navController = self.deckController.centerViewController as? RVMainLandingNavigationController {
                    if let controller = navController.topViewController as? RVMainLandingViewController {
                        controller.checkForLoggedOut()
                    } else {
                        print("In \(self.classForCoder).didClose, failed to get MainLandingViewController")
                    }
                } else {
                    print("In \(self.classForCoder).didClose, failed to cast navController \(self.centerController)")
                }
            })

        } else {
                            print("In \(self.classForCoder).didClose, have side \(self.deckController.openSide)")
        }
        
    }


}
