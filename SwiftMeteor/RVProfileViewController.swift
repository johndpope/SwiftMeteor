//
//  RVProfileViewController.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/21/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
// import GoogleMaps
import GooglePlaces
import TPKeyboardAvoiding
// https://developers.google.com/places/ios-api/autocomplete#add_an_autocomplete_ui_control
extension RVProfileViewController: GMSAutocompleteViewControllerDelegate {
    // Handle the user's selection
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name), address: \(place.formattedAddress), attributions: \(place.attributions)")
        let location = RVLocation(googlePlace: place)
        print(location.toString())
        if let profile = RVCoreInfo.sharedInstance.userProfile {
            profile.location = location
            profile.updateById(callback: { (updatedProfile, error ) in
                if let error = error {
                    error.append(message: "In \(self.classForCoder).didAutocomplete, got error saving profile for location: \(location.toString())")
                    error.printError()
                } else if let updatedProfile = updatedProfile as? RVUserProfile {
                    print("In \(self.classForCoder).didAutocomplete, got updatedProfile \(updatedProfile.toString())")
                    RVCoreInfo.sharedInstance.userProfile = updatedProfile
                    self.showProfileInfo()
                } else {
                    print("In \(self.classForCoder).didAutocomplete, no error but no updateProfile")
                }
            })
        }
        dismiss(animated: true) { }
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("In \(self.classForCoder).didFailAutocompleteWithError: \(error.localizedDescription)")
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didSelect prediction: GMSAutocompletePrediction) -> Bool {
        return true
    }
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        showProfileInfo()
        dismiss(animated: true) {}
    }
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
extension RVProfileViewController: RVCameraDelegate {
    func didFinishPicking(picker: UIImagePickerController, info: [String: Any]) -> Void {
        if let profileImageView = self.profileImageView {
            if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                profileImageView.image = chosenImage
                if let profile = RVCoreInfo.sharedInstance.userProfile {
                    self.tableView.lock()
                    RVImage.saveImage(image: chosenImage, path: nil, filename: "arbitraryname", filetype: .jpeg, parent: profile, params: [String: AnyObject](), callback: { (image, error) in
                        if let error = error {
                            self.tableView.unlock()
                            error.append(message: "In \(self.classForCoder).didFinish, got error ")
                            error.printError()
                        } else if let rvImage = image {
                          //  print("In \(self.classForCoder).didFinsh got rvImage\n\(rvImage) with id \(rvImage.localId) \(rvImage.shadowId)")
                            profile.image = rvImage
                            profile.updateById(callback: { (updatedProfile, error) in
                                if let error = error {
                                    error.printError()
                                } else if let updatedProfile = updatedProfile as? RVUserProfile {
                                    RVCoreInfo.sharedInstance.userProfile = updatedProfile
                                    print("In \(self.classForCoder).didFinish, successfully updated profile")
                                    if let image = updatedProfile.image {
                                        print("Profile iamge ids: localId = \(image.localId), \(image.shadowId)")
                                    }
                                } else {
                                    print("In \(self.classForCoder).didFinishPicking, on updating Profile, nothing returned")
                                }
                                self.tableView.unlock()
                            })
                        } else {
                            self.tableView.unlock()
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
extension RVProfileViewController: UIPickerViewDataSource {
    // returns the number of 'columns' to display.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {return 1}
    
    
    // returns the # of rows in each component..
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }
}
extension RVProfileViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        self.view.endEditing(true)
        if row < genders.count {
            if let font = UIFont(name: "Georgia", size: 14.0) {
                return NSAttributedString(string: genders[row].rawValue, attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.white])
            }
        }
        return nil
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row < genders.count { if let textField = self.genderTextField { textField.text = genders[row].rawValue } }
    }
}
class RVProfileViewController: UITableViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var middleNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBOutlet weak var genderPickerView: UIPickerView!
    @IBOutlet weak var cellPhoneTextField: UITextField!
    @IBOutlet weak var homePhoneTextField: UITextField!
    @IBOutlet weak var yobLabel: UILabel!
    @IBOutlet weak var addressTextField: UITextField!
    
    @IBOutlet weak var earliestYOBLabel: UILabel!
    @IBOutlet weak var latestYOBLabel: UILabel!
    var yobSliderValueValid: Bool = false
    
    var tapGestureRecognizer: UITapGestureRecognizer? = nil
    var lastTextField: UITextField? = nil
    
    let activity = UIActivityIndicatorView(activityIndicatorStyle: .white)
    let activityView = UIView()
    let genders = [RVGender.female, RVGender.itsComplicated, RVGender.male, RVGender.transgender, RVGender.unknown]
    @IBOutlet weak var genderTextField: UITextField!
    
    @IBOutlet weak var yobSlider: UISlider!
    @IBAction func yobSliderValueChanged(_ sender: UISlider) {
     //   print("yobSliderValueChanged \(sender.value)")
        view.endEditing(true)
        setLabelText(text: "\(Int(sender.value))", label: yobLabel)
    }
    
    var latestYOB: Int = {
        return Calendar.autoupdatingCurrent.component(.year, from: Date())
    }()
    var earliestYOB: Int {
        get {
           return latestYOB - 90
        }
    }
    let trimCharacters: CharacterSet  = [" ", "\n", "\r", "\t"]

    var camera = RVCamera()
    
    
    @IBAction func saveButtonTouched(_ sender: UIBarButtonItem) {
        updateProfile {
            self.showProfileInfo()
        }
    }
    @IBAction func imageButtonTouched(_ sender: UIButton) {
        view.endEditing(true)
        removeGenderPicker()
        camera.showPhotoLibrary()

    }
    @IBAction func shootPhoto(_ sender: UIButton) {
        view.endEditing(true)
        removeGenderPicker()
        camera.shootPhoto()

    }
    
    @IBAction func cancelButtonTouched(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        removeGenderPicker()
        dismiss(animated: true) { 
            
        }
    }

    func updateProfile(callback: @escaping() -> Void) {
        removeGenderPicker()
        if let profile = RVCoreInfo.sharedInstance.userProfile {
            if let text = firstNameTextField.text {profile.firstName = text.trimmingCharacters(in: trimCharacters) }
            if let text = middleNameTextField.text {profile.middleName = text.trimmingCharacters(in: trimCharacters) }
            if let text = lastNameTextField.text { profile.lastName = text.trimmingCharacters(in: trimCharacters) }
            if let rawValue = genderTextField.text {
                if let gender = RVGender(rawValue: rawValue) {
                    profile.gender = gender
                } else {
                    print("In \(self.classForCoder).updateProfile, gendertext nonexistent")
                }
            }
            if yobSliderValueValid { if let slider = yobSlider { profile.yob = NSNumber(value: slider.value).intValue } }
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

    func showProfileInfo() {
        removeGenderPicker()
        setupYOBSlider()
        if let profile = RVCoreInfo.sharedInstance.userProfile {
          // print("------------------\nIn \(self.classForCoder).showProfileInfo, have profile \(profile.toString())\n%\n%\n%")
            setTextFieldText(text: profile.firstName, textField: firstNameTextField)
            setTextFieldText(text: profile.middleName, textField: middleNameTextField)
            setTextFieldText(text: profile.lastName, textField: lastNameTextField)
            setTextFieldText(text: profile.gender.rawValue, textField: genderTextField)
            if let rvImage = profile.image {
                rvImage.download(callback: { (image, error) in
                    if let error = error {
                        error.printError()
                    } else if let uiImage = image {
                      //  print("In \(self.classForCoder).setProfileInfo, have image \(uiImage.size.height)")
                        self.showImage(imageView: self.profileImageView, uiImage: uiImage)
                    }
                })
            }
            if let location = profile.location {
                if let address = location.fullAddress {
                    setTextFieldText(text: address, textField: addressTextField)
                }
            }
        } else {
            print("In \(self.classForCoder).showProfileInfo, do NOT have profile")
        }
    }
    func setupYOBSlider() {
        yobSliderValueValid = false
        setLabelText(text: "\(earliestYOB)", label: earliestYOBLabel)
        setLabelText(text: "\(latestYOB)", label:latestYOBLabel)
        if let slider = yobSlider {
            slider.maximumValue = Float(latestYOB)
            slider.minimumValue = Float(earliestYOB)
            if let profile = RVCoreInfo.sharedInstance.userProfile {
                if let yob = profile.yob {
                    if (yob >= earliestYOB) && (yob <= latestYOB) {
                        slider.setValue(Float(yob), animated: true)
                        setLabelText(text: yob.description, label: yobLabel)
                        yobSliderValueValid = true
                        return
                    }
                    setLabelText(text: yob.description, label: yobLabel)
                    slider.setValue(Float(latestYOB - earliestYOB), animated: true)
                    return
                }
            }
            slider.setValue(Float(latestYOB - earliestYOB), animated: true)
        }
        setLabelText(text: "", label: yobLabel)
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
        showProfileInfo()
        camera.delegate = self
        camera.anchorBarButtonItem = doneButton
        if let picker = self.genderPickerView {picker.isHidden = true }

        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("In \(self.classForCoder).didSelectRow \(indexPath.row)")
    }
    func plugWatchGroup() {
        let group = RVWatchGroup()
        group.title = "Elmo"
        let image = RVImage()
        image.title = "First Title"
        group.image = image
        group.create { (newGroup, error) in
            if let error = error {
                error.printError()
            } else if let newGroup = newGroup as? RVWatchGroup {
                print(newGroup.toString())
                let image = RVImage()
                image.title = "Image Title"
                group.image = image
                group.updateById(callback: { (updatedModel, error) in
                    if let error = error {
                        error.printError()
                    } else if let updatedGroup = updatedModel as? RVWatchGroup {
                        print(updatedGroup.toString())
                    } else {
                        print("In \(self.classForCoder).viewDidLoad  no error but no model")
                    }
                })
            } else {
                print("In \(self.classForCoder).viewDidLoad WatchGroup no error but no result")
            }
        }
    }
}
extension RVProfileViewController: UIGestureRecognizerDelegate {
    
}
extension RVProfileViewController: UITextFieldDelegate {
    func showGenderPicker() {
        view.endEditing(true)
        if let picker = self.genderPickerView {
            picker.backgroundColor = UIColor.blue
            picker.alpha = 1.0
            picker.isHidden = false
            if let profile = RVCoreInfo.sharedInstance.userProfile {
                let gender = profile.gender
                var row = 0
                for index in (0..<genders.count) {
                    if genders[index] == gender {
                        row = index
                        break
                    }
                }
                picker.selectRow(row, inComponent: 0, animated: true)
            }
        }
    }
    func removeGenderPicker() {
        if let picker = genderPickerView { picker.isHidden = true }
        removeTapGestureRecognizer()
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == firstNameTextField { print("FIrst name TextField") }
        if textField == lastNameTextField { print("Last name textfield")}
        if textField == middleNameTextField { print("Middle name textField") }
        if textField == cellPhoneTextField { print("Cellphone textField") }
        if textField == homePhoneTextField   { print("HomePhone textField") }
        if textField == genderTextField { print("Gender textField") }
        if textField == addressTextField { print("Address textField") }
        if textField == addressTextField {
            let filter = RVGMaps.sharedInstance.usaFilter
            let autocompleteController = GMSAutocompleteViewController()

            autocompleteController.autocompleteFilter = filter
            autocompleteController.delegate = self
            present(autocompleteController, animated: true) {
                
            }
            return false
        } else if textField == genderTextField {
            if let picker = self.genderPickerView {
                if picker.isHidden {
                    showGenderPicker()
                    setupGestureRecognizer()
                } else {
                    removeGenderPicker()
                }
            }
            return false
        } else {
            if let picker = self.genderPickerView {
                if !picker.isHidden {
                    return true
                }
            }
        }
        return true
    }// return NO to disallow editing.
    func setupGestureRecognizer() {
        if let tap = self.tapGestureRecognizer {
            if let recognizers = self.tableView.gestureRecognizers {
                for recognizer in recognizers {
                    if let recognizer = recognizer as? UITapGestureRecognizer {
                        if recognizer == tap {
                            self.tableView.removeGestureRecognizer(recognizer)
                        }
                    }
                }
            }
            self.tapGestureRecognizer = nil
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(RVProfileViewController.outside))
        tap.numberOfTapsRequired = 1
        tap.cancelsTouchesInView = true
        self.tableView.addGestureRecognizer(tap)
        tap.delegate = self
        self.tapGestureRecognizer = tap
    }
    func removeTapGestureRecognizer() {
        if let tap = self.tapGestureRecognizer {
            if let tableView = self.tableView { tableView.removeGestureRecognizer(tap) }
            tap.delegate = nil
            self.tapGestureRecognizer = nil
        }
    }
    @objc func outside(recognizer: UITapGestureRecognizer) {
        if let picker = self.genderPickerView { picker.isHidden = true }
        removeTapGestureRecognizer()
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }// became first responder
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {return true }// return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        print("In didEnd")
        if textField == firstNameTextField {
            if let middle = middleNameTextField {
                print("Making middle")
                middle.becomeFirstResponder()
            }
        } else if textField == middleNameTextField {
            if let last = lastNameTextField { last.becomeFirstResponder() }
        }
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
        if (firstNameTextField != nil) && (firstNameTextField == textField ){
            
        } else if (middleNameTextField != nil) && (middleNameTextField == textField) {
            
        } else if (lastNameTextField != nil) && (lastNameTextField == textField) {
            
        } else if textField == cellPhoneTextField || textField == homePhoneTextField {
            if string.characters.count == 1 {
                if string.contains("#") || string.contains("*") || string.contains("+") || string.contains(";") || string.contains(","){ return false }
                else {return true}
            }
        }
        return true
    }// return NO to not change text
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {return true }// called when clear button pressed. return NO to ignore (no notifications)
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("In \(self.classForCoder).textFieldShouldReturn")
        if textField == firstNameTextField { middleNameTextField.becomeFirstResponder()  }
        if textField == middleNameTextField { lastNameTextField.becomeFirstResponder() }
        if textField == lastNameTextField { cellPhoneTextField.becomeFirstResponder() }
        if textField == cellPhoneTextField { homePhoneTextField.becomeFirstResponder() }
        if textField == homePhoneTextField { genderTextField.becomeFirstResponder() }
        if textField == genderTextField { addressTextField.becomeFirstResponder() }
        if textField == addressTextField { textField.resignFirstResponder() }
        return true}// called when 'return' key pressed. return NO to ignore
}
extension RVProfileViewController {
    func setLabelText(text: String?, label: UILabel?) {
        if let label = label {
            if let text = text {
                label.text = text
            } else {
                label.text = ""
            }
        }
    }
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
