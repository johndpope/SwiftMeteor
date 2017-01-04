//
//  RVLeftMenuViewController.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 11/27/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import UIKit

class RVLeftMenuViewController: RVBaseViewController {
    static let identifier: String = "LeftMenu"
    
    @IBAction func closeButton(_ sender: UIButton) {
        RVViewDeck.sharedInstance.toggleSide(side: .center)
    }
}
