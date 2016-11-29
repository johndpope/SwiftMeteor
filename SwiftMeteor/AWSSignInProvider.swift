//
//  AWSSignInProvider.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 11/28/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import UIKit
import AWSCore
public protocol AWSSignInProvider: AWSIdentityProvider {
    
    /**
     Determines if a user is logged in.
     */
    var loggedIn: Bool {get}
    /**
     The URL for profile image of a user.
     */
    var imageURL: NSURL { get }
    /**
     The User Name of a user.
     */
    var userName: String { get}
    /**
     The login handler method for the Sign-In Provider.
     The completionHandler will bubble back errors to the developers.
     */
    func login(completionHandler: (AnyObject?, NSError) -> Void )
    //var completionHanlder: (AnyObject?, NSError) -> Void {get set}
    /**
     The logout handler method for the Sign-In Provider.
     */
    func logout() -> Void
    
    /**
     The handler method for managing the session reload for the Sign-In Provider.
     */
    func reloadSession() -> Void
    
    func interceptApplication(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    
    func interceptApplication(application: UIApplication, openURL: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool
    
}


