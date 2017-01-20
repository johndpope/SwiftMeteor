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
        [MenuKeys.name: "Logout", MenuKeys.displayText: "Logout"],

    ]
    override func viewDidLoad() {
        //self.dsScrollView = tableView
        self.dontUseManager = true
        super.viewDidLoad()
    }
    
}
extension RVLeftMenuController {

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? RVLeftMenuTableViewCell {
            cell.menuItem = menuItems[indexPath.row]
        } else {
            print("Did not find RVLeftMenuTableViewCell")
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("\(instanceType).didSelectRow")
        if indexPath.row >= 0 && indexPath.row < menuItems.count {
            let selection = menuItems[indexPath.row]
              //  print("In \(self.classForCoder).didSelectRowAt \(indexPath.row)")
            if let (_, string) = selection.first {
                if string == "Logout" {
                  //  print("In \(self.classForCoder).didSelectRowAt \(indexPath.row), Found Logout")
                    RVSwiftDDP.sharedInstance.logout(callback: { (error) in
                        if let error = error {
                            error.append(message: "In \(self.classForCoder).didSelectRowAt go error")
                            error.printError()
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
