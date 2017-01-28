//
//  RVWatchGroupTableCell.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/28/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit

class RVWatchGroupTableCell: RVBaseTableViewCell {
    static let identifier = "RVWatchGroupTableCell"
    
    @IBOutlet weak var watchGroupImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var watchGroupTitleLabel: UILabel!
    @IBOutlet weak var watchGroupDescriptionLabel: UILabel!
    
    override func configure() {
        if let group = self.model as? RVWatchGroup {
            setLabelText(label: usernameLabel, text: group.fullName)
            setLabelText(label: watchGroupTitleLabel, text: group.title)
            setLabelText(label: watchGroupDescriptionLabel, text: group.regularDescription)
            showImage(rvImage: group.image, imageView: watchGroupImageView)
        }
    }
}
