//
//  RVTransactionViewController.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/4/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
class RVTransactionViewController: RVBaseViewController4 {
    
    @IBAction func searchButtonTouched(_ sender: UIBarButtonItem) {
        searchController.isActive = true
    }
    @IBAction func menuButtonTouched(_ sender: UIBarButtonItem) {
            self.deck.toggleSide(side: .left)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // manager.addSection(section: RVTransactionDatasource())
    }
    


}


