//
//  RVViewDeck.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 11/27/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import UIKit
import ViewDeck
import SwiftDDP

class RVViewDeck: NSObject {
    
    enum Side {
        case left
        case right
        case center
    }
    static let sharedInstance: RVViewDeck = {RVViewDeck() }()
    static let mainStorybardName: String = "Main"
    static let leftControllerIdentifier: String =  RVLeftMenuNavController.identifier
    static let rightControllerIdentifier: String = RVRightMenuViewController.identifier
    //static let centerControllerIdentifier: String = RVMainTabMenuViewController.identifier
    static let centerControllerIdentifier: String = RVMainLandingNavigationController.identifier
    
    var leftController: UIViewController!
    var rightController: UIViewController!
    var centerController: UIViewController!
    var deckController: IIViewDeckController!
    
    func initialize(appDelegate: AppDelegate) {
        Meteor.client.allowSelfSignedSSL = true // Connect to a server that users a self signed ssl certificate
        Meteor.client.logLevel = .info // Options are: .Verbose, .Debug, .Info, .Warning, .Error, .Severe, .None
        /*
        Meteor.connect("wss://rnmpassword-nweintraut.c9users.io/websocket") {
            // do something after the client connects
            print("In RVViewDeck.initiaize, returned after connect")
            /*
             Meteor.loginWithUsername("neil.weintraut@gmail.com", password: "password", callback: { (result, error: DDPError?) in
             if let error = error {
             print(error)
             } else {
             print("After loginWIthUsernmae \(result)")
             }
             })
             */
        }
 */
        let window = UIWindow(frame: UIScreen.main.bounds)
        appDelegate.window = window
        window.tintColor = UIColor(red: 0.071, green: 0.42, blue: 0.694, alpha: 1.0)
        window.rootViewController = generateControllerStack()
        window.makeKeyAndVisible()
        
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
    func openSide(side: IIViewDeckSide) {
        RVViewDeck.sharedInstance.deckController.open(side, animated: true)
    }
    func closeSide() {
        RVViewDeck.sharedInstance.deckController.closeSide(true)
    }
    func toggleSide(side: RVViewDeck.Side) {
        let position: IIViewDeckSide = RVViewDeck.sharedInstance.deckController.openSide
        if (position == IIViewDeckSide.none) {
            switch(side) {
            case .left:
                self.openSide(side: IIViewDeckSide.left)
            case .right:
                self.openSide(side: IIViewDeckSide.right)
            case .center:
                self.closeSide()
            }
        } else {
            self.closeSide()
        }
    }
}
extension RVViewDeck: IIViewDeckControllerDelegate {
    func viewDeckController(_ viewDeckController: IIViewDeckController, didOpen side: IIViewDeckSide) {
        
    }
    func viewDeckController(_ viewDeckController: IIViewDeckController, didClose side: IIViewDeckSide) {
        
    }
    func viewDeckController(_ viewDeckController: IIViewDeckController, willOpen side: IIViewDeckSide) -> Bool {
        return true
    }
    func viewDeckController(_ viewDeckController: IIViewDeckController, willClose side: IIViewDeckSide) -> Bool {
        return true
    }

}
