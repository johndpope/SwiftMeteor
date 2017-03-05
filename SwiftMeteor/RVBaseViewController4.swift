//
//  RVBaseViewController4.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/4/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
class RVBaseViewController4: UIViewController {
    var instanceType: String { get { return String(describing: type(of: self)) }}
    var manager: RVDSManager = RVDSManager()
    let searchController = UISearchController(searchResultsController: nil)
    var searchScopes: [String] { get {return ["Elmer", "Fudd"]}}
    var installSearchController: Bool { get { return true }}
    var dsScrollView: UIScrollView? { get { return tableView }}
    var searchBarPlaceholder: String { get { return "Search..." }}
    @IBOutlet weak var tableView: UITableView!

    override func viewWillAppear(_ animated: Bool) {
        manager = RVDSManager(scrollView: dsScrollView)
        configureSearchController()
        super.viewWillAppear(animated)
    }
}

extension RVBaseViewController4: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return manager.numberOfSections(scrollView: tableView)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return manager.numberOfItems(section: section)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
extension RVBaseViewController4: UISearchResultsUpdating {
    
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchBar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        searchController.searchBar.barTintColor = UIColor.blue
        searchController.dimsBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        if let tableView = self.dsScrollView as? UITableView {
            if installSearchController {  tableView.tableHeaderView = searchController.searchBar}
            else if let _ = tableView.tableHeaderView as? UISearchBar { tableView.tableHeaderView = nil}
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
extension RVBaseViewController4: UISearchControllerDelegate {
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
extension RVBaseViewController4: UISearchBarDelegate {
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
