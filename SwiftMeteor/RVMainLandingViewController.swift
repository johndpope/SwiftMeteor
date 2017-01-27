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

    @IBOutlet weak var segmentedControl: UISegmentedControl!


    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        p("segmentedControlValueChanged", "to index: \(sender.selectedSegmentIndex)")
    }
    
    @IBAction func doneButtonTouched(_ sender: UIBarButtonItem) {
       RVViewDeck.sharedInstance.toggleSide(side: RVViewDeck.Side.left)
    }
    @IBAction func searchButtonTouched(_ sender: UIBarButtonItem) {
        p("searchBarButtonTouche ---------------------------d")
               RVViewDeck.sharedInstance.toggleSide(side: RVViewDeck.Side.right)
    }
    override func viewDidLoad() {
        if let scrollView = self.dsScrollView {
            self.mainState = RVMainViewControllerState.tasksState(scrollView: scrollView)
        } else {
            print("In \(self.classForCoder).viewDidLoad, no scrollView")
        }
        super.viewDidLoad()
        if let tableView = self.tableView {
            tableView.register(RVFirstViewHeaderCell.self, forHeaderFooterViewReuseIdentifier: RVFirstViewHeaderCell.identifier)
        }
        RVViewDeck.sharedInstance.toggleSide(side: .right, animated: true)
    }
    override func setupTopView() {
        if let _ = self.topView {
            if let segmentedControl = self.segmentedControl {
                var index = 0
                segmentedControl.removeAllSegments()
                for segment in [["Elmer": RVKeys.handle], ["Goober": RVKeys.title]  , ["Something": RVKeys.comment]] {
                   // print("In \(self.classForCoder).setupTopView, \(segment.first!.key)")
                    segmentedControl.insertSegment(withTitle: segment.first!.key, at: index, animated: true)
                    index = index + 1
                }
                segmentedControl.selectedSegmentIndex = 0
            }
        }

    }


    func loadup() {
        if RVAppState.shared.state == RVAppState.State.ShowProfile {
           // print("In \(self.classForCoder).loadup, have ShowProfile state")
            let storyboard = UIStoryboard(name: RVCoreInfo.sharedInstance.mainStoryboard, bundle: nil)
                if let viewController = storyboard.instantiateViewController(withIdentifier: "ProfileNavController") as? UINavigationController {
                    self.present(viewController, animated: true, completion: {
                        //print("In \(self.instanceType).loadUp returned from presenting ProfileNavController")
                    })
                }
            
        } else {
            RVSeed.createRootTask { (root, error) in
                if let error = error {
                    error.printError()
                    return
                } else if let root = root {
                        self.mainState.stack = [root]
                        if let mainDatasource = self.mainState.findDatasource(type: RVBaseDataSource.DatasourceType.main) {
                            if let queryFunction = self.mainState.queryFunctions[RVBaseDataSource.DatasourceType.main] {
                                let query = queryFunction([String: AnyObject]())
                                    let manager = self.manager
                                    manager.stopAndResetDatasource(datasource: mainDatasource, callback: { (error) in
                                        if let error = error {
                                            error.append(message: "In \(self.instanceType).loadUp, got error stoping main database")
                                            error.printError()
                                        } else {
                                            manager.startDatasource(datasource: mainDatasource, query: query, callback: { (error) in
                                                if let error = error {
                                                    error.append(message: "In \(self.instanceType).loadUp, got error starting main database")
                                                    error.printError()
                                                }
                                            })
                                        }
                                    })

                            } else {
                                print("In \(self.classForCoder).loadup, no queryFunction")
                            }
                        } else {
                            print("In \(self.classForCoder).loadup, no mainDatasource")
                        }


                } else {
                    print("In \(self.instanceType).loadup no root")
                }
            }
        }

    }
}






