//
//  RVLeftMenuViewController4.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/19/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
class RVLeftMenuViewController4: RVBaseViewController44 {
    var deck: RVViewDeck8 { return RVViewDeck8.shared }
    static let identifier = "RVLeftMenuViewController4"
    let actions = ["Logout"]
    
    @IBAction func menuButtonTouched(_ sender: UIBarButtonItem) {
        deck.returnToCenter {
            
        }
    }
    
}
extension RVLeftMenuViewController4: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: RVLeftMenuTableViewCell4.identifier, for: indexPath) as? RVLeftMenuTableViewCell4 {
            if indexPath.row < actions.count {
                cell.actionText = actions[indexPath.row]
                cell.configure()
            }
        }
        return UITableViewCell()
    }
}
extension RVLeftMenuViewController4: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < actions.count {
            let selected = actions[indexPath.row]
            if selected == "Logout" {
                print("In \(self.classForCoder).didSelectRow \(indexPath.row)")
                RVSwiftDDP.sharedInstance.logout(callback: { (error) in
                    if let error = error {
                        error.append(message: "In \(self.classForCoder).didSelectRowAt \(indexPath.row) gor error logging out")
                        error.printError()
                    } else {
                        
                    }
                    tableView.deselectRow(at: indexPath, animated: true)
                })
            }
        }
    }
}
