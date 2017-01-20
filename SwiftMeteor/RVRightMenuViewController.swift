//
//  RVRightMenuViewController.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 11/27/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import UIKit
import SwiftDDP

class RVRightMenuViewController: RVBaseViewController {
    static let identifier: String = "RightMenu"
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailMessageLabel: UILabel!
    
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var passwordMessageLabel: UILabel!
    
    @IBOutlet weak var registerButton: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var resetPasswordButton: UIButton!
    
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var buttonView: UIView!
    
    var listener: RVListener? = nil
    @IBAction func backButtonTouched(_ sender: UIBarButtonItem) {
        //       print("In \(self.classForCoder).backButtonTOuched toggling to center")
        //RVViewDeck.sharedInstance.toggleSide(side: .center)
        RVSwiftDDP.sharedInstance.loginWithUsername(username: RVSwiftDDP.pluggedUsername, password: RVSwiftDDP.pluggedPassword, callback: { (result, error: RVError?) in
            if let error = error {
                error.printError()
            } else {
                print("After loginWIthUsernmae \(result)")
            }
        })
    }
    
    @IBAction func registerButtonTouched(_ sender: UIButton) {
    }
    
    @IBAction func loginButtonTouched(_ sender: UIButton) {
    }

    @IBAction func resetButtonTouiched(_ sender: UIButton) {
    }

    override func addLogInOutListeners() {
        print("In \(self.classForCoder).addLoginOutListeners")
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false) { (timer) in
            if let _ = RVCoreInfo.sharedInstance.username {
                           print("In \(self.classForCoder).addLogInOutListeners toggling to center")
                    RVViewDeck.sharedInstance.toggleSide(side: .center, animated: true)

            } else {
             //   print("In \(self.classForCoder).addLogInOutListeners in RVBaseViewController need to override this method")
                var listener = RVSwiftDDP.sharedInstance.addListener(listener: self, eventType: .userDidLogin) { (_ info: [String: AnyObject]? ) -> Bool in
                  //  print("In \(self.classForCoder).addLogInOutListeners, \(RVSwiftEvent.userDidLogin.rawValue) returned")
                    RVViewDeck.sharedInstance.toggleSide(side: .center)
                    return false
                }
                if let listener = listener {
                  //  print("In \(self.classForCoder) adding userDidLogIn listener \(listener.identifier)")
                    self.listeners.append(listener)
                }
                listener = RVSwiftDDP.sharedInstance.addListener(listener: self, eventType: .userDidLogout, callback: { (_ info: [String: AnyObject]? ) -> Bool in
                  //  print("In \(self.classForCoder).addLogInOutListeners, \(RVSwiftEvent.userDidLogout.rawValue) returned")
                    return false
                })
                if let listener = listener { self.listeners.append(listener) }
                
            }
        }

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        for listener in self.listeners {
            RVSwiftDDP.sharedInstance.removeListener(listener: listener)
        }
        self.listeners = [RVListener]()
    }
    /*
    func login(email: String, password: String) {
        let email = email.lowercased()
        
        Meteor.loginWithUsername("neil.weintraut@gmail.com", password: "password", callback: { (result, error: DDPError?) in
            if let error = error {
                print(error)
            } else {
                print("After loginWIthUsernmae \(result)")
            }
        })
    }
 */
    //http://swiftdeveloperblog.com/email-address-validation-in-swift/
    func validateEmail(email: String) -> Bool  {
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx, options: NSRegularExpression.Options.caseInsensitive)
        
            let match = regex.matches(in: email, options: NSRegularExpression.MatchingOptions.anchored, range: NSRange(location: 0, length: email.characters.count ) )
            if match.count == 0 { return false }
            return true
        } catch let error {
            print("In \(self.instanceType).validateEmail, go exception creating Regex \(error.localizedDescription)")
            return false
        }
    }
}

extension RVRightMenuViewController: UITextFieldDelegate {
    
}
