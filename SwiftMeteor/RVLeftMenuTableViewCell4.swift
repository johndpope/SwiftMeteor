//
//  RVLeftMenuTableViewCell4.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/19/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit

class RVLeftMenuTableViewCell4: RVBaseTableViewCell {
    static let identifier = "RVLeftMenuTableViewCell4"
    @IBOutlet weak var actionLabel: UILabel!
    var actionText: String = "Action"
    override func configure() {
        setLabelText(label: actionLabel, text: actionText)
        super.configure()
    }
    override func prepareForReuse() {
        actionText = "Action"
        setLabelText(label: actionLabel, text: actionText)
        super.prepareForReuse()
    }
}
