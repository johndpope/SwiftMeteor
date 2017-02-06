//
//  RVUserTableViewCell.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 2/5/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit

class RVUserTableViewCell: RVBaseTableViewCell {
    static let identifier = "UserCell"
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var localIdLabel: UILabel!
    
    override func configure() {
        if let userProfile = model as? RVUserProfile {
            setLabelText(label: fullNameLabel, text: userProfile.fullName)
            setLabelText(label: localIdLabel, text: userProfile.localId)
            if let rvImage = userProfile.image {
                showImage(rvImage: rvImage, imageView: userImageView)
            }
        } else {
            setLabelText(label: fullNameLabel, text: "")
            showImage(rvImage: nil, imageView: userImageView)
        }
    }
}
