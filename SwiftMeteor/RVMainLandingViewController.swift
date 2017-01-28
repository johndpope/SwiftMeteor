//
//  RVMainLandingViewController.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/4/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
import SwiftDDP

class RVMainLandingViewController: RVBaseViewController {
 //   @IBOutlet weak var segmentedControl: UISegmentedControl!

    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        p("segmentedControlValueChanged", "to index: \(sender.selectedSegmentIndex)")
    }
    
    @IBAction func doneButtonTouched(_ sender: UIBarButtonItem) { RVViewDeck.sharedInstance.toggleSide(side: RVViewDeck.Side.left) }
    func presentWatchGroupCreateEdit(watchGroup: RVWatchGroup?) {
        let storyboard = UIStoryboard(name: RVCoreInfo.sharedInstance.mainStoryboard, bundle: nil)
        if let navController = storyboard.instantiateViewController(withIdentifier: "WatchGroupCreateEditNavController") as? UINavigationController {
            if let controller = navController.topViewController as? RVWatchGroupCreateEditController {
                let carrier = RVStateCarrier()
                carrier.incoming = watchGroup
                controller.carrier = carrier
            }
            self.present(navController, animated: true, completion: { })
        }
    }
    @IBAction func searchButtonTouched(_ sender: UIBarButtonItem) {
        
        presentWatchGroupCreateEdit(watchGroup: nil)
    }
    override func viewDidLoad() {
       // if let scrollView = self.dsScrollView { self.mainState = RVMainStateTask(scrollView: scrollView) }
        if let scrollView = self.dsScrollView { mainState = RVWatchGroupState(scrollView: scrollView) }
        super.viewDidLoad()
        if let tableView = self.tableView {
            tableView.register(RVFirstViewHeaderCell.self, forHeaderFooterViewReuseIdentifier: RVFirstViewHeaderCell.identifier)
        }
        RVViewDeck.sharedInstance.toggleSide(side: .right, animated: true)
    }
    override func setupTopView() {
        if let topView = self.topView {
            if let segmentedControl = self.segmentedControl {
                var index = 0
                segmentedControl.removeAllSegments()
                if mainState.segmentViewFields.count > 0 {
                    for segment in mainState.segmentViewFields {
                        segmentedControl.insertSegment(withTitle: segment.first!.key, at: index, animated: true)
                        index = index + 1
                    }
                    segmentedControl.selectedSegmentIndex = 0
                } else {
                    print("In \(self.classForCoder).setTopVIew, hiding it")
                    topView.isHidden = true
                }
            }
        }
    }

    // Called by RVViewDeck
    func loadup() {
        if RVAppState.shared.state == RVAppState.State.ShowProfile {
            let storyboard = UIStoryboard(name: RVCoreInfo.sharedInstance.mainStoryboard, bundle: nil)
            if let viewController = storyboard.instantiateViewController(withIdentifier: "ProfileNavController") as? UINavigationController {
                self.present(viewController, animated: true, completion: { })
            }
        } else {
            mainState.initialize()
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var actions = [UITableViewRowAction]()
        if let item = manager.item(indexPath: indexPath) as? RVWatchGroup {
            if let itemOwnerId = item.ownerId {
                if let userProfile = self.userProfile {
                    if let userProfileId = userProfile.localId {
                        if itemOwnerId == userProfileId {
                            let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Edit") { (action, indexPath) in
                                if let watchGroup = self.manager.item(indexPath: indexPath) as? RVWatchGroup {
                                    self.presentWatchGroupCreateEdit(watchGroup: watchGroup)
                                }
                            }
                            editAction.backgroundColor = UIColor.blue
                            actions.append(editAction)
                            let deleteAction = UITableViewRowAction(style: .default , title: "Delete") { (action, indexPath) in
                                print("In editActions delete callback")
                            }
                            deleteAction.backgroundColor = UIColor.red
                            actions.append(deleteAction)
                        }
                    }
                }
            }
        }
        if actions.count > 0 { return actions }
        return nil
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let _ = mainState as? RVWatchGroupState {
            if let cell = tableView.dequeueReusableCell(withIdentifier: RVWatchGroupTableCell.identifier, for: indexPath) as? RVWatchGroupTableCell {
                cell.model = manager.item(indexPath: indexPath)
                return cell
            }
        }
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110.0
    }
}






