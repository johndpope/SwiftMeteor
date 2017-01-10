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
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentView: UIView!
    @IBOutlet weak var segmentedView: UIView!
    @IBOutlet weak var segmentedViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    let topConstraintDelta: CGFloat = 30.0
    var segmentedViewTopConstraintConstant:CGFloat = 0.0
    var tableViewTopConstraintConstant: CGFloat = 0.0
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
    }
    
    @IBAction func doneButtonTouched(_ sender: UIBarButtonItem) {
        RVViewDeck.sharedInstance.toggleSide(side: RVViewDeck.Side.left)
    }
    @IBAction func searchButtonTouched(_ sender: UIBarButtonItem) {
        showSearchBar()
        segmentedView.isHidden = false
    }
    override func viewDidLoad() {
        self.dsScrollView = tableView
        mainDatasource = RVTaskDatasource()
        filterDatasource = RVTaskDatasource()
        super.viewDidLoad()
        tableView.register(RVFirstViewHeaderCell.self, forHeaderFooterViewReuseIdentifier: RVFirstViewHeaderCell.identifier)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let _ = RVSwiftDDP.sharedInstance.username {
            // do nothing for now
             print("In \(self.classForCoder).viewWillAppear, username not found")
        } else {
            print("In \(self.classForCoder).viewWillAppear, no username")
            //loadup()
        }
    }
    func loadup() {
        RVSeed.createRootTask { (root, error) in
            if let error = error {
                error.printError()
                return
            } else if let root = root {
              //  print("In \(self.instanceType).loadup() Have root task: \(root._id), \(root.special.rawValue)")
                self.stack = [root]
                let query = self.mainDatasource.basicQuery()
                if let top = self.stack.last {
                    query.addAnd(term: RVKeys.parentId, value: top._id as AnyObject, comparison: .eq)
                    query.addAnd(term: RVKeys.parentModelType, value: top.modelType.rawValue as AnyObject, comparison: .eq )
                }
                self.manager.startDatasource(datasource: self.mainDatasource, query: query, callback: { (error) in
                    if let error = error {
                        error.append(message: "In \(self.instanceType).loadUp, got error starting main database")
                        error.printError()
                    }
                })
            } else {
                print("In \(self.instanceType).loadup no root")
            }
        }
    }
    func userDidLogin() {
        print("The user just signed in!")
    }
    override func filterQuery(text: String ) -> RVQuery {
        let query = filterDatasource.basicQuery().duplicate()
        query.addAnd(term: RVKeys.handleLowercase, value: text.lowercased() as AnyObject, comparison: .regex)
        // query.fixedTerm = RVQueryItem(term: RVKeys.handleLowercase, value: text.lowercased() as AnyObject, comparison: .gte) // necessary for keeping filter equal or gt filter term
        if let top = self.stack.last {
            query.addAnd(term: RVKeys.parentId, value: top._id as AnyObject, comparison: .eq)
            query.addAnd(term: RVKeys.parentModelType, value: top.modelType.rawValue as AnyObject, comparison: .eq )
        }
        query.removeAllSortTerms()
        query.addSort(field: .handleLowercase, order: .ascending)
        return query
    }
    func filterQuery0(text: String ) -> RVQuery {
        let query = filterDatasource.basicQuery().duplicate()
        query.setTextSearch(value: text.lowercased())
        if let top = self.stack.last {
            query.addAnd(term: RVKeys.parentId, value: top._id as AnyObject, comparison: .eq)
            query.addAnd(term: RVKeys.parentModelType, value: top.modelType.rawValue as AnyObject, comparison: .eq )
        }
        query.removeAllSortTerms()
        query.limit = 100
      //  query.addSort(field: .handleLowercase, order: .ascending)
        return query
    }
    override func userDidLogin(notification: NSNotification) {
        print("In \(self.instanceType).userDidLogin notification target")
        loadup()
    }
}

extension RVMainLandingViewController {
    override func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        super.searchBarCancelButtonClicked(searchBar)
        segmentedView.isHidden = true
    }

}




