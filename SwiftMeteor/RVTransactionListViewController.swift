//
//  RVTransactionListViewController.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/10/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit

class RVTransactionListViewController: RVBaseSLKViewController {

    override func viewDidLoad() {
        super.viewDidLoad()


        if let tableView = self.tableView {
            tableView.separatorStyle = .singleLine
            let nib = UINib(nibName: RVTransactionTableViewCell.identifier, bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: RVTransactionTableViewCell.identifier)
        }
        if let tableView = self.tableView { tableView.register(RVFirstViewHeaderCell.self, forHeaderFooterViewReuseIdentifier: RVFirstViewHeaderCell.identifier) }
        self.configuration = RVTransactionListConfiguration()
        configuration.configure(stack: self.stack) {
            
        }
    //    RVTransactionCollection().subscribe {
    //        print("In \(self.classForCoder).viewDidLoad subscribed to Transactions")
      //  }
    }

}
