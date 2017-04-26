//
//  RVUserListController8.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/25/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit

class RVUserListController8: RVBaseListController8  {
    
    
    override var instanceConfiguration: RVBaseConfiguration8 { return RVUserListConfiguration8(scrollView: dsScrollView) }

    override func viewDidLoad() {
        self.queue.addOperation(RVControllerOperation<NSObject>(title: "\(self.classForCoder).viewDidLoad", viewController: self, closure: { (operation, error) in
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
        self.queue.addOperation(RVControllerOperation<NSObject>(title: "\(self.classForCoder).didPressRightButton", viewController: self, closure: { (operation , error) in
            if let error = error {
                error.printError(message: "In \(self.classForCoder).didPressRightButton")
                operation.completeOperation()
                return
            } else {
                print("In \(self.classForCoder).didPressRightButton, need to implement User Something")
                //self.createGroup(text: self.textView.text) {}
                
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
                operation.completeOperation()
            }
        }))
        
        
    }
    
}
