//
//  RVMainLandingViewController.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/4/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
import SwiftDDP

class RVMainLandingViewController: RVBaseViewController2 {
    let SegueFromMainToWatchGroupEdit = "SegueFromMainToWatchGroupEdit"
    let SegueFromMainToProfileScene = "SegueFromMainToProfileScene"
 //   @IBOutlet weak var segmentedControl: UISegmentedControl!
    weak var watchGroupInfoView: RVWatchGroupView? = nil
    @IBAction func unwindFromWatchGroupCreateEdit(seque: UIStoryboardSegue) {
        if let _ = seque.source as? RVWatchGroupCreateEditController {
        }
    }
    @IBAction func unwindFromProfileScene(segue: UIStoryboardSegue) {
        if let _ = segue.source as? RVRightMenuViewController {}
    
    }
    func evaluateNewWatchGroupState(index: Int) {
        if index < mainState.segmentViewFields.count {
            switch(mainState.segmentViewFields[index]) {
            case .WatchGroupInfo:
                setupWatchGroupInfo()
            case .WatchGroupMembers:
                setupWatchGroupMembers()
            case .WatchGroupMessages:
                setupWatchGroupMessages()
            default:
                print("In \(self.classForCoder).evaluateNewWatchGroupState, unhandled state \(mainState.segmentViewFields[index].rawValue)")
            }
        
        }
    }
    func setupWatchGroupMembers() {
            print("In \(self.classForCoder).setUpWatchGroupMembers, after unwind \(self.manager.numberOfSections())")
            mainState.unwind {
                if let view = self.watchGroupInfoView {
                    view.removeFromSuperview()
                    self.watchGroupInfoView = nil
                }
                self.mainState = RVWatchGroupMembersState(scrollView: self.dsScrollView, stack: self.mainState.stack)
                self.install()
               // self.setupTopView()
                self.mainState.initialize()
                
            }
        
    }
    func setupWatchGroupMessages() {
        mainState.unwind {
            print("In \(self.classForCoder).setUpWatchGroupMessage, after unwind \(self.manager.numberOfSections())")
            if let view = self.watchGroupInfoView {
               view.removeFromSuperview()
                self.watchGroupInfoView = nil
            }
            
            self.mainState = RVWatchGroupForumState(scrollView: self.dsScrollView, stack: self.mainState.stack)
            self.install()
            //self.setupTopView()
            self.mainState.initialize()
 
        }
    }
    func setupWatchGroupInfo(){
        mainState.unwind {
            self.mainState = RVWatchGroupInfoState(scrollView: self.dsScrollView, stack: self.mainState.stack)
//
            self.install()
            //self.setupTopView()
            if self.watchGroupInfoView == nil {
                if let overlayView = self.OverlayView {
                    if let view = RVWatchGroupView.loadFromNib(frame: overlayView.bounds) {
                        self.watchGroupInfoView = view
                        view.state = self.mainState
                        overlayView.addSubview(view)
                    }
                    self.mainState.initialize()
                }
            }
            self.mainState.initialize()
        }
    }
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
       // p("segmentedControlValueChanged", "to index: \(sender.selectedSegmentIndex)")
        switch(mainState.state) { // current State
        case .WatchGroupInfo:
            evaluateNewWatchGroupState(index: sender.selectedSegmentIndex)
        case .WatchGroupMembers:
            evaluateNewWatchGroupState(index: sender.selectedSegmentIndex)
        case .WatchGroupMessages:
            evaluateNewWatchGroupState(index: sender.selectedSegmentIndex)
        default:
            print("In \(self.classForCoder).segmentedControlValueChanged to unaddressed state: \(mainState.state) \(mainState)")
        }
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
        print("In \(self.classForCoder).)viewDidLoad")
       // if let scrollView = self.dsScrollView { self.mainState = RVMainStateTask(scrollView: scrollView) }
        mainState.unwind {
            self.mainState = RVWatchGroupListState(scrollView: self.dsScrollView, stack: [RVBaseModel]())
        }
   //     if let scrollView = self.dsScrollView { mainState = RVWatchGroupListState(scrollView: scrollView) }
        super.viewDidLoad()
        if let tableView = self.tableView {
            tableView.register(RVFirstViewHeaderCell.self, forHeaderFooterViewReuseIdentifier: RVFirstViewHeaderCell.identifier)
        }
        RVViewDeck.sharedInstance.toggleSide(side: .right, animated: true)
    }

    override func installTopView() {
        if let topView = self.topView {
            if let segmentedControl = self.segmentedControl {
                self.topView.isHidden = false
                self.tableView.isUserInteractionEnabled = false
                var index = 0
                segmentedControl.removeAllSegments()
                if mainState.segmentViewFields.count > 0 {
                    print("In \(self.classForCoder).setupTopView")
                    for segment in mainState.segmentViewFields {
                        segmentedControl.insertSegment(withTitle: segment.segmentLabel, at: index, animated: true)
                        index = index + 1
                    }
                    let state = mainState.state
                    for index in (0..<mainState.segmentViewFields.count) {
                        if state == mainState.segmentViewFields[index] {
                            segmentedControl.selectedSegmentIndex = index
                            break
                        }
                    }

                    if mainState.state == .WatchGroupInfo {
                        self.tableView.isUserInteractionEnabled = false
                    } else {
                        self.tableView.isUserInteractionEnabled = true
                    }
                    
                } else {
                    
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
        print("In \(self.classForCoder).loadup")
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
        if let group = manager.item(indexPath: indexPath) as? RVWatchGroup  {
            mainState.stack.append(group)
            setupWatchGroupInfo()
        } else {
            print("In \(self.classForCoder).didSelect row, no RVWatchGroup")
        }
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






