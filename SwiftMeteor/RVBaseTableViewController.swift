//
//  RVBaseTableViewController.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/27/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit

class RVBaseTableViewController: UITableViewController {
    var instanceType: String { get { return String(describing: type(of: self)) } }
    var _carrier: RVStateCarrier? = nil
    var carrier: RVStateCarrier {
        get {
            if let carrier = _carrier { return carrier }
            self._carrier = RVStateCarrier()
            return self._carrier!
        }
        set {
            self._carrier = newValue
            self.configure()
        }
    }
    var userProfile: RVUserProfile? { get { return RVCoreInfo.sharedInstance.userProfile }}
    var domain: RVDomain? { get { return RVCoreInfo.sharedInstance.domain }}
    func configure() {}
}

extension RVBaseTableViewController {
    
    func setLabelText(label: UILabel?, text: String? = nil, defaultText: String? = nil) {
        if let label = label {
            if let text = text { label.text = text}
            else if let defaultText = defaultText {label.text = defaultText}
            else {label.text = nil}
        }
    }
    func setTextFieldText(textField: UITextField?, text: String? = nil, defaultText: String? = nil) {
        if let textField = textField {
            if let text = text {textField.text = text }
            else if let defaultText = defaultText {textField.text = defaultText}
            else {textField.text = nil }
        }
    }
    func showHideView(view: UIView?, hide: Bool) {
        if let view = view { view.isHidden = hide ? true : false}
    }
    func getTextFieldText(textField: UITextField?) -> String? {
        if let textField = textField { return textField.text }
        return nil
    }
    func getLabelText(label: UILabel?) -> String? {
        if let label = label { return label.text }
        return nil
    }
}
