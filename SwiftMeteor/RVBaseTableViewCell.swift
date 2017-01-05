//
//  RVBaseTableViewCell.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/4/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit

class RVBaseTableViewCell: UITableViewCell {
    var instanceType: String { get { return String(describing: type(of: self)) } }
    var model: RVBaseModel? = nil {
        didSet {
            self.configure()
        }
    }
    func configure() {
        
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
}
extension RVBaseTableViewCell {
    func setLabelText(label: UILabel!, text: String?) {
        if let label = label {
            if let text = text {
                label.text = text
            } else {
                label.text = "nothing"
            }
        }
    }
    func setButtonText(button: UIButton!, text: String?) {
        if let button = button {
            if let text = text {
                button.setTitle(text, for: UIControlState.normal)
            }
        }
    }
}
