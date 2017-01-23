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
        updateProfile {
            self.setProfileInfo()
        }
    }
    func updateProfile(callback: @escaping() -> Void) {
        /*
        let user = RVUserProfile()
        user.title = "Elmo was here"
        user.text = "SOme more text 6677777"
        user.create { (error) in
            if let error = error {
                error.printError()
            }
        }
        return
        */
        if let profile = RVCoreInfo.sharedInstance.userProfile {
            if let text = firstNameTextField.text {profile.firstName = text }
            if let text = middleNameTextField.text {profile.middleName = text }
            if let text = lastNameTextField.text { profile.lastName = text }
            let image = RVImage()
            image.urlString = "NEW URL STRING *************** "
            image.title = "DIrrent TItle"
            image.urlString = "URL STRINGGGG 88&&&&&&&&&&&&&&&&&&&&&&&&"
            image.regularDescription = "An Image Description"
       //     image.updatedAt = Date()
            profile.image = image
      //      profile.location = RVLocation(fields: [String: AnyObject]())
      //     profile.image = nil
            profile.ownerId = "Elmer"
            profile.ownerModelType = .household
            profile.parentId = "parentIDGoesHerrrrrrrrrre"
            profile.parentModelType = .domain
            profile.handle = "A new handle"
            profile.comment = "New comment"
     //       profile.regularDescription = "A regular description"
     //       profile.yob = 1958
     //       profile.clientRole = .admin
     //       profile.gender = .male
    //        profile.validRecord = true
           // profile.domainId = "DomainID"
    //        profile.email = "f@f.com"
     //       profile.cellPhone = nil
            profile.homePhone = nil
     //       profile.watchGroupIds = ["ID1", "ID2", "SOMETHING"]
            profile.watchGroupIds = ["ABCD", "1234"]
            profile.schemaVersion = 15.0
         //   profile.title = "New title"
            profile.text = "Alexandar"
            if let domain = RVCoreInfo.sharedInstance.domain {
                profile.domainId = domain.localId
            }
            profile.updateById(callback: { (updatedModel, error) in
                if let error = error {
                    error.printError()
                    callback()
                } else if let newProfile = updatedModel as? RVUserProfile {
                    print("In \(self.classForCoder).updateProfile successful saved\n\(newProfile.toString())")
                    RVCoreInfo.sharedInstance.userProfile = newProfile
                    callback()
                } else {
                    print("In \(self.classForCoder).updateProfile no error but no newModel")
                    callback()
                }
            })
        }
    }
    func setProfileInfo() {
        if let profile = RVCoreInfo.sharedInstance.userProfile {
           // print("------------------\nIn \(self.classForCoder).setProfileInfo, have profile \(profile.toString())")
            setTextFieldText(text: profile.firstName, textField: firstNameTextField)
            setTextFieldText(text: profile.middleName, textField: middleNameTextField)
            setTextFieldText(text: profile.lastName, textField: lastNameTextField)
        } else {
            print("In \(self.classForCoder).setProfileInfo, do NOT have profile")
        }
    }
    
    @IBAction func doneButtonTouched(_ sender: UIBarButtonItem) {
        updateProfile{
            print("In \(self.classForCoder).doneButtonTouched callback")
            RVAppState.shared.state = .Regular
            self.dismiss(animated: true) {
            }
        }
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
        setProfileInfo()
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
      //  print("\(string)")
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
