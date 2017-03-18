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
        RVTransactionCollection().subscribe {
            print("In \(self.classForCoder).viewDidLoad subscribed to Transactions")
        }
    }
}
