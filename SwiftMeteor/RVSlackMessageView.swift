//
//  RVSlackMessageView.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/6/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
import SlackTextViewController

class RVSlackMessageView: SLKTextView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        self.backgroundColor = UIColor.white
        self.placeholder = "Message"
        self.placeholderColor = UIColor.lightGray
        self.pastableMediaTypes = SLKPastableMediaType.all
        self.layer.borderColor = UIColor(colorLiteralRed: 217.0/255.0, green: 217.0/255.0, blue: 217.0/255.0, alpha: 1.0).cgColor
    }
}
