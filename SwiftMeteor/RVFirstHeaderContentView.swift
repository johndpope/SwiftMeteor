//
//  RVFirstHeaderContentView.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/3/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit

class RVFirstHeaderContentView: UIView {
    var section: Int = -1
    weak var delegate: RVFirstHeaderContentViewDelegate?
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var expandCollapseButton: UIButton!
    @IBAction func expandCollapseButtonTouched(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.expandCollapseButtonTouched(button: sender, view: self)
        }
    }
    func configure(section: Int, expand: Bool) {
        self.section = section
        setLabelText(label: headerLabel, text: "Section \(section)")
        if expand {
            setButtonText(button: expandCollapseButton , text: "Expand")
        } else {
            setButtonText(button: expandCollapseButton , text: "Collapse")
        }
    }
}
protocol RVFirstHeaderContentViewDelegate: class {
    func expandCollapseButtonTouched(button: UIButton, view: RVFirstHeaderContentView) -> Void
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
