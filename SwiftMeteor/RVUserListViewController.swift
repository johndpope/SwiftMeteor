//
//  RVUserListViewController.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 2/5/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit

class RVUserListViewController: RVBaseViewController3 {
    static let SegueFromMemberListToMemberScene = "SegueFromMemberListToMemberScene"

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let member = manager.item(indexPath: indexPath) as? RVUserProfile {
            let payload: [String: AnyObject] = ["chatBuddy" : member, "indexPath": indexPath as AnyObject]
            self.performSegue(withIdentifier: RVUserListViewController.SegueFromMemberListToMemberScene, sender: payload)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier ==  RVUserListViewController.SegueFromMemberListToMemberScene {
                if let payload = sender as? [String: AnyObject] {
                    if let member = payload["chatBuddy"] as? RVUserProfile {
                        if let indexPath = payload["indexPath"] as? IndexPath {
                            if let tableView = self.tableView {
                                RVPrivateChat.specialPrivateChatLookup(otherUser: member) { (chat, error) in
                                    if let error = error {
                                        error.printError()
                                    } else if let chat = chat {
                                        print("In \(self.classForCoder)\n\(chat.toString())")
                                        // chat.delete(callback: { (count, error ) in if let error = error { error.printError() } })
                                        self.appState.unwind {
                                            if let nav = segue.destination as? UINavigationController {
                                                if let destination = nav.topViewController as? RVMemberViewController2 {
                                                    destination.privateChat = chat
                                                }

                                            } else {
                                                print("In \(self.classForCoder).prepareForSegue, destination is not RVMemberViewController2")
                                            }
                                            let memberToMemberState = RVMemberToMemberChatState()
                                            memberToMemberState.stack.append(member)
                                            self.appState = memberToMemberState
                                            tableView.deselectRow(at: indexPath, animated: true)
                                        }
                                    } else {
                                        print("In \(self.classForCoder).   no error but no privateChat result")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
