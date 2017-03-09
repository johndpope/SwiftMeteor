//
//  RVBaseSLKViewController.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/8/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
import SlackTextViewController

class RVBaseSLKViewController: SLKTextViewController {
    @IBOutlet weak var searchControllerContainerView: UIView!
    @IBOutlet weak var TopOuterView: UIView!
    @IBOutlet weak var TopTopView: UIView!
    @IBOutlet weak var TopMiddleView: UIView!
    @IBOutlet weak var TopBottomView: UIView!
    @IBOutlet weak var TopTopHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var TopMiddleHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var TopBottomHeightConstraint: NSLayoutConstraint!
    
    let searchController = UISearchController(searchResultsController: nil)
    var searchScopes: [String] { get {return ["Elmer", "Fudd"]}}
    var installSearchControllerInTableView: Bool { get { return false }}
    var searchBarPlaceholder: String { get { return "Search..." }}
    
    var dsScrollView: UIScrollView? {return tableView }
    var instanceType: String { get { return String(describing: type(of: self)) } }
    var deck: RVViewDeck { get { return RVViewDeck.sharedInstance }}
    @IBAction func searchButtonTouched(_ sender: UIBarButtonItem) {
        searchController.isActive = true
    }
    @IBAction func menuButtonTouched(_ sender: UIBarButtonItem) {
        self.deck.toggleSide(side: .left)
    }
    var totalTopHeight: CGFloat {
        get {
            var height: CGFloat = 0.0
            height = (TopTopHeightConstraint != nil) ? TopTopHeightConstraint.constant + height : height
            height = (TopMiddleHeightConstraint != nil) ? TopMiddleHeightConstraint.constant + height : height
            height = (TopBottomHeightConstraint != nil) ? TopBottomHeightConstraint.constant + height : height
            return height
        }
    }
    func changeConstraintConstant(constraint: NSLayoutConstraint?, newValue: CGFloat) {
        if let constraint = constraint { constraint.constant = newValue }
    }
    func hideTopView() {
        if let view = TopOuterView { view.isHidden = true }
    }
    func putTopViewOnTop() {
        if let outerView = TopOuterView {
            self.view.bringSubview(toFront: outerView)
            outerView.isHidden = false
        }
    }
    override func viewDidLoad() {
        putTopViewOnTop()
        configureSearchController()
        super.viewDidLoad()
    }

    
}
extension RVBaseSLKViewController: UISearchResultsUpdating {
    
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchBar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        searchController.searchBar.barTintColor = UIColor.blue
        searchController.dimsBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        searchController.searchBar.removeFromSuperview()
        if installSearchControllerInTableView {
            if let tableView = self.dsScrollView as? UITableView {
                tableView.tableHeaderView = searchController.searchBar
            }
        } else {
            searchControllerContainerView.addSubview(searchController.searchBar)
        }
    }
    func configureScopeBar() {
        searchController.searchBar.scopeButtonTitles = self.searchScopes
        searchController.searchBar.selectedScopeButtonIndex = 0
        searchController.searchBar.showsSearchResultsButton = false
        searchController.searchBar.placeholder = self.searchBarPlaceholder
    }
    // Called when the search bar's text or scope has changed or when the search bar becomes first responder.
    public func updateSearchResults(for searchController: UISearchController) {
        print("In \(instanceType).updateSearchResults, active: \(searchController.isActive)")
    }
}
extension RVBaseSLKViewController: UISearchControllerDelegate {
    // These methods are called when automatic presentation or dismissal occurs. They will not be called if you present or dismiss the search controller yourself.
    func willPresentSearchController(_ searchController: UISearchController) {
        configureScopeBar()
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {}
    
    func willDismissSearchController(_ searchController: UISearchController) {}
    
    func didDismissSearchController(_ searchController: UISearchController) {}
    
    // Called after the search controller's search bar has agreed to begin editing or when 'active' is set to YES. If you choose not to present the controller yourself or do not implement this method, a default presentation is performed on your behalf.
    func presentSearchController(_ searchController: UISearchController) {}
}
extension RVBaseSLKViewController: UISearchBarDelegate {
    // func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool ( return true) // return NO to not become first responder
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {}// called when text starts editing
    
    //func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool { return true }// return NO to not resign first responder
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {}// called when text ends editing
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {}// called when text changes (including clear)
    
    // func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {return true}// called before text changes
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {}// called  when keyboard search button pressed
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {}// called when bookmark button pressed
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {} // called when cancel button pressed
    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {} // called when search results button pressed
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        print("In \(instanceType).seelectedScopeButtonIndexDidChange \(selectedScope)")
        searchBar.text = ""
    }
}
