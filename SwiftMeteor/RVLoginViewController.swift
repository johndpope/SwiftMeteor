//
//  RVLoginViewController.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 2/2/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
import SwiftDDP
class RVLoginViewController: RVBaseViewController8 {
    
    @IBAction func loginButtonTouched(_ sender: UIButton) {
        self.hideLoginFailure()
        if let emailField = self.emailTextField {
            if let email = emailField.text {
                if email.validEmail() {
                    if let passwordField = self.passwordTextField {
                        if let password = passwordField.text {
                            if password.validPassword() {
                                var operation = self.operation
                                if operation.active {
                                    operation.cancelled = true
                                    self.operation = RVOperation(active: true, name: "\(Date().timeIntervalSince1970)")
                                    operation = self.operation
                                }
                                operation.active = true
                                RVSwiftDDP.sharedInstance.loginWithPassword(email: email.lowercased(), password: password, completionHandler: { (result, error) in
                                    if let _ = error {
                                        //error.printError()
                                        self.hideButtons()
                                        self.showLoginFailure()
                                    } else {
                                        // print("In \(self.classForCoder).loginButtonTOuched. Logged in")
                                        self.hideButtons()
                                        self.hideView(view: self.passwordView)
                                        self.loginRegisterState = nil
                                        RVStateDispatcher4.shared.changeState(newState: RVBaseAppState4(appState: .transactionList))
                                    }
                                    if operation.identifier == self.operation.identifier {
                                        self.operation = RVOperation(active: false)
                                    }
                                })
                            }
                        }
                    }
                }
            }
        }
    }
    @IBAction func registerButtonTouched(_ sender: UIButton) {
        self.hideLoginFailure()
        if let emailField = self.emailTextField {
            if let email = emailField.text {
                if email.validEmail() {
                    if let passwordField = self.passwordTextField {
                        if let password = passwordField.text {
                            if password.validPassword() {
                                var operation = self.operation
                                if operation.active {
                                    operation.cancelled = true
                                    operation = RVOperation(active: false)
                                    self.operation = operation
                                }
                                operation.active = true
                                RVSwiftDDP.sharedInstance.signupViaEmail(email: email.lowercased(), password: password, profile: nil, callback: { (error) in
                                    if let error = error {
                                        error.printError()
                                        self.hideButtons()
                                        self.showLoginFailure()
                                    } else {
                                        RVSwiftDDP.sharedInstance.loginWithPassword(email: email.lowercased(), password: password , completionHandler: { (result, error) in
                                            if let error = error {
                                                error.printError()
                                                self.hideButtons()
                                                self.showLoginFailure()
                                                self.loginRegisterState = nil
                                            } else {
                                                //print("In \(self.classForCoder).registerButtonTouched. Registered")
                                                self.hideButtons()
                                                self.hideView(view: self.passwordView)
                                                self.loginRegisterState = nil
                                            }
                                            if operation.identifier == self.operation.identifier {
                                                self.operation = RVOperation(active: false)
                                            }
                                        })
                                    }
                                })
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func resetPasswordButtonTouched(_ sender: UIButton) {
    }

    override func viewDidLoad() {
       // print("In \(self.classForCoder).viewDidLoad \(self.presentationController) \(self.presentingViewController)")
        hideView(view: passwordView)
        hideView(view: passwordMessageLabel)
        hideView(view: emailMessageLabel)
        hideView(view: loginFailureView)
        hideButtons()
       // addLogInOutListeners()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !RVSwiftDDP.sharedInstance.connected {RVSwiftDDP.sharedInstance.connect {}}
        // print("In \(self.classForCoder).viewDidAppear \(self.presentingViewController)")
    }
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailMessageLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordMessageLabel: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var resetPasswordButton: UIButton!
    @IBOutlet weak var loginFailureView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var registerButtonView: UIView!
    var loginRegisterState: String? = nil {
        didSet {
            if let state = loginRegisterState {
                if state == "Login" {
                    showLoginButton()
                } else {
                    showRegisterButton()
                }
            } else {
                hideButtons()
            }
        }
    }
    /*
    func addLogInOutListeners() {
       // print("In \(self.classForCoder).addLogInOutListeners Installing Listeners")
        var listener = RVSwiftDDP.sharedInstance.addListener(listener: self, eventType: .userDidLogin) { (_ info: [String: AnyObject]? ) -> Bool in
       // print("In \(self.classForCoder).addLogInOutListeners callback, \(RVSwiftEvent.userDidLogin.rawValue) returned")
            print("\(self.appState)")
            self.appState.unwind {
                //print("In \(self.classForCoder).addLogInOutListeners(), returned from unwind")
                self.performSegue(withIdentifier: "UnwindFromLoginToMainLanding" , sender: nil)
            }
            return true
        }
        if let listener = listener { listeners.append(listener) }
        listener = RVSwiftDDP.sharedInstance.addListener(listener: self, eventType: .userDidLogout, callback: { (_ info: [String: AnyObject]? ) -> Bool in
            print("In \(self.classForCoder).addLogInOutListeners, \(RVSwiftEvent.userDidLogout.rawValue) returned")
            return true
        })
        if let listener = listener { listeners.append(listener) }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        for listener in self.listeners {
            RVSwiftDDP.sharedInstance.removeListener(listener: listener)
        }
        self.listeners = [RVListener]()
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

extension RVLoginViewController: UITextFieldDelegate {
    func showRegisterButton() {
        showView(view: registerButtonView)
        hideView(view: buttonView)
    }
    func showLoginButton() {
        showView(view: buttonView)
        hideView(view: registerButtonView)
    }
    func hideButtons() {
        hideView(view: registerButtonView)
        hideView(view: buttonView)
    }
    func hideLoginFailure() {
        hideView(view: loginFailureView)
    }
    func showLoginFailure() {
        showView(view: loginFailureView)
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }// return NO to disallow editing.
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }// became first responder
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    } // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }// may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        
    }// if implemented, called in place of textFieldDidEndEditing:
    
    func showHidePasswordMessage(message: String, show: Bool) {
        if let label = self.passwordMessageLabel {
            if show {
                if message.characters.count > 0 {
                    label.text = message
                    label.isHidden = false
                } else {
                    label.text = ""
                    label.isHidden = true
                }
            } else {
                label.isHidden = true
            }
        }
    }
    func showHideEmailMessage(message: String, show: Bool) {
        if let label = self.emailMessageLabel {
            if show {
                if message.characters.count > 0 {
                    label.text = message
                    label.isHidden = false
                } else {
                    label.text = ""
                    label.isHidden = true
                }
            } else {
                label.isHidden = true
            }
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
      //  print("In \(self.classForCoder).shouldChangeCharacters \(string.characters.count)")
        self.hideLoginFailure()
        let emailField = (self.emailTextField != nil) && textField == emailTextField
        let passwordField = (self.passwordTextField != nil) && textField == self.passwordTextField
        var text = (textField.text != nil) ? textField.text! : ""
        var count = text.characters.count
        let combined = "\(text)\(string)"
        if string == "" {
            
            if count <= 1 {
                if emailField {
                    showHideEmailMessage(message: "Invalid email", show: true)
                    hideButtons()
                    return true
                } else if passwordField {
                    showHidePasswordMessage(message: "Invalid Password", show: true)
                    hideButtons()
                    return true
                } else {
                    return false
                }
            } else {
                let candidate = text.substring(to: count - 1)
                if emailField {
                    if candidate.validEmail() {
                        lookup(email: candidate)
                        showHideEmailMessage(message: "", show: false)
                        showView(view: passwordView)
                        return true
                    } else {
                        showHideEmailMessage(message: "Invalid email", show: true)
                        hideView(view: passwordView)
                        hideButtons()
                        return true
                    }
                } else if passwordField {
                    if candidate.validPassword() {
                      //  print("IN \(self.classForCoder).shouldChange, have password \(candidate), ")
                        showHidePasswordMessage(message: "", show: false)
                        if let state = self.loginRegisterState {
                            if state == "Login" {
                                showLoginButton()
                            } else {
                                showRegisterButton()
                            }
                        } else {
                            print("In \(self.classForCoder).shouldChange... state is not loginRegisterState")
                        }
                        return true
                    } else {
                        showHidePasswordMessage(message: "Invalid Password", show: true)
                        return true
                    }
                } else {
                    return false
                }
            }
        } else if string == " " {
            print("IN \(self.classForCoder).shouldChange, have string \(string), ")
            if emailField {
                if text.validEmail() {
                    //lookup(email: text)
                    showHideEmailMessage(message: "", show: false)
                    showView(view: passwordView)
                    return false
                } else {
                    showHideEmailMessage(message: "Invalid email", show: true)
                    hideView(view: passwordView)
                    hideButtons()
                    return false
                }
            } else if passwordField {
                if text.validPassword() {
                    showHidePasswordMessage(message: "", show: false)
               //     print("IN \(self.classForCoder).shouldChange, have password \(text), ")
                    if let state = self.loginRegisterState {
                        if state == "Login" {
                            showLoginButton()
                        } else {
                            showRegisterButton()
                        }
                    }
                    return false
                } else {
                    showHidePasswordMessage(message: "Invalid Password", show: true)
                    return false
                }
            } else {
                return false
            }
        }
        if string.characters.count == 1 {
            if emailField {
                if combined.validEmail() {
                    lookup(email: combined)
                    showHideEmailMessage(message: "", show: false)
                    showView(view: passwordView)
                    return true
                } else {
                    showHideEmailMessage(message: "Invalid email", show: true)
                    hideView(view: passwordView)
                    hideButtons()
                    return true
                }
            } else if passwordField {
                if combined.validPassword() {
               //      print("IN \(self.classForCoder).shouldChange, have password with count == 1 \(text), string: \(string)")
                    showHidePasswordMessage(message: "", show: false)
                    if let state = self.loginRegisterState {
                 //       print("In \(self.classForCoder).shouldChange state have loginRegisterState")
                        if state == "Login" {
                      //       print("In \(self.classForCoder).shouldChange state have loginRegisterState showing LoginButton")
                            showLoginButton()
                        } else {
                     //       print("In \(self.classForCoder).shouldChange state have loginRegisterState showing RegisterButton")
                            showRegisterButton()
                        }
                    } else {
                        print("In \(self.classForCoder).shouldChange state is not loginRegisterState")
                    }
                    return true
                } else {
                    showHidePasswordMessage(message: "Invalid password", show: true)
                    return true
                }
            } else {
                // should not get here
                return false
            }
        }
        count = string.characters.count
        let scrubbed = string.replacingOccurrences(of: " ", with: "")
        if scrubbed.characters.count != count {
            return false
        } else {
            if emailField {
                if combined.validEmail() {
                    lookup(email: combined)
                    showHideEmailMessage(message: "", show: false)
                    showView(view: passwordView)
                    return true
                } else {
                    showHideEmailMessage(message: "Invalid email", show: true)
                    hideView(view: passwordView)
                    hideButtons()
                    return true
                }
            } else if passwordField {
                if combined.validPassword() {
                    showHidePasswordMessage(message: "", show: false)
                    return true
                } else {
                    showHidePasswordMessage(message: "Invalid password", show: true)
                    return true
                }
            } else {
                hideButtons()
                return false
            }
        }
    }// return NO to not change text
    
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        let emailField = (self.emailTextField != nil) && textField == emailTextField
        let passwordField = (self.passwordTextField != nil) && textField == self.passwordTextField
        if emailField {
            showHideEmailMessage(message: "Invalid email", show: true)
            hideView(view: passwordView)
            hideButtons()
        } else if passwordField {
            showHidePasswordMessage(message: "Invalid password", show: true)
        }
        return true
    }// called when clear button pressed. return NO to ignore (no notifications)
    
    func lookup(email: String) {
        var operation = self.operation
        if operation.active {
            operation.cancelled = true
            self.operation = RVOperation(active: true, name: "\(Date().timeIntervalSince1970)")
            operation = self.operation
        } else {
            operation.active = true
        }
        self.loginRegisterState = nil
        let password =  "\(Date().timeIntervalSince1970)" // Plug with invalid password
        RVSwiftDDP.sharedInstance.loginWithPassword(email: email.lowercased(), password: password, completionHandler: { (result , error) in
            if let error = error {
                if !operation.cancelled && operation.identifier == self.operation.identifier {
                    print("IN \(self.classForCoder).lookup, with error")
                    if let original = error.sourceError as? DDPError{
                        if let reason = original.reason {
                            print("In \(self.classForCoder).lookup, reason is: \(reason)")
                            if reason == "User not found" {
                               // print("In \(self.classForCoder).lookup for email \(email), User Not Found")
                                self.showRegisterButton()
                                self.loginRegisterState = "Register"
                            } else if reason == "Incorrect password" {
                              //  print("In \(self.classForCoder).lookup for email \(email), Incorrect Password")
                                self.showLoginButton()
                                self.loginRegisterState = "Login"
                            } else {
                                print("In \(self.classForCoder).lookup for email \(email), got error with uncaptured reason \(reason)")
                            }
                        } else {
                            print("In \(self.classForCoder).lookup for email \(email), got DDP error but no reason")
                        }
                        
                    } else {
                        print("In \(self.classForCoder).lookup for email \(email), got error but not DDP Error \(error.output())")
                    }
                    self.operation = RVOperation(active: false, name: "\(Date().timeIntervalSince1970))")
                } else if operation.identifier == self.operation.identifier {
                    self.operation = RVOperation(active: false, name: "\(Date().timeIntervalSince1970))")
                } else {
                    // do nothing
                }
            } else {
                // will get this if already logged in (and regardless of what is sent as email and password)
                print("In \(self.classForCoder).lookup, did not get error, but supposed to get one. Email is: \(email) and password is: \(password)")
            }
        })
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let emailField = (self.emailTextField != nil) && textField == emailTextField
        let passwordField = (self.passwordTextField != nil) && textField == self.passwordTextField
        let text = (textField.text != nil) ? textField.text! : ""
        if emailField {
            if text.validEmail() {
                showHideEmailMessage(message: "", show: false)
                if let passwordField = self.passwordTextField {
                    passwordField.becomeFirstResponder()
                }
                
                return true
            } else {
                showHideEmailMessage(message: "Invalid email", show: true)
                hideView(view: passwordView)
                return false
            }
            
        } else if passwordField {
            if text.validPassword() {
                showHidePasswordMessage(message: "", show: false)
                return true
            } else {
                showHidePasswordMessage(message: "Invalid password", show: true)
                return false
            }
        } else {
            return false
        }
    }// called when 'return' key pressed. return NO to ignore.
}
