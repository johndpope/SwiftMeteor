//
//  RVSlaceMessageViewCell.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/6/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
import SlackTextViewController

class RVSlackMessageViewCell: RVBaseTableViewCell {
    static let identifier = "RVSlackMessageViewCell"
    static let autoCompletionCellIdentifier = "AutoCompletionCell"
    static let minimumHeight: CGFloat = 50.0
    static let avatarHeight: CGFloat = 30.0
    
    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    
    
    var indexPath: NSIndexPath = NSIndexPath()
    var usedForMessage: Bool = true
    static func defaultFontSize() -> CGFloat {

            var pointSize: CGFloat = 16.0
            let contentSizeCategory = UIApplication.shared.preferredContentSizeCategory.rawValue 
            pointSize = pointSize + SLKPointSizeDifferenceForCategory(contentSizeCategory)
            return pointSize
    }
    override func configure() {
        super.configure()
        self.thumbnailView.backgroundColor = UIColor(white: 0.0, alpha: 1.0)
        self.thumbnailView.layer.cornerRadius = 30.0 / 2.0
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.selectionStyle = UITableViewCellSelectionStyle.none
        //let pointSize = RVSlackMessageViewCell.defaultFontSize
        self.titleLabel.text = ""
        self.bodyLabel.text = ""
    }
}
