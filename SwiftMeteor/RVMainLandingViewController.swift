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
    var scopes: [[String: RVKeys]] = [["Handle": RVKeys.handle], ["Title": RVKeys.title]  , ["Comment": RVKeys.comment]]

    let topConstraintDelta: CGFloat = 30.0
    var segmentedViewTopConstraintConstant:CGFloat = 0.0
    var tableViewTopConstraintConstant: CGFloat = 0.0
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        self.searchBar.text = ""
        manager.stopAndResetDatasource(datasource: filterDatasource) { (error) in
            if let error = error {
                error.printError()
            } else {
                let searchText =  self.searchBar.text != nil ? self.searchBar.text! : ""
                self.runSearch(searchText: searchText)
            }
        }
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
        segmentedControl.removeAllSegments()
        var index = 0
        for segment in scopes {
            print("\(segment.first!.key)")
            segmentedControl.insertSegment(withTitle: segment.first!.key, at: index, animated: true)
            index = index + 1
        }
        segmentedControl.selectedSegmentIndex = 0
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
        if let segmentedView = self.segmentedView {
            segmentedView.isHidden = false
            if let constraint = tableViewTopConstraint {
                tableViewTopConstraintConstant = constraint.constant
                constraint.constant = constraint.constant + topConstraintDelta
            }
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
        query.removeAllSortTerms()
        if let top = self.stack.last {
            query.addAnd(term: RVKeys.parentId, value: top._id as AnyObject, comparison: .eq)
            query.addAnd(term: RVKeys.parentModelType, value: top.modelType.rawValue as AnyObject, comparison: .eq )
        }
        let scopeIndex = segmentedControl.selectedSegmentIndex
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
                } else if field == .comment || field == .lowerCaseComment {
                 //   query.addAnd(term: RVKeys.comment, value: text.lowercased() as AnyObject, comparison: .gte)
                    query.fixedTerm = RVQueryItem(term: RVKeys.comment, value: text.lowercased() as AnyObject, comparison: .regex) // necessary for keeping filter equal or gt filter term
                    query.addSort(field: .comment, order: .ascending)
                }
            }
        }
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




