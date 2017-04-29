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
    

    override var instanceConfiguration: RVListControllerConfigurationProtocol { return RVTransactionListConfiguration8<RVTransaction>(scrollView: dsScrollView) }
    override func viewDidLoad() {
        self.queue.addOperation(RVControllerOperation(title: "\(self.classForCoder).viewDidLoad", viewController: self, closure: { (operation, error) in
            if let error = error {
                error.printError()
                operation.completeOperation()
                return
            }
            if let tableView = self.tableView {
                tableView.separatorStyle = .singleLine
                let nib = UINib(nibName: RVTransactionTableViewCell.identifier, bundle: nil)
                tableView.register(nib, forCellReuseIdentifier: RVTransactionTableViewCell.identifier)
                
                let zeroNib = UINib(nibName: RVZeroTableCell.identifier, bundle: nil)
                tableView.register(zeroNib, forCellReuseIdentifier: RVZeroTableCell.identifier)
            }
            if let tableView = self.tableView { tableView.register(RVFirstViewHeaderCell.self, forHeaderFooterViewReuseIdentifier: RVFirstViewHeaderCell.identifier) }
            operation.completeOperation()

        }))
        super.viewDidLoad()
    }
    
    // Notifies the view controller when the right button's action has been triggered, manually or by using the keyboard return key.
    override func didPressRightButton(_ sender: Any!) {
        self.queue.addOperation(RVControllerOperation<NSObject>(title: "In \(self.classForCoder).didPressRightButton", viewController: self, closure: { (operation, error) in
            if let error = error {
                error.printError(message: "In \(self.classForCoder).didPressRightButton closure")
                operation.completeOperation()
                return
            } else {
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
                operation.completeOperation()
            }
        }))
    }
    func createTransaction(text: String, callback: @escaping()-> Void) {
       // print("In \(self.classForCoder).createTransaction")
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
            } else if let _ = model as? RVTransaction {
             //   print("In \(self.instanceType).createTransaction, created transaction \(transaction.localId ?? " no LocalId") \(transaction.createdAt?.description ?? " no createdAt")")
            } else {
                print("In \(self.instanceType).createTransaction, no error, but no result ")
            }
            callback()
        }
        
    }
}

