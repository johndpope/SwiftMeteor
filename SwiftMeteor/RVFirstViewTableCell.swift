//
//  RVFirstViewTableCell.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/1/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
class RVFirstViewTableCell: RVBaseTableViewCell {
    
    @IBOutlet weak var customTextLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!

    
    override func configure() {
        if let model = model {
            setLabelText(label: customTextLabel, text: model.text)
            setLabelText(label: descriptionLabel, text: model.regularDescription)
            setLabelText(label: commentLabel, text: model.comment)
        }
        
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        model = nil
    }
}
extension RVFirstViewTableCell {
    override func setLabelText(label: UILabel!, text: String?) {
        if let label = label {
            if let text = text {
                label.text = text
            } else {
                label.text = "nothing"
            }
        }
    }
    override func setButtonText(button: UIButton!, text: String?) {
        if let button = button {
            if let text = text {
                button.setTitle(text, for: UIControlState.normal)
            }
        }
    }
}
