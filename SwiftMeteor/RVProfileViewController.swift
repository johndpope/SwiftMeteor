//
//  RVProfileViewController.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/21/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
import TPKeyboardAvoiding

class RVProfileViewController: UITableViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var middleNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    
    @IBAction func saveButtonTouched(_ sender: UIBarButtonItem) {
        if let profile = RVCoreInfo.sharedInstance.userProfile {
            print(profile.toString())
            if let text = firstNameTextField.text {profile.firstName = text }
            if let text = middleNameTextField.text {profile.middleName = text }
            if let text = lastNameTextField.text { profile.lastName = text }
            profile.update(callback: { (error) in
                if let error = error {
                    error.printError()
                } else {
                    print("In \(self.classForCoder).saveButtonTouched successful saved")
                }
            })
        }
    }
    
    @IBAction func doneButtonTouched(_ sender: UIBarButtonItem) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let nav = self.navigationController {
            //let gray = UIColor(colorLiteralRed: 128/255, green: 128/255, blue: 128/255, alpha: 1.0).cgColor
            let silver = UIColor(colorLiteralRed: 192/255, green: 200/255, blue: 210/255, alpha: 1.0).cgColor
            let nearWhite = UIColor(colorLiteralRed: 230/255, green: 240/255, blue: 255/255, alpha: 1.0).cgColor
            let _ = nav.navigationBar.layerGradient(colors: [nearWhite, silver])
        }
        if let image = UIImage(named: "Placeholder") {
            profileImageView.image = image
        }
        if let profile = RVCoreInfo.sharedInstance.userProfile {
            print("In \(self.classForCoder).viewDidLoad, have profile \(profile.toString())")
            setTextFieldText(text: profile.firstName, textField: firstNameTextField)
            setTextFieldText(text: profile.middleName, textField: middleNameTextField)
            setTextFieldText(text: profile.lastName, textField: lastNameTextField)
        } else {
             print("In \(self.classForCoder).viewDidLoad, do NOT have profile")
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("In \(self.classForCoder).didSelectRow \(indexPath.row)")
    }
    
}
extension RVProfileViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {return true}// return NO to disallow editing.
    
    func textFieldDidBeginEditing(_ textField: UITextField) {}// became first responder
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {return true }// return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        let text = textField.text == nil ? textField.text! : ""
        if let profile = RVCoreInfo.sharedInstance.userProfile {
            if (firstNameTextField != nil) && (firstNameTextField == textField ){
                profile.firstName = text
            } else if (middleNameTextField != nil) && (middleNameTextField == textField) {
                profile.middleName = text
            } else if (lastNameTextField != nil) && (lastNameTextField == textField) {
                profile.lastName = text
            }
        }

    }// if implemented, called in place of textFieldDidEndEditing:
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("\(string)")
        if (firstNameTextField != nil) && (firstNameTextField == textField ){
            
        } else if (middleNameTextField != nil) && (middleNameTextField == textField) {
            
        } else if (lastNameTextField != nil) && (lastNameTextField == textField) {
            
        }
        return true
    }// return NO to not change text
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {return true }// called when clear button pressed. return NO to ignore (no notifications)
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {return true}// called when 'return' key pressed. return NO to ignore
}
extension RVProfileViewController {
    func setTextFieldText(text: String?, textField: UITextField? ) {
        if let textField = textField {
            if let text = text {
                textField.text = text
            }
        }
    }
}
