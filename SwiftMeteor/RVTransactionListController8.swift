//
//  RVTransactionListController8.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/15/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit

class RVTransactionListController8: RVBaseListController8  {
    static let identifier = "RVTransactionListController8"
    

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
    override func reconnectedNotification(notification: Notification) {
        DispatchQueue.main.async {
            print("IN \(self.classForCoder).reconnectedNotification, doing initialize()")
            if self.doingSearch {
                self.doSearchInner()
            } else {
                self.configuration.endSearch(mainAndTerms: self.andTerms, callback: { (error ) in
                    if let error = error {
                        error.append(message: "In \(self.instanceType).endSearch2, got error ")
                        error.printError()
                    }
                })
            }
        
        }
    }
    override var instanceConfiguration: RVBaseConfiguration8 { return RVTransactionListConfiguration8(scrollView: dsScrollView) }
    override func viewDidLoad() {

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
        
        self.createTransaction(text: self.textView.text) {
            let indexPath = IndexPath(row: 0, section: 0)
            //let rowAnimation: UITableViewRowAnimation = self.isInverted ? .bottom : .top
            let scrollPosition: UITableViewScrollPosition = self.isInverted ? .bottom : .top
            
            //        self.tableView.beginUpdates()
            //        self.messages.insert(message, at: 0)
            //        self.tableView.insertRows(at: [indexPath], with: rowAnimation)
            //        self.tableView.endUpdates()
            
            self.tableView?.scrollToRow(at: indexPath, at: scrollPosition, animated: true)
            
            // Fixes the cell from blinking (because of the transform, when using translucent cells)
            // See https://github.com/slackhq/SlackTextViewController/issues/94#issuecomment-69929927
            //   self.tableView?.reloadRows(at: [indexPath], with: .automatic)
        }
        super.didPressRightButton(sender)
    }
    func createTransaction(text: String, callback: @escaping()-> Void) {
        print("In \(self.classForCoder).createTransaction")
        let transaction = RVTransaction()
        if let loggedInUser = self.userProfile {
            transaction.targetUserProfileId = loggedInUser.localId
            transaction.entityId = loggedInUser.localId
            transaction.entityModelType = .userProfile
            transaction.entityTitle = loggedInUser.fullName
        }
        transaction.title = text
        transaction.everywhere = true
        transaction.transactionType = .updated
        transaction.create { (model, error) in
            if let error = error {
                error.printError()
            } else if let transaction = model as? RVTransaction {
                print("In \(self.instanceType).createTransaction, created transaction \(transaction.localId ?? " no LocalId") \(transaction.createdAt?.description ?? " no createdAt")")
            } else {
                print("In \(self.instanceType).createTransaction, no error, but no result ")
            }
            callback()
        }
    }
}
