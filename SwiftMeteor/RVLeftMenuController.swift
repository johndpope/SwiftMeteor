//
//  RVLeftMenuController.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/4/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
class RVLeftMenuController: RVBaseViewController {
    static let identifier = "RVLeftMenuController"
    var deck: RVViewDeck { get {return RVViewDeck.sharedInstance}}
    var coreInfo: RVCoreInfo { get { return RVCoreInfo.sharedInstance }}
    enum MenuKeys: String {
        case name = "name"
        case displayText = "displayText"
    }
  //  @IBOutlet weak var tableView: UITableView!
    @IBAction func menuButtonTouched(_ sender: UIBarButtonItem) {
        print("In \(self.classForCoder).menuButtonTOuched toggling to center")
        RVViewDeck.sharedInstance.toggleSide(side: .center)
    }


    let menuItems:[[RVLeftMenuController.MenuKeys: String]] = [
        [MenuKeys.name: "Profile", MenuKeys.displayText: "Profile"],
        [MenuKeys.name: "Watchgroups", MenuKeys.displayText: "WatchGroups" ],
        [MenuKeys.name: "Members", MenuKeys.displayText: "Members"],
        [MenuKeys.name: "Transactions", MenuKeys.displayText: "Transactions"],
        [MenuKeys.name: "Transaction", MenuKeys.displayText: "Transaction"],
        [MenuKeys.name: "Logout", MenuKeys.displayText: "Logout"],
        [MenuKeys.name: "ClearUsers", MenuKeys.displayText: "ClearUsers"],
        [MenuKeys.name: "Group", MenuKeys.displayText: "Group"],
        [MenuKeys.name: "RootGroup", MenuKeys.displayText: "RootGroup"]

    ]
    override func viewDidLoad() {
       // self.mainState = RVLeftControllerState()
        super.viewDidLoad()
    }
    var topParentId: String = "88"
}
extension RVLeftMenuController {

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? RVLeftMenuTableViewCell {
            cell.menuItem = menuItems[indexPath.row]
        } else {
            print("Did not find RVLeftMenuTableViewCell")
        }
    }
    func createdTransaction() -> RVTransaction{
        let transaction = RVTransaction()
        transaction.title = title
        let owner = RVCoreInfo.sharedInstance.userProfile!
        transaction.topParentId = topParentId
        transaction.topParentModelType = RVModelType.image
        transaction.parentId = "12345"
        transaction.parentModelType = RVModelType.watchgroup
        transaction.transactionType = .added
        transaction.ownerId = owner.localId
        transaction.fullName = owner.fullName
        transaction.handle = owner.handle
        transaction.domainId = owner.domainId
        transaction.entityId = "someMessageEntityId"
        transaction.entityModelType = RVModelType.message
        transaction.readState = .unread
        return transaction
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {


        /*
        query.addAnd(term: .modelType , value: RVModelType.transaction.rawValue as AnyObject , comparison: .eq)
        RVTransaction.bulkQuery(query: query) { (results: [RVBaseModel]?, error ) in
            if let error = error {
                error.printError()
            } else if let models = results as? [RVTransaction] {
                print("In \(self.classForCoder). have \(models.count) results")
            } else {
                print("In \(self.classForCoder).no errors, but no results")
            }
        }
        let collection = RVTransactionCollection()
        collection.query = query
        let subscriptionId = collection.subscribe {
            print("In \(self.instanceType).callback")
        }
        */

        //print("In \(self.instanceType).didSelect subscriptionId = \(subscriptionId)")
        //print("\(instanceType).didSelectRow")
        if indexPath.row >= 0 && indexPath.row < menuItems.count {
            let selection = menuItems[indexPath.row]
              //  print("In \(self.classForCoder).didSelectRowAt \(indexPath.row)")
            if let (_, string) = selection.first {
                if string == "Logout" {
                  //  print("In \(self.classForCoder).didSelectRowAt \(indexPath.row), Found Logout")
                    RVSwiftDDP.sharedInstance.logout(callback: { (error) in
                        if let error = error {
                            error.append(message: "In \(self.classForCoder).didSelectRowAt gor error")
                            error.printError()
                        }
                    })
                } else if string == "ClearUsers" {
                    RVUserProfile.clearAll()
                } else if string == "Watchgroups" {
                    var stack = [RVBaseModel]()
                    if mainState.stack.count >= 2 {
                        for index in (0..<2) {
                            stack.append(mainState.stack[index])
                        }
                        mainState.unwind {
                            self.mainState = RVWatchGroupListState(stack: stack)
                            RVViewDeck.sharedInstance.centerViewController = RVViewDeck.sharedInstance.instantiateController(controller: .WatchGroupList)
                            RVViewDeck.sharedInstance.toggleSide(side: .center)
                        }
                    }
            
                } else if string == "Profile" {
                    print("In \(self.classForCoder).didSelectRowAt, about to install Profile and toggle to center")
                    deck.centerViewController = deck.instantiateController(controller: .Profile)
                    deck.toggleSide(side: .center)
                } else if string == "Members" {
                    coreInfo.appState.unwind {
                        self.coreInfo.appState = RVUserListState()
                        self.deck.centerViewController = self.deck.instantiateController(controller: .UserList)
                        self.deck.toggleSide(side: .center)
                    }
                } else if string == "Transactions" {
                    self.deck.centerViewController = self.deck.instantiateController(controller: .TransactionList)
                    self.deck.toggleSide(side: .center)
                } else if string == "Transaction" {

                
                    let transaction = createdTransaction()
                    transaction.create(callback: { (result, error) in
                        if let error = error {
                            error.printError()
                        } else if let result = result {
                            print("In \(self.classForCoder). transaction result: \n\(result.toString())")
                        } else {
                            print("In \(self.classForCoder) \(#line)")
                        }
                    })
                } else if string == "Group" {

                    let group = RVGroup()
                    group.setOwner(owner: RVCoreInfo.sharedInstance.userProfile!)
                    group.domainId = RVCoreInfo.sharedInstance.domain!.localId
                    group.parentId = "Elmo"
                    group.create(callback: { (group , error) in
                        if let error = error {
                            error.printError()
                        } else if let group = group {
                            print("In \(self.classForCoder). have group \(group.toString())")
                            let query = RVQuery()
                            query.addAnd(term: .createdAt, value: query.decadeAgo as AnyObject, comparison: .gte)
                            query.addSort(field: .createdAt, order: .ascending)
                            RVGroup.bulkQuery(query: query , callback: { (groups, error) in
                                if let error = error {
                                    error.printError()
                                } else if let groups = groups as? [RVGroup] {
                                    for group in groups {
                                        print("In \(self.classForCoder). group { id: \(group.localId!), createdAt: \(group.createdAt!)")
                                    }
                                } else {
                                    print("In \(self.classForCoder).bulkQuery no error but no groups")
                                }
                            })
                            
                        } else {
                            print("In \(self.classForCoder). no error no group")
                        }
                    })
                } else if string == "RootGroup" {
                    
                    RVGroup.getRootGroup(callback: { (group , error) in
                        if let error = error {
                            error.printError()
                        } else if let group = group {
                            print("\(group.toString())")
                        } else {
                            print("In \(self.classForCoder).RootGroup, no error but no root Group")
                        }
                    })
                
                } else {

                    print("In \(self.classForCoder).didSelectRowAt \(indexPath.row), \(string) not handled")
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40.0
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: RVLeftMenuTableViewCell.identifier, for: indexPath) as? RVLeftMenuTableViewCell {
            return cell
        } else {
            print("In \(instanceType).cellForRow, did not find RVLeftMenuTableViewCell")
            return UITableViewCell()
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
}
