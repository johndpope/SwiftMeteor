//
//  RVWatchGroupView.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/28/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit

class RVWatchGroupView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadHeaderFromNib()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    func loadHeaderFromNib() {
        if let views = Bundle.main.loadNibNamed("RVWatchGroupView", owner: nil, options: nil) {
            if let view = views.first as? UIView {
                view.frame = bounds
                view.alpha = 0.25
                view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.addSubview(view)
            }
        }
    }
 
}
