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
    
    // Notifies the view controller when the right button's action has been triggered, manually or by using the keyboard return key.
    override func didPressRightButton(_ sender: Any!) {
        
        if !setupSLKDatasource {
            super.didPressRightButton(sender)
            return
        }
        print("In \(self.classForCoder).didPressRightBUtton. should not be here")
        // This little trick validates any pending auto-correction or auto-spelling just after hitting the 'Send' button
        self.textView.refreshFirstResponder()
        RVGroup.deleteAll { (error) in
            if let error = error {
                error.printError()
            } else {
                print("In \(self.classForCoder), successfully deleted all groups")
            }
        }
        /*
        self.createTransaction(text: self.textView.text) {
            let indexPath = IndexPath(row: 0, section: 0)
            //let rowAnimation: UITableViewRowAnimation = self.isInverted ? .bottom : .top
            let scrollPosition: UITableViewScrollPosition = self.isInverted ? .bottom : .top
            
            //        self.tableView.beginUpdates()
            //        self.messages.insert(message, at: 0)
            //        self.tableView.insertRows(at: [indexPath], with: rowAnimation)
            //        self.tableView.endUpdates()
            if let _ = self.tableView?.cellForRow(at: indexPath) {
                self.tableView?.scrollToRow(at: indexPath, at: scrollPosition, animated: true)
            }
            // Fixes the cell from blinking (because of the transform, when using translucent cells)
            // See https://github.com/slackhq/SlackTextViewController/issues/94#issuecomment-69929927
            //   self.tableView?.reloadRows(at: [indexPath], with: .automatic)
        }
 */
        super.didPressRightButton(sender)
    }
 
}
