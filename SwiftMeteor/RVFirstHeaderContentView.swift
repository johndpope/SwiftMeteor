//
//  RVFirstHeaderContentView.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/3/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit

class RVFirstHeaderContentView: UIView {

    weak var delegate: RVFirstHeaderContentViewDelegate?
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var expandCollapseButton: UIButton!
    @IBAction func expandCollapseButtonTouched(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.expandCollapseButtonTouched(button: sender)
        }
    }
    func configure(model: RVBaseModel?, collapsed: Bool, section: Int) {
        if let model = model {
            //print("In \(self.classForCoder).configure, have model")
            setLabelText(label: headerLabel, text: "\(model.title!)")
        }
        
        if collapsed {
            setButtonText(button: expandCollapseButton , text: "Expand")
        } else {
            setButtonText(button: expandCollapseButton , text: "Collapse")
        }
    }
}
protocol RVFirstHeaderContentViewDelegate: class {
    func expandCollapseButtonTouched(button: UIButton) -> Void
}

extension RVFirstHeaderContentView {
    func setLabelText(label: UILabel!, text: String?) {
        if let label = label {
            if let text = text {
                label.text = text
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
