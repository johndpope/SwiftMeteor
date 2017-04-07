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
    @IBOutlet weak var scoreLabel: UILabel!
    
    override func configure() {
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor.darkGray.cgColor
        self.layer.cornerRadius = 5.0
        if let model = model {
            setLabelText(label: customTextLabel, text: model.title)
            setLabelText(label: descriptionLabel, text: model.handle)
            setLabelText(label: commentLabel, text: model.comment)
            setLabelText(label: scoreLabel, text: "\(model.score?.description ?? "")")
        }
        
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        model = nil
    }
}
