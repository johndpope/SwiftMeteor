//
//  RVZeroTableCell.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/12/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
class RVZeroTableCell: UITableViewCell {
    @IBOutlet weak var cellTitleLabel: UILabel!
    weak var item: RVBaseModel? = nil
    static let identifier = "RVZeroTableCell"
    
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
        
    }
    override func prepareForReuse() {
        self.item = nil
    }
    
    
}
