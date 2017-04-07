//
//  AWSMobileClient.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 11/28/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import UIKit
import AWSCore


/**
 * AWSMobileClient is a singleton that bootstraps the app. It creates an identity manager to establish the user identity with Amazon Cognito.
 */
class AWSMobileClient: NSObject {
    
    // Shared instance of this class
    static let sharedInstance = AWSMobileClient()
    private var isInitialized: Bool
    
    private override init() {
        isInitialized = false
        super.init()
    }
    
    deinit {
        // Should never be called
        print("Mobile Client deinitialized. This should not happen.")
    }
    
    /**
     * Configure third-party services from application delegate with url, application
     * that called this provider, and any annotation info.
     *
     * - parameter application: instance from application delegate.
     * - parameter url: called from application delegate.
     * - parameter sourceApplication: that triggered this call.
     * - parameter annotation: from application delegate.
     * - returns: true if call was handled by this component
     */
    func withApplication(application: UIApplication, withURL url: NSURL, withSourceApplication sourceApplication: String?, withAnnotation annotation: AnyObject) -> Bool {
        print("withApplication:withURL")
        if let manager = AWSIdentityManager.defaultIdentityManager() {
            if (manager.interceptApplication(application: application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)) {
                if (!isInitialized) { isInitialized = true }
                print("In AWSMobileClient, third party services successfully initialized")
            } else {
                print("In AWSMobileClient, third-party services initialization did not succeed")
            }
        } else {
            print("In AWSMobileClient, third-party services initialization did not produce a defaultIdentityManager")
        }
        return false;
    }
    
    /**
     * Performs any additional activation steps required of the third party services
     * e.g. Facebook
     *
     * - parameter application: from application delegate.
     */
    func applicationDidBecomeActive(application: UIApplication) {
        print("applicationDidBecomeActive:")
    }
    
    
    /**
     * Configures all the enabled AWS services from application delegate with options.
     *
     * - parameter application: instance from application delegate.
     * - parameter launchOptions: from application delegate.
     */
    func didFinishLaunching(application: UIApplication, withOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        print("didFinishLaunching:")
        if let manager = AWSIdentityManager.defaultIdentityManager() {
            let didFinishLaunching: Bool = manager.interceptApplication(application: application, didFinishLaunchingWithOptions: launchOptions)
            if (!isInitialized) {
                if let manager = AWSIdentityManager.defaultIdentityManager() {
                    manager.resumeSessionWithCompletionHandler(completionHandler: {(result: AnyObject?, error: NSError?) -> Void in
                        print("In DidFinishLaunching with Result: \(result ?? "no result" as AnyObject) \n Error:\(error ?? "No error")")
                    }) // If you get an EXC_BAD_ACCESS here in iOS Simulator, then do Simulator -> "Reset Content and Settings..."
                    // This will clear bad auth tokens stored by other apps with the same bundle ID.
                    isInitialized = true
                } else {
                     print ("In AWSMobileClient did not get defaultIdentityManager after intercept")
                }
            } else {
                print("Is initialized in AWSMobileClient.didFinishLaunching")
            }
            return didFinishLaunching
        } else {
            print ("In AWSMobileClient did not get defaultIdentityManager")
        }

        return true

    }
}
