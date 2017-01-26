//
//  RVProfileViewController.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/21/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
import TPKeyboardAvoiding
extension RVProfileViewController: RVCameraDelegate {
    func didFinishPicking(picker: UIImagePickerController, info: [String: Any]) -> Void {
        if let profileImageView = self.profileImageView {
            if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                profileImageView.image = chosenImage
                if let profile = RVCoreInfo.sharedInstance.userProfile {
                    self.tableView.lock()
                    RVImage.saveImage(image: chosenImage, path: nil, filename: "arbitraryname", filetype: .jpeg, parent: profile, params: [String: AnyObject](), callback: { (image, error) in
                        print("RVProfileViewController.didFinish. About to unlock")
                        self.tableView.unlock()
                        if let error = error {
                            error.append(message: "In \(self.classForCoder).didFinish, got error ")
                            error.printError()
                        } else if let rvImage = image {
                            print("In \(self.classForCoder).didFinsh got rvImage\n\(rvImage)")
                            profile.image = rvImage
                            profile.updateById(callback: { (profile, error) in
                                if let error = error {
                                    error.printError()
                                } else if let profile = profile as? RVUserProfile {
                                    RVCoreInfo.sharedInstance.userProfile = profile
                                    print("In \(self.classForCoder).didFinish, successfully updated profile")
                                } else {
                                    print("In \(self.classForCoder).didFinishPicking, on updating Profile, nothing returned")
                                }
                            })
                        } else {
                            print("In \(self.classForCoder).didFinish, no error but no image")
                        }
                    })
                }

            }
        }
        dismiss(animated: true) { }
    }
    func pickerCancelled(picker: UIImagePickerController) -> Void {
               dismiss(animated: true) {  }
    }
}

class RVProfileViewController: UITableViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var middleNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    let trimCharacters: CharacterSet  = [" ", "\n", "\r", "\t"]

    var camera = RVCamera()
    
    
    @IBAction func saveButtonTouched(_ sender: UIBarButtonItem) {
        updateProfile {
            self.setProfileInfo()
        }
    }
    @IBAction func imageButtonTouched(_ sender: UIButton) {
        camera.showPhotoLibrary()

    }
    @IBAction func shootPhoto(_ sender: UIButton) {
        camera.shootPhoto()

    }
    

    func updateProfile(callback: @escaping() -> Void) {
        if let profile = RVCoreInfo.sharedInstance.userProfile {
            if let text = firstNameTextField.text {profile.firstName = text.trimmingCharacters(in: trimCharacters) }
            if let text = middleNameTextField.text {profile.middleName = text.trimmingCharacters(in: trimCharacters) }
            if let text = lastNameTextField.text { profile.lastName = text.trimmingCharacters(in: trimCharacters) }
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
          // print("------------------\nIn \(self.classForCoder).setProfileInfo, have profile \(profile.toString())\n%\n%\n%")
            setTextFieldText(text: profile.firstName, textField: firstNameTextField)
            setTextFieldText(text: profile.middleName, textField: middleNameTextField)
            setTextFieldText(text: profile.lastName, textField: lastNameTextField)
            if let rvImage = profile.image {
                rvImage.download(callback: { (image, error) in
                    if let error = error {
                        error.printError()
                    } else if let uiImage = image {
                        print("In \(self.classForCoder).setProfileInfo, have image \(uiImage.size.height)")
                        self.showImage(imageView: self.profileImageView, uiImage: uiImage)
                    }
                })
            }
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
      //  self.picker.delegate = self
        setProfileInfo()
        camera.delegate = self
        camera.anchorBarButtonItem = doneButton
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
        /*
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
*/
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
    func showImage(imageView: UIImageView?, uiImage: UIImage?) {
        if let imageView = imageView {
            if let uiImage = uiImage {
                imageView.image = uiImage
            }
        }
    }
}
