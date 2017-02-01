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

class RVMessageAuthorViewController: UIViewController {
    static let unwindFromMessageCreateSceneWithSegue = "unwindFromMessageCreateSceneWithSegue"
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var priorityButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addChangePhotoButton: UIButton!
    @IBOutlet weak var messageContentTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var sendButtonHeightConstraint: NSLayoutConstraint!
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
    }

    @IBAction func sendButtonTouched(_ sender: UIButton) {
 
    }
    func showHideSendButton(hide: Bool) {
        if let button = sendButton { button.isHidden = hide}
        if let constraint = sendButtonHeightConstraint { constraint.constant = hide ? 0 : sendButtonHeightConstant }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
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
        do{
            let doc: Document = try SwiftSoup.parse("<div>One</div><span>One</span>")
            let div: Element = try doc.select("div").first()! // <div></div>
            try div.html("<p>lorem ipsum</p>") // <div><p>lorem ipsum</p></div>
            try div.prepend("<p>First</p>")
            try div.append("<p>Last</p>")
            print(div)
            // now div is: <div><p>First</p><p>lorem ipsum</p><p>Last</p></div>
            
            let span: Element = try doc.select("span").first()! // <span>One</span>
            try span.wrap("<li><a href='http://example.com/'></a></li>")
            print(doc)
                    messageContentTextView.text = try doc.text()
            // now: <li><a href="http://example.com/"><span>One</span></a></li>
        }catch Exception.Error(let type, let message)
        {
            print("\(type) \(message)")
        } catch let error {
            print("\(error)")
        }

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
