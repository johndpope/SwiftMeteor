//
//  RVTaskTableViewCell.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/6/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit

class RVTaskTableViewCell: RVBaseTableViewCell {
    static let identifier = "RVTaskTableViewCell"
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
