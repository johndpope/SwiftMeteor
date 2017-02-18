//
//  RVSlackMessageTextView.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 2/17/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
import SlackTextViewController

class RVSlackMessageTextView: SLKTextView {
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        self.backgroundColor = UIColor.white
        self.placeholder = "Message"
        self.placeholderColor = UIColor.lightGray
        self.pastableMediaTypes = SLKPastableMediaType.all
        self.layer.borderColor = UIColor(colorLiteralRed: 217/255, green: 217/255, blue: 217/255, alpha: 1.0).cgColor
    }
}
