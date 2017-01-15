//
//  RVLeftMenuTableViewCell.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/4/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit

class RVLeftMenuTableViewCell: RVBaseTableViewCell {
    static let identifier = "RVLeftMenuTableViewCell"
    let _menuItem: [RVLeftMenuController.MenuKeys: String] = [RVLeftMenuController.MenuKeys.name: "Nothing", .displayText: "No display text"]
    var menuItem: [RVLeftMenuController.MenuKeys: String] = [RVLeftMenuController.MenuKeys.name: "Nothing"] {
        didSet {
            configure()
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func configure() {
        setLabelText(label: titleLabel, text: menuItem[.displayText])
    }
    override func prepareForReuse() {
        self.menuItem = _menuItem
        super.prepareForReuse()
    }
}
