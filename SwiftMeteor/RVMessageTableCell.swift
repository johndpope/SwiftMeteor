//
//  RVMessageTableCell.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 2/4/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit

class RVMessageTableCell: RVBaseTableViewCell {
    static let identifier = "RVMessageTableCell"
    @IBOutlet weak var userIconImageViewe: UIImageView!
    @IBOutlet weak var userFullNameLabel: UILabel!
    @IBOutlet weak var messageTextLabel: UILabel!
    @IBOutlet weak var urgencyLabel: UILabel!
    @IBOutlet weak var sentDateLabel: UILabel!
    override func configure() {
        if let message = self.model as? RVMessage {
            setLabelText(label: userFullNameLabel, text: message.fullName)
            setLabelText(label: messageTextLabel, text: message.text)
            setLabelText(label: urgencyLabel, text: message.priority.description)
            setLabelText(label: sentDateLabel, date: message.createdAt)
            if let userProfile = message.userProfile {
                if let rvImage = userProfile.image {
                    showImage(rvImage: rvImage, imageView: userIconImageViewe)
                }
            } else {
                if let ownerId = message.ownerId {
                    RVUserProfile.retrieveInstance(id: ownerId, callback: { (profile, error) in
                        if let error = error {
                            error.append(message: "In \(self.classForCoder).configure, got error retrieving userProfile with id \(ownerId)")
                            error.printError()
                        } else if let profile = profile as? RVUserProfile {
                            if let currentMessage = self.model as? RVMessage {
                                if let currentOwnerId = currentMessage.ownerId {
                                    if currentOwnerId == ownerId {
                                        currentMessage.userProfile = profile
                                        if let rvImage = profile.image {
                                            self.showImage(rvImage: rvImage, imageView: self.userIconImageViewe)
                                        }
                                    }
                                }
                            }
                        } else {
                            print("In \(self.classForCoder).configure, attempting to get userProfile with id \(ownerId). No error but no result")
                        }
                    })
                } else {
                    print("In \(self.classForCoder).configure, no ownerId")
                }
            }
        }
    }
    
}
