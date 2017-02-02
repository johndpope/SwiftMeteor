//
//  RVMessageAuthorViewController.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/30/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
import DropDown
import Google_Material_Design_Icons_Swift
import Font_Awesome_Swift
import SwiftSoup
import Toast_Swift

class RVMessageAuthorViewController: UIViewController {
    static let unwindFromMessageCreateSceneWithSegue = "unwindFromMessageCreateSceneWithSegue"
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var priorityButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addChangePhotoButton: UIButton!
    @IBOutlet weak var messageContentTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var sendButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var envelopingMessageView: UIView!
    var camera = RVCamera()
    var capturedImage: RVImage? = nil {
        didSet {
            if capturedImage != nil { showHideSendButton(hide: false)}
        }
    }
    var topOfStack: RVBaseModel? {get {return RVCoreInfo.sharedInstance.mainState.stack.last}}
    var userProfile: RVUserProfile? { get { return RVCoreInfo.sharedInstance.userProfile }}
    func setActiveButtonIfNotActive(_ button: UIButton? = nil, _ barButton: UIBarButtonItem? = nil) -> Bool {
        return RVCoreInfo.sharedInstance.setActiveButtonIfNotActive(button, barButton)
    }
    func clearActiveButton(_ button: UIButton? = nil, _ barButton: UIBarButtonItem? = nil) -> Bool {
        return RVCoreInfo.sharedInstance.clearActiveButton(button, barButton)
    }
    var sendButtonHeightConstant: CGFloat = 40.0
    let reportDropDown  = DropDown()
    let priorityDropDown = DropDown()
    let textField = UITextField()
    var seguePayload: [String: AnyObject]? = nil
    var messageDefaultImage: UIImage? { get { return UIImage(named: "JNW.png") } }
    lazy var dropDowns:[DropDown] = {
        return [self.reportDropDown, self.priorityDropDown]
    }()
    @IBAction func reportButtonTouched(_ sender: UIButton) {

        if let textView = self.messageContentTextView { if textView.isFirstResponder { textView.resignFirstResponder() }}
        reportDropDown.show()
    }
    
    @IBAction func priorityButtonTouched(_ sender: UIButton) {
        if let textView = self.messageContentTextView { if textView.isFirstResponder { textView.resignFirstResponder() }}
        priorityDropDown.show()
    }

    @IBAction func addChangePhotoButtonTouched(_ sender: UIButton) {
        if !setActiveButtonIfNotActive(sender) { return }
        showCameraMenu()
    }
    func getButtonText(button: UIButton?) -> String? {
        if let button = button {
            if let label = button.titleLabel {
                return label.text
            }
        }
        return nil
    }
    @IBAction func sendButtonTouched(_ sender: UIButton) {
        if !setActiveButtonIfNotActive(sender) { return }
        if let textView = messageContentTextView {
            if let text = textView.text {
                let message = RVMessage()
                if let priority = RVMessage.Priority.urgent.reverse(rawValue: getButtonText(button: self.priorityButton)) {
                    message.priority = priority
                }
                if let rawValue = getButtonText(button: self.reportButton) {
                    if let report = RVMessage.MessageReport(rawValue: rawValue) {
                        message.messageReport = report
                    }
                }
                message.text = text
                if let top = topOfStack {
                    message.setParent(parent: top)
                }
                if let userProfile = self.userProfile {
                    message.setOwner(owner: userProfile)
                    message.fullName = userProfile.fullName
                }
                if let rvImage = self.capturedImage {
                    rvImage.setParent(parent: message)
                    if let userProfile = self.userProfile {
                        rvImage.setOwner(owner: userProfile)
                        rvImage.fullName = userProfile.fullName
                    }
                    print("In \(self.classForCoder).sendBUttonTouched, About to do updateById")
                    rvImage.updateById(callback: { (updatedRVImage, error) in
                        if let error = error {
                            let _ = self.clearActiveButton(sender)
                            error.append(message: "In \(self.classForCoder).sendButtonTouched error updating image")
                            error.printError()
                        } else if let updatedRVImage = updatedRVImage as? RVImage {
                            print("\n-------------\nIn \(self.classForCoder).sendButton... \n\(updatedRVImage.toString())\n----------")
                            message.image = updatedRVImage
                            self.createMessage(message: message)
                        } else {
                            let _ = self.clearActiveButton(sender)
                            print("In\(self.classForCoder).sendBUttonTouched, no error but no updated RVImage")
                        }
                    })
                } else {
                    createMessage(message: message)
                }
            }
        }
    }
    func createMessage(message: RVMessage) {
        message.create(callback: { (result, error) in
            let _ = self.clearActiveButton(self.sendButton)
            if let error = error {
                if let view = self.envelopingMessageView {
                    view.makeToast("Error sending message :-(", duration: 2.0, position: .center)
                }
                error.printError()
            } else if let sentMessage = result as? RVMessage {
                if let view = self.envelopingMessageView {
                    view.makeToast(" Successfully sent message ;-)", duration: 2.0, position: .center)
                }
                print("In \(self.classForCoder).sendButtonTouched, successfully sent message \n\(sentMessage.toString())")
            } else {
                print("In \(self.classForCoder).sendButton, no error but no response")
                if let view = self.envelopingMessageView {
                    view.makeToast("In sending message, no error but no result :-(", duration: 2.0, position: .center)
                }
            }
        })
    }
    func showCameraMenu() {
        
        let alertVC = UIAlertController(title: title, message: "Get Picture from...", preferredStyle: .alert)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action: UIAlertAction) in
            self.camera.delegate = self
            self.camera.shootPhoto()
        }
        let albumAction = UIAlertAction(title: "Album", style: .default) { (action) in
            self.camera.delegate = self
            self.camera.showPhotoLibrary()
        }
        alertVC.addAction(cameraAction)
        alertVC.addAction(albumAction)
        self.present(alertVC, animated: true) { }
    }
    func showHideSendButton(hide: Bool) {
        if let button = sendButton { button.isHidden = hide}
        if let constraint = sendButtonHeightConstraint { constraint.constant = hide ? 0 : sendButtonHeightConstant }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        camera.anchorBarButtonItem = doneButton
        view.addSubview(textField)
        dressupTextView()
        if let constraint = sendButtonHeightConstraint { sendButtonHeightConstant = constraint.constant }
        if let button = addChangePhotoButton {
        //    button.setGMDIcon(icon: GMDType.GMDPhotoCamera, forState: .normal)
            button.setFAIcon(icon: .FACamera, iconSize: 35, forState: .normal)
        //    button.setFAText(prefixText: "P", icon: .FACamera, postfixText: "S", size: 25, forState: .normal, iconSize: 35)
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let payload = sender as? [String: AnyObject] {
            self.seguePayload = payload
        } else {
            self.seguePayload = nil
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        if let textView = self.messageContentTextView { textView.text = "" }
        showHideSendButton(hide: true)
        setupDropDowns()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let textView = messageContentTextView {
            textView.resignFirstResponder()
        }
        super.touchesBegan(touches, with: event)
    }
    func dressupTextView() {
        if let view = messageContentTextView {
            view.layer.borderColor = UIColor.green.cgColor
            view.layer.borderWidth = 2.0
            view.layer.cornerRadius = 10.0
        }
    }
}
extension RVMessageAuthorViewController: UITextViewDelegate {
//    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {return true}
//    func textViewShouldEndEditing(_ textView: UITextView) -> Bool { return true }
    func textViewDidBeginEditing(_ textView: UITextView) {}
    func textViewDidEndEditing(_ textView: UITextView) {
        if let text = textView.text {
            if text.characters.count == 0 {
                showHideSendButton(hide: true)
                return
            }
        }
        showHideSendButton(hide: false)
        
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.characters.contains("\r") || text.characters.contains("\n") || text.characters.contains("\t") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    func textViewDidChange(_ textView: UITextView) {}
    func textViewDidChangeSelection(_ textView: UITextView) {}
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {return true}
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {return true}
}
extension RVMessageAuthorViewController: UITextFieldDelegate {
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {return true}// return NO to disallow editing.
    func textFieldDidBeginEditing(_ textField: UITextField) {} // became first responder
//    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool { return true}// return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
    // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
//    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {}// if implemented, called in place of textFieldDidEndEditing:
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool  {return true}// return NO to not change text
//    func textFieldShouldClear(_ textField: UITextField) -> Bool {return true}// called when clear button pressed. return NO to ignore (no notifications)
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool { return true }// called when 'return' key pressed. return NO to ignore.
}

extension RVMessageAuthorViewController: RVCameraDelegate {
    @objc func finishedWritingToAlbum(image: UIImage, error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let rvError = RVError(message: "In \(self.classForCoder).finishedWriting got erro", sourceError: error , lineNumber: #line, fileName: "")
            rvError.printError()
        } else {
            dismiss(animated: true, completion: { })
        }
    }
    func didFinishPicking(picker: UIImagePickerController, info: [String: Any]) -> Void {
        if let uiImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imageView.image = uiImage
            RVImage.saveImage(image: uiImage, path: "Message", filename: "message", filetype: .jpeg, parent: nil, params: [RVKeys: AnyObject](), callback: { (rvImage, error) in
                let _ = self.clearActiveButton(self.addChangePhotoButton)
                self.capturedImage = nil
                if let error = error {
                    error.append(message: "In \(self.classForCoder).didFinishPicking, got error")
                    error.printError()
                } else if let rvImage = rvImage {
                    print("In \(self.classForCoder).didFinishPicking, successfully saved image \n\(rvImage.toString())")
                    self.capturedImage = rvImage

                } else {
                    print("In \(self.classForCoder).didFinishPicking no error but no rvImage")
                }
                picker.dismiss(animated: true, completion: {
                    
                })
            })
        } else {
            let _ = self.clearActiveButton(self.addChangePhotoButton)
            picker.dismiss(animated: true, completion: { })
        }
        
        
    }
    func pickerCancelled(picker: UIImagePickerController) -> Void {
        print("In \(self.classForCoder).pickerCancelled")
        let _ = self.clearActiveButton(self.addChangePhotoButton)
        picker.dismiss(animated: true) {}
    }
}
extension RVMessageAuthorViewController {
    func customizeDropDown(_ sender: AnyObject) {
        let appearance = DropDown.appearance()
        appearance.cellHeight = 60
        appearance.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        appearance.selectionBackgroundColor = UIColor(colorLiteralRed: 0.6494, green: 0.8155, blue: 1.0, alpha: 0.2)
        appearance.cornerRadius = 10.0
        appearance.shadowColor = UIColor(white: 0.6, alpha: 1.0)
        appearance.shadowOpacity = 0.9
        appearance.shadowRadius = 25.0
        appearance.animationduration = 0.25
        appearance.textColor = .darkGray
        //appearance.separatorColor = UIColor(white: 0.7, alpha: 0.8)
        //appearance.textFont = UIFont(name: "Georgia", size: 14)
        dropDowns.forEach {
            /*** FOR CUSTOM CELLS **/
            $0.cellNib = UINib(nibName: "MyCell", bundle: nil)
            $0.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
                guard let cell = cell as? MyCell else {return }
                // Setup your custom UI components
                cell.suffixLabel.text = "Suffix \(index)"
            }
            
        }
    }
    func setupPriorityDropDown() {
        let dropDown = priorityDropDown
        dropDown.anchorView = priorityButton
        dropDown.bottomOffset = CGPoint(x: 0, y: reportButton.bounds.height)
        dropDown.dataSource = [
            "General Info",
            "Medium",
            "Urgent"
        ]
        if let button = self.priorityButton {
            let index = 0
            dropDown.selectRow(at: index)
            if index < reportDropDown.dataSource.count { button.setTitle(dropDown.dataSource[index], for: .normal) }
            dropDown.selectionAction = {(index, item) in
        //    dropDown.selectionAction = { [unowned self] (index, item) in
                button.setTitle(item, for: .normal)
            }
        }
        dropDown.cancelAction = { [unowned self] in
            self.priorityDropDown.deselectRow(at: self.priorityDropDown.indexForSelectedRow)
            //self.priorityButton.setTitle("Cancelled", for: .normal)
        }
        
    }
    func setupDefaultDropDown() {
        DropDown.setupDefaultAppearance()
        dropDowns.forEach {
            $0.cellNib = UINib(nibName: "DropDownCell", bundle: Bundle(for: DropDownCell.self))
            $0.customCellConfiguration = nil
        }
    }
    @IBAction func changeDismissalMode(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: dropDowns.forEach { $0.dismissMode = .automatic}
        case 1: dropDowns.forEach { $0.dismissMode = .onTap }
        default:
            break
        }
    }
    @IBAction func changeUI(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: setupDefaultDropDown()
        case 1: customizeDropDown(self)
        default: break;
        }
    }
    
    @IBAction func dropDownSegmentedControl(_ sender: UISegmentedControl) {
        changeUI(sender)
    }
    func setupDropDowns() {
        DropDown.startListeningToKeyboard()
        setupReportDropDown()
        setupPriorityDropDown()
        // dropDowns.forEach { $0.dismissMode = .automatic}
        dropDowns.forEach { $0.dismissMode = .onTap }
        dropDowns.forEach { $0.direction = .any}
    }
    func setupReportDropDown() {
        reportDropDown.anchorView = reportButton
        reportDropDown.bottomOffset = CGPoint(x: 0, y: reportButton.bounds.height)
        reportDropDown.dataSource = [
            "Other",
            "Regular",
            "Suspicious Person",
            "Suspicious Vehicle"
        ]

        if let button = self.reportButton {
            let index = 1
            reportDropDown.selectRow(at: index)
            if index < reportDropDown.dataSource.count { button.setTitle(reportDropDown.dataSource[index], for: .normal) }
            //reportDropDown.selectionAction = { [unowned self] (index, item) in
            reportDropDown.selectionAction = {(index, item) in
                button.setTitle(item, for: .normal)
            }
        }

        reportDropDown.cancelAction = { [unowned self] in
            self.reportDropDown.deselectRow(at: self.reportDropDown.indexForSelectedRow)
            //self.reportButton.setTitle("Cancelled", for: .normal)
        }
    }
}
