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
    @IBAction func searchButtonTouched(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: RVCoreInfo.sharedInstance.mainStoryboard, bundle: nil)
        if let navController = storyboard.instantiateViewController(withIdentifier: "WatchGroupCreateEditNavController") as? UINavigationController {
            if let _ = navController.topViewController as? RVWatchGroupCreateEditController { }
            self.present(navController, animated: true, completion: { })
        }
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
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Edit") { (action, indexPath) in
            print("In editActions edit callback")
        }
        editAction.backgroundColor = UIColor.blue
        let deleteAction = UITableViewRowAction(style: .default , title: "Delete") { (action, indexPath) in
            print("In editActions delete callback")
        }
        return [editAction, deleteAction]
    }
}






