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
    override func provideMainDatasource() -> RVBaseDataSource{ return RVTaskDatasource() }
    override func provideFilteredDatasource() -> RVBaseDataSource { return RVTaskDatasource(maxArraySize: 500, filterMode: true) }

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
                    //  print("In \(self.instanceType).loadup() Have root task: \(root._id), \(root.special.rawValue)")
                    self.stack = [root]
                    let query = self.mainDatasource.basicQuery()
                    if let top = self.stack.last {
                        query.addAnd(term: RVKeys.parentId, value: top.localId as AnyObject, comparison: .eq)
                        query.addAnd(term: RVKeys.parentModelType, value: top.modelType.rawValue as AnyObject, comparison: .eq )
                    }
                    if let manager = self.manager {
                        manager.stopAndResetDatasource(datasource: self.mainDatasource, callback: { (error) in
                            if let error = error {
                                error.printError()
                            } else {
                                manager.startDatasource(datasource: self.mainDatasource, query: query, callback: { (error) in
                                    if let error = error {
                                        error.append(message: "In \(self.instanceType).loadUp, got error starting main database")
                                        error.printError()
                                    }
                                })
                            }
                        })
                        
                    }
                } else {
                    print("In \(self.instanceType).loadup no root")
                }
            }
        }

    }

    override func filterQuery(text: String, scopeIndex: Int ) -> RVQuery {
        let query = filterDatasource.basicQuery().duplicate()
        query.removeAllSortTerms()
        if let top = self.stack.last {
            query.addAnd(term: RVKeys.parentId, value: top.localId as AnyObject, comparison: .eq)
            query.addAnd(term: RVKeys.parentModelType, value: top.modelType.rawValue as AnyObject, comparison: .eq )
        }
        //let scopeIndex = segmentedControl.selectedSegmentIndex
        if scopeIndex >= 0 && scopeIndex < scopes.count {
            if let (_, field) = scopes[scopeIndex].first {
               // print("In \(self.classForCoder).filterQuery, scope is \(field.rawValue)")
                if field == .handle || field == .handleLowercase {
                   // query.addAnd(term: RVKeys.handle, value: text.lowercased() as AnyObject, comparison: .gte)
                    query.fixedTerm = RVQueryItem(term: RVKeys.handle, value: text.lowercased() as AnyObject, comparison: .regex) // necessary for keeping filter equal or gt filter term
                    query.addSort(field: .handle, order: .ascending)
                } else if field == .title {
                 //   query.addAnd(term: RVKeys.title, value: text.lowercased() as AnyObject, comparison: .gte)
                    query.fixedTerm = RVQueryItem(term: RVKeys.title, value: text.lowercased() as AnyObject, comparison: .regex) // necessary for keeping filter equal or gt filter term
                    query.addSort(field: .title, order: .ascending)
                } else if field == .comment || field == .commentLowercase {
                 //   query.addAnd(term: RVKeys.comment, value: text.lowercased() as AnyObject, comparison: .gte)
                    query.fixedTerm = RVQueryItem(term: RVKeys.comment, value: text.lowercased() as AnyObject, comparison: .regex) // necessary for keeping filter equal or gt filter term
                    query.addSort(field: .comment, order: .ascending)
                }
            }
        } else {
            query.fixedTerm = RVQueryItem(term: RVKeys.handle, value: text.lowercased() as AnyObject, comparison: .regex) // necessary for keeping filter equal or gt filter term
            query.addSort(field: .handle, order: .ascending)
        }
        return query
    }
}






