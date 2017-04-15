//
//  RVGroupListController4.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/7/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit


class RVGroupListController4: RVBaseSLKViewController4 {
    
 
    override var instanceConfiguration: RVBaseConfiguration4 { return RVTransactionConfiguration4(scrollView: dsScrollView) }
    override func viewDidLoad() {
        let _ = RVSwiftDDP.sharedInstance.unsubscribe(collectionName: RVModelType.transaction.rawValue) {
            print("In \(self.classForCoder).viewDidLoad, returned from unsubscribing")
        }
        if let tableView = self.tableView {
            tableView.separatorStyle = .singleLine
            let nib = UINib(nibName: RVTransactionTableViewCell.identifier, bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: RVTransactionTableViewCell.identifier)
            
            let zeroNib = UINib(nibName: RVZeroTableCell.identifier, bundle: nil)
            tableView.register(zeroNib, forCellReuseIdentifier: RVZeroTableCell.identifier)
        }
        if let tableView = self.tableView { tableView.register(RVFirstViewHeaderCell.self, forHeaderFooterViewReuseIdentifier: RVFirstViewHeaderCell.identifier) }
        super.viewDidLoad()
        
    }
}
