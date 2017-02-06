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
        self.model = nil
    }

}
extension RVBaseTableViewCell {
    func setLabelText(label: UILabel!, text: String?, default: String = "nothing") {
        if let label = label {
            if let text = text { label.text = text
            } else { label.text = "nothing" }
        }
    }
    func setLabelText(label: UILabel?, date: Date?) {
        if let label = label {
            if let date = date {label.text = RVDateToHumanMapper.shared.timeAgoSinceDate(date: date, numericDates: false)}
        }
    }
    func setButtonText(button: UIButton!, text: String?) {
        if let button = button {
            if let text = text {
                button.setTitle(text, for: UIControlState.normal)
            }
        }
    }
    func showImage(rvImage: RVImage?, imageView: UIImageView? ) {
        if let imageView = imageView {
            imageView.image = nil
            if let model = self.model {
                if let id = model.localId {
                    if let rvImage = rvImage {
                        rvImage.download(callback: { (uiImage, error) in
                            if let error = error {
                                error.append(message: "In \(self.classForCoder).showImage, got error ")
                                error.printError()
                            } else if let uiImage = uiImage {
                                if let current = self.model {
                                    if let currentId = current.localId {
                                        if currentId == id {
                                            imageView.image = uiImage
                                        }
                                    }
                                }
                            } else {
                                print("In \(self.classForCoder).showImage, no error but no image")
                            }
                        })
                    }
                }
            }
        }
    }
}
