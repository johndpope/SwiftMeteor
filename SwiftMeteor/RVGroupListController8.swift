//
//  RVGroupListController8.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/16/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit

class RVGroupListController8: RVBaseListController8  {
    static let identifier = "RVGroupListController8"
    
    override var instanceConfiguration: RVBaseConfiguration8 { return RVGroupDynamicListConfiguration8(scrollView: dsScrollView) }
    
    @IBAction func AllUnreadSegementedControlChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        if index == 0 {
            print("All selected")
            self.andTerms = [RVQueryItem]()
        } else {
            print("Unread Only selected")
            self.andTerms = [RVQueryItem(term: .readState, value: RVReadState.unread.rawValue as AnyObject, comparison: .eq)]
        }
        if let controller = self.searchController {
            if controller.isActive {
                self.doFilterSearch(searchController: searchController)
                return
            }
        }
        self.endSearch()
    }
    
    override func viewDidLoad() {
        let _ = RVSwiftDDP.sharedInstance.unsubscribe(collectionName: RVModelType.transaction.rawValue) {
            // print("In \(self.classForCoder).viewDidLoad, returned from unsubscribing")
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
