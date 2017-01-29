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
    let SegueFromMainToWatchGroupEdit = "SegueFromMainToWatchGroupEdit"
    let SegueFromMainToProfileScene = "SegueFromMainToProfileScene"
 //   @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBAction func unwindFromWatchGroupCreateEdit(seque: UIStoryboardSegue) {
        if let _ = seque.source as? RVWatchGroupCreateEditController {
        }
    }
    @IBAction func unwindFromProfileScene(segue: UIStoryboardSegue) {
        if let _ = segue.source as? RVRightMenuViewController {}
    }
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        p("segmentedControlValueChanged", "to index: \(sender.selectedSegmentIndex)")
    }
    @IBOutlet weak var OverlayView: UIView!
    
    @IBAction func doneButtonTouched(_ sender: UIBarButtonItem) { RVViewDeck.sharedInstance.toggleSide(side: RVViewDeck.Side.left) }
    func presentWatchGroupCreateEdit(watchGroup: RVWatchGroup?) {
        performSegue(withIdentifier: "SegueFromMainToWatchGroupEdit", sender: watchGroup )
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueFromMainToWatchGroupEdit {
            if let navController = segue.destination as? UINavigationController {
                if let controller = navController.topViewController as? RVWatchGroupCreateEditController {
                    if let watchGroup = sender as? RVWatchGroup {
                        let carrier = RVStateCarrier()
                        carrier.incoming = watchGroup
                        controller.carrier = carrier
                    }
                }
            } else if segue.identifier == SegueFromMainToProfileScene {
                if let navController = segue.destination as? UINavigationController {
                    if let _ = navController.topViewController as? RVProfileViewController {}
                }
            }
        }
    }
    @IBAction func searchButtonTouched(_ sender: UIBarButtonItem) {
        presentWatchGroupCreateEdit(watchGroup: nil)
    }
    override func viewDidLoad() {
       // if let scrollView = self.dsScrollView { self.mainState = RVMainStateTask(scrollView: scrollView) }
        if let scrollView = self.dsScrollView { mainState = RVWatchGroupListState(scrollView: scrollView) }
        super.viewDidLoad()
        if let tableView = self.tableView {
            tableView.register(RVFirstViewHeaderCell.self, forHeaderFooterViewReuseIdentifier: RVFirstViewHeaderCell.identifier)
            

        }
        RVViewDeck.sharedInstance.toggleSide(side: .right, animated: true)
    }
    func setupWatchGroup(){
        print("In setupWatchGroup")
        self.mainState = RVWatchGroupState(scrollView: dsScrollView!)
        setupTopView()
        if let overlayView = self.OverlayView {
            let view = RVWatchGroupView(frame: overlayView.bounds)
            overlayView.addSubview(view)
        }
    }
    override func setupTopView() {
        if let topView = self.topView {
            if let segmentedControl = self.segmentedControl {
                self.topView.isHidden = false
                self.tableView.isUserInteractionEnabled = false
                var index = 0
                segmentedControl.removeAllSegments()
                if mainState.segmentViewFields.count > 0 {
                    print("In \(self.classForCoder).setupTopView")
                    for segment in mainState.segmentViewFields {
                        segmentedControl.insertSegment(withTitle: segment.rawValue, at: index, animated: true)
                        index = index + 1
                    }
                    segmentedControl.selectedSegmentIndex = 0
                } else {
                    print("In \(self.classForCoder).setTopVIew, hiding it")
                    topView.isHidden = true
                    self.tableView.isUserInteractionEnabled = true
                }
            } else {
                print("In \(self.classForCoder).setupTopView no segmentedControl")
            }
        } else {
            print("In \(self.classForCoder).setupTopView no topView")
        }
    }

    // Called by RVViewDeck
    func loadup() {
        if RVAppState.shared.state == RVAppState.State.ShowProfile {
            performSegue(withIdentifier: SegueFromMainToProfileScene, sender: nil)
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
    func hideEditButtons() {
        if let tableView = self.tableView { tableView.setEditing(false, animated: true) }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        setupWatchGroup()
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var actions = [UITableViewRowAction]()
        if let item = manager.item(indexPath: indexPath) as? RVWatchGroup {
            if let itemOwnerId = item.ownerId {
                if let userProfile = self.userProfile {
                    if let userProfileId = userProfile.localId {
                        if itemOwnerId == userProfileId {
                            let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Edit") { (action, indexPath) in
                                self.perform(#selector(RVMainLandingViewController.hideEditButtons), with: nil, afterDelay: 0.01)
                                if let watchGroup = self.manager.item(indexPath: indexPath) as? RVWatchGroup {
                                    self.presentWatchGroupCreateEdit(watchGroup: watchGroup)
                                }
                            }
                            editAction.backgroundColor = UIColor.blue
                            actions.append(editAction)
                            let deleteAction = UITableViewRowAction(style: .default , title: "Delete") { (action, indexPath) in
                                self.perform(#selector(RVMainLandingViewController.hideEditButtons), with: nil, afterDelay: 0.5)
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
        if let _ = mainState as? RVWatchGroupListState {
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






