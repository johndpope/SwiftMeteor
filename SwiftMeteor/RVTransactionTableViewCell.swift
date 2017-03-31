//
//  RVTransactionTableViewCell.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/18/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
import SlackTextViewController
class RVTransactionTableViewCell: RVBaseTableViewCell, RVItemRetrieve {
    
    var usedForMessage: Bool = true
    static let MinimumHeight: CGFloat = 60.0;
    static let AvatarHeight:  CGFloat = 40.0;
    static let AutoCompletionCellIdentifier = "AutoCompletionCell"
    static let identifier = "RVTransactionTableViewCell"
    
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageContentLabel: UILabel!
    
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var authorImageView: UIImageView!
    var indexPath: IndexPath!
    var item:RVBaseModel? = nil {
        didSet {
            self.configureSubviews()
        }
    }
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = UIColor.white
        self.configureSubviews()
    }
    //   func defaultFontSize() -> CGFloat { return 30.0 }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configureSubviews()
    }
    
    func configureSubviews() {
        if let label = self.titleLabel {
            label.font = UIFont.boldSystemFont(ofSize: RVTransactionTableViewCell.defaultFontSize())
            if let item = self.item {
                if let title = item.title {
                    label.text = title
                }
            }
        }
        if let label = self.messageContentLabel {
            label.font = UIFont.systemFont(ofSize: RVTransactionTableViewCell.defaultFontSize())
        }
        if let label = self.createdAtLabel {
            label.font = UIFont.systemFont(ofSize: RVTransactionTableViewCell.defaultFontSize())
            if let item = self.item {
                if let createdAt = item.createdAt {
                    label.text = "\(createdAt)"
                }
            }
        }
        if let view = self.authorImageView {
            view.layer.cornerRadius = RVTransactionTableViewCell.AvatarHeight / 2.0
            view.layer.masksToBounds = true
        }
        if let view = self.outerView {
            view.layer.cornerRadius = 20.0
            view.layer.masksToBounds = true
        }
    }
    
    class func defaultFontSize() -> CGFloat {
        var pointSize: CGFloat = 16.0
        let contentSizeCategory = UIApplication.shared.preferredContentSizeCategory
        pointSize = pointSize + SLKPointSizeDifferenceForCategory(contentSizeCategory.rawValue)
        return pointSize
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        let pointSize = RVTransactionTableViewCell.defaultFontSize()
        
        if let label = self.titleLabel {
            label.font = UIFont.boldSystemFont(ofSize: pointSize)
            label.text = ""
        }
        
        if let label = self.messageContentLabel {
            label.font = UIFont.systemFont(ofSize: pointSize)
            label.text = ""
        }
        if let label = self.createdAtLabel {
            label.font = UIFont.systemFont(ofSize: pointSize)
            label.text = ""
        }
    }
}
