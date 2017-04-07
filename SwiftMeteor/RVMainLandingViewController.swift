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
    @IBAction func unwindFromLoginSceneToMainLanding(segue: UIStoryboardSegue) {
        //print("In \(self.classForCoder).unwindFromLoginScene")
        self.mainState = RVWatchGroupListState(stack: self.mainState.stack)
        //mainState.initialize(scrollView: dsScrollView)
    }
    @IBAction func unwindFromWatchGroupCreateEdit(seque: UIStoryboardSegue) {
        if let _ = seque.source as? RVWatchGroupCreateEditController {
        }
    }
    @IBAction func unwindFromProfileScene(segue: UIStoryboardSegue) {
        print("In \(self.classForCoder).unwindFromProfileScene.......should not get here")
    
    }
    @IBAction func unwindFromMessageCreateScene(segue: UIStoryboardSegue) {
        if let controller = segue.source as? RVMessageAuthorViewController {
            if let payload = controller.seguePayload {
                print("Have payload")
                if let menu = payload["Menu"] as? Bool {
                    if menu {RVViewDeck.sharedInstance.toggleSide(side: RVViewDeck.Side.left)}
                }
                controller.seguePayload = nil
            }
        } else {
            print("In unwind controller is \(segue.source)")
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       print("In \(self.classForCoder).viewDidAppear with state \(mainState) \(mainState.state)")
        if mainState.state == .LoggedOut {
            self.performSegue(withIdentifier: "SegueFromWatchGroupListToLoginScene", sender: nil)
        } else {
            mainState.initialize(scrollView: self.dsScrollView, callback: { (error) in
                if let error = error {
                    error.printError()
                }
            })
        }
      //
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
          //  print("In \(self.classForCoder).setUpWatchGroupMembers, after unwind \(self.manager.numberOfSections())")
            mainState.unwind {
                if let view = self.watchGroupInfoView {
                    view.removeFromSuperview()
                    self.watchGroupInfoView = nil
                }
                self.mainState = RVWatchGroupMembersState(stack: self.mainState.stack)
                self.install()
               // self.setupTopView()
                self.mainState.initialize(scrollView: self.dsScrollView, callback: { (error) in
                    if let error = error {
                        error.printError()
                    }
                })
                
            }
        
    }
    func setupWatchGroupMessages() {
        mainState.unwind {
           // print("In \(self.classForCoder).setUpWatchGroupMessage, after unwind \(self.manager.numberOfSections())")
            if let view = self.watchGroupInfoView {
               view.removeFromSuperview()
                self.watchGroupInfoView = nil
            }
            self.mainState.unwind {
                self.mainState = RVMessageListState(stack: self.mainState.stack)
                //self.mainState = RVWatchGroupForumState(scrollView: self.dsScrollView, stack: self.mainState.stack)
                print("In \(self.classForCoder).setupWatchGroupMessage. just installed RVMessageListState")
                self.install()
               // self.setupTopView()
                self.mainState.initialize(scrollView: self.dsScrollView, callback: { (error) in
                    if let error = error {
                        error.printError()
                    }
                })
            }

        }
    }
    func setupWatchGroupInfo(){
        mainState.unwind {
            self.mainState = RVWatchGroupInfoState(stack: self.mainState.stack)
//
            print("In \(self.classForCoder).setupWatchGroupInfo()")
            self.install()
            //self.setupTopView()
            if self.watchGroupInfoView == nil {
                if let overlayView = self.OverlayView {
                    if let view = RVWatchGroupView.loadFromNib(frame: overlayView.bounds) {
                        self.watchGroupInfoView = view
                        view.state = self.mainState
                        overlayView.addSubview(view)
                    }
                    self.mainState.initialize(scrollView: self.dsScrollView, callback: { (error) in
                        if let error = error {
                            error.printError()
                        }
                    })
                    return
                }
            }
            self.mainState.initialize(scrollView: self.dsScrollView, callback: { (error) in
                if let error = error {
                    error.printError()
                }
            })
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
    
    @IBAction func doneButtonTouched(_ sender: UIBarButtonItem) {
        if mainState.state == .WatchGroupMessages {
            if let controller = self.presentedViewController as? RVMessageAuthorViewController {
                controller.performSegue(withIdentifier: RVMessageAuthorViewController.unwindFromMessageCreateSceneWithSegue, sender: ["Menu": true])
            } else {
                print("No controller \(self.presentedViewController?.description ?? " no presentedViewController")")
            }
        } else {
            RVViewDeck.sharedInstance.toggleSide(side: RVViewDeck.Side.left)
        }

    }
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
        if mainState.state == .WatchGroupMessages || mainState.state == .MessageListState {
            performSegue(withIdentifier: "SegueFromMainToMessageCreate", sender: nil)
        } else {
            presentWatchGroupCreateEdit(watchGroup: nil)
        }
    }
    override func viewDidLoad() {
        print("In \(self.classForCoder).viewDidLoad")
        // mainState.unwind { self.mainState = RVWatchGroupListState(stack: [RVBaseModel]()) }
        super.viewDidLoad()
        if let tableView = self.tableView { tableView.register(RVFirstViewHeaderCell.self, forHeaderFooterViewReuseIdentifier: RVFirstViewHeaderCell.identifier) }
    

        // RVViewDeck.sharedInstance.toggleSide(side: .right, animated: true)
    }

    override func installTopView() {
        if let topView = self.topView {
            if let segmentedControl = self.segmentedControl {
                self.topView.isHidden = false
                self.tableView.isUserInteractionEnabled = false
                var index = 0
                segmentedControl.removeAllSegments()
                if mainState.segmentViewFields.count > 0 {
                   // print("In \(self.classForCoder).setupTopView")
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
        //print("In \(self.classForCoder).loadup")
        if RVAppState.shared.state == RVAppState.State.ShowProfile {
            performSegue(withIdentifier: SegueFromMainToProfileScene, sender: nil)
            let storyboard = UIStoryboard(name: RVCoreInfo.sharedInstance.mainStoryboard, bundle: nil)
            if let viewController = storyboard.instantiateViewController(withIdentifier: "ProfileNavController") as? UINavigationController {
                self.present(viewController, animated: true, completion: { })
            }
        } else {
            mainState.initialize(scrollView: self.dsScrollView, callback: { (error) in
                if let error = error {
                    error.printError()
                }
            })
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
            let query = RVQuery()
            query.addAnd(term: .ownerId, value: userProfile!.localId as AnyObject, comparison: .eq)
            query.addAnd(term: .followedId, value: group.localId as AnyObject, comparison: .eq)
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
        //print("In \(self.classForCoder).cellForRowAt: \(indexPath.row), mainState is \(mainState)")
        if let _ = mainState as? RVWatchGroupListState {
            if let cell = tableView.dequeueReusableCell(withIdentifier: RVWatchGroupTableCell.identifier, for: indexPath) as? RVWatchGroupTableCell {
                cell.model = manager.item(indexPath: indexPath)
                return cell
            }
        } else if let _ = mainState as? RVMessageListState {
            if let cell = tableView.dequeueReusableCell(withIdentifier: RVMessageTableCell.identifier, for: indexPath) as? RVMessageTableCell {
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






