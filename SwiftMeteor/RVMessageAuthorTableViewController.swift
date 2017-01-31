//
//  RVMessageAuthorTableViewController.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/30/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit


class RVMessageAuthorTableViewController: UITableViewController {
    
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var reportTypePicker: UIPickerView!
    @IBOutlet weak var priorityStepper: UIStepper!
}
extension RVMessageAuthorTableViewController: UIPickerViewDelegate {
    // returns width of column and height of row for each component.
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat { return 80}
    
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat { return 24 }
    
    
    // these methods return either a plain NSString, a NSAttributedString, or a view (e.g UILabel) to display the row for the component.
    // for the view versions, we cache any hidden and thus unused views and pass them back for reuse.
    // If you return back a different object, the old one will be released. the view will be centered in the row rect
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row) Elmo"
    }
    
    //func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? // attributed title is favored if both methods are implemented
    
    //func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {}
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("In \(self.classForCoder).selectedRow \(row)")
    }
}
extension RVMessageAuthorTableViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1}
    
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return 6}
}
