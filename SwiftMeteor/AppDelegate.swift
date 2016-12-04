//
//  AppDelegate.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 11/27/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import UIKit



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        RVViewDeck.sharedInstance.initialize(appDelegate: self)
        let _ = RVAWSDirect.sharedInstance
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        //let _ = AWSMobileClient.sharedInstance.didFinishLaunching(application: application, withOptions: launchOptions)
        //RVAWSDirect.sharedInstance.launch()

        
        
        let path = "elmerfudd.jpg"
        RVAWSDirect.sharedInstance.download2(path: path, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                print("Got Error RVAWSDirect.download2 \(error)")
            } else if let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    print("Successful RVAWSDirect.download2)")
                    if let data = data {
                        print("Successful RVAWDDirect.download2 data \(data.bytes.count)")
                    }
                }
            } else {
                print("In RVAWSDirect.download2 no error no response")
            }
        })
 
   //     let u = URLRequest(url: URL(string: "http://www.google.com/goober")!)
 //       let session = URLSession.shared.downloadTask(with: u , completionHandler: {(url: URL?, respone: URLResponse?, error: Error?) in })
//        session.resume()
   //     let session2 = URLSession.shared.dataTask(with: u)
     //   session2.resume()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        AWSMobileClient.sharedInstance.applicationDidBecomeActive(application: application)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

