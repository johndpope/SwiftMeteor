//
//  SecondViewController.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 11/27/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import UIKit

class SecondViewController: FirstViewController {
    var filteredResults = [RVBaseModel]()
    enum SearchScope: String {
        case all = "All"
        case somethingElse = "Else"
    }
    let scopeTitles2 = [SearchScope.all.rawValue, SearchScope.somethingElse.rawValue]
    let searchController = UISearchController(searchResultsController: nil)
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false // set true when using another controller for searchResultsController
        definesPresentationContext = true // ensures that the search bar does not remain on the screen if the user navigates to another view controller while the UISearch Controller is active
        searchController.searchBar.scopeButtonTitles = scopeTitles2
        searchController.searchBar.delegate = self
        tableView.tableHeaderView = searchController.searchBar
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(RVFirstViewTableCell.self, forCellReuseIdentifier: "first")
        setupSearchController()
    }

    func filterContentForSearchText(searchText: String, scope: SearchScope = .all ) {
        self.filteredResults = [RVBaseModel]()
        tableView.reloadData()
    }
    override func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        var text = (searchController.searchBar.text != nil) ? searchController.searchBar.text! : ""
        text = text.lowercased()
        filterContentForSearchText(searchText: text, scope: getScope())
    }
    func getScope() -> SearchScope {
        let searchBar = searchController.searchBar
        let selectedScope = searchBar.selectedScopeButtonIndex
        var scope = SearchScope.all
        if selectedScope == 0 {
            scope = SearchScope.all
        }
        return scope
    }
}

extension SecondViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        var text = (searchController.searchBar.text != nil) ? searchController.searchBar.text! : ""
        text = text.lowercased()
        filterContentForSearchText(searchText: text, scope: .all)

    }
}
