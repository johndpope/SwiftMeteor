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
    
    var parentModel: RVBaseModel? {
        get {
            if self.stack.count > 0 {
                return self.stack.last
            } else if let root = coreInfo.rootGroup {
                self.stack.append(root)
                return root
            } else {
                return nil
            }
        }
    }
    
    override var instanceConfiguration: RVBaseConfiguration8 { return RVGroupDynamicListConfiguration8(scrollView: dsScrollView) }
    
    
    override func viewDidLoad() {
        self.queue.addOperation(RVControllerOperation(viewController: self, operation: {
            if let tableView = self.tableView {
                tableView.separatorStyle = .singleLine
                let nib = UINib(nibName: RVTransactionTableViewCell.identifier, bundle: nil)
                tableView.register(nib, forCellReuseIdentifier: RVTransactionTableViewCell.identifier)
                
                let zeroNib = UINib(nibName: RVZeroTableCell.identifier, bundle: nil)
                tableView.register(zeroNib, forCellReuseIdentifier: RVZeroTableCell.identifier)
            }
            if let tableView = self.tableView { tableView.register(RVFirstViewHeaderCell.self, forHeaderFooterViewReuseIdentifier: RVFirstViewHeaderCell.identifier) }
            super.viewDidLoad()
        }))

        
    }
    func createGroup(text: String, callback: @escaping()-> Void) {
        let group = RVGroup()
        group.special = .regular
        group.title = text
        group.everywhere = true
        if let parentModel = self.parentModel {
           // print("In \(self.classForCoder).createGroup, have parent. TYpe: \(parentModel.modelType.rawValue) ID is: \(String(describing: parentModel.localId))")
            group.setParent(parent: parentModel)
        } else {
            print("In \(self.classForCoder).createdGroup with title \(text), no parent model")
        }
        group.create { (model, error) in
            if let error = error {
                error.append(message: "IN \(self.classForCoder).createGroup, got error ")
                error.printError()
            }
            callback()
        }
    }
    
    // Notifies the view controller when the right button's action has been triggered, manually or by using the keyboard return key.
    override func didPressRightButton(_ sender: Any!) {
        self.queue.addOperation(RVControllerOperation(viewController: self, operation: {
            self.createGroup(text: self.textView.text) {}
            
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
        }))

    }
 
}
