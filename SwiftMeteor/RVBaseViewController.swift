//
//  RVBaseViewController.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 11/27/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import UIKit

class RVBaseViewController: UIViewController {
    var instanceType: String { get { return String(describing: type(of: self)) } }
    var stack = [RVBaseModel]()
    func p(_ message: String, _ method: String = "") {
        print("In \(instanceType) \(method) \(message)")
    }
    weak var dsScrollView: UIScrollView?
    var manager: RVDSManager!
    var mainDatasource: RVBaseDataSource = RVBaseDataSource()
    var filterDatasource: RVBaseDataSource = RVBaseDataSource()
    override func viewDidLoad() {
        super.viewDidLoad()

        configureSearchBar()
        if let scrollView = self.dsScrollView {
            self.manager = RVDSManager(scrollView: scrollView)
        } else {
            print("In \(instanceType).viewDidLoad, scrollView not set")
        }
        manager.addSection(section: mainDatasource)
        manager.addSection(section: filterDatasource)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.installObservers()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.uninstallObservers()
    }
    deinit {
        self.uninstallObservers()
    }

    // searchBar
    var leftBarButtonItems: [UIBarButtonItem]? =  nil
    var rightBarButtonItems: [UIBarButtonItem]? = nil
    var navigationItemTitleView: UIView? = nil
    var searchBar = UISearchBar()
    let backspace = String(describing: UnicodeScalar(8))
    let tab = "\t"
    let sparklingHeart = "\u{1F496}"
    var searchBarScopeTitles: [String] = ["Scope0", "Scope1"]
    func filterQuery(text: String ) -> RVQuery {
        let query = mainDatasource.basicQuery().duplicate()
        print("In \(self.instanceType).filterQuery base class. Need to override")
        query.addAnd(term: RVKeys.lowerCaseComment, value: text.lowercased() as AnyObject, comparison: .gte)
        query.removeAllSortTerms()
        query.addSort(field: .lowerCaseComment, order: .ascending)
        return query
    }
    var observers: [NSNotification.Name : Selector] =  [
        NSNotification.Name(rawValue: RVNotification.userDidLogin.rawValue)  : #selector(RVBaseViewController.userDidLogin),
        NSNotification.Name(rawValue: RVNotification.userDidLogout.rawValue) : #selector(RVBaseViewController.userDidLogout)
    ]
    func installObservers() {
        for (name, selector) in observers {
            NotificationCenter.default.addObserver(self, selector:  selector, name: name, object: nil)
        }
    }
    func uninstallObservers() {
        for (name, _) in observers {
            NotificationCenter.default.removeObserver(self, name: name, object: nil)
        }
    }
}
extension RVBaseViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("In \(instanceType).didSelectRowAt, not overridded")
    }
}
extension RVBaseViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return manager.numberOfSections()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("In \(instanceType).cellForRowAt, baseClass RVBaseViewController. Needs to be overridden")
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return manager.numberOfItems(section: section)
    }
    func userDidLogin(notification: NSNotification) {
        print("In \(self.instanceType).userDidLogin notification target")
        if let userInfo = notification.userInfo {
            if let username = userInfo["user"] as? String {
                print("Username is \(username)")
            }
        }
    }
    func userDidLogout(notification: NSNotification) {
        print("In \(self.instanceType).userDidLogout notification target")        
    }

}


extension RVBaseViewController: UISearchBarDelegate {
    func showSearchBar() {
        self.leftBarButtonItems = navigationItem.leftBarButtonItems
        self.rightBarButtonItems = navigationItem.rightBarButtonItems
        navigationItem.setLeftBarButtonItems(nil, animated: true)
        navigationItem.setRightBarButtonItems(nil, animated: true)
        self.navigationItemTitleView = navigationItem.titleView
        navigationItem.titleView = self.searchBar
        navigationItem.titleView?.sizeToFit()
    }
    func removeSearchBar() {
        navigationItem.titleView = self.navigationItemTitleView
        navigationItem.setLeftBarButtonItems(self.leftBarButtonItems, animated: true)
        navigationItem.setRightBarButtonItems(self.rightBarButtonItems, animated: true)
    }
    func configureSearchBar() {
        searchBar.prompt = "Prompt"
        searchBar.isTranslucent = false
        searchBar.searchBarStyle = UISearchBarStyle.prominent
    //    searchBar.showsSearchResultsButton = true
        searchBar.placeholder = " Search..."
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        searchBar.showsCancelButton = true
    
    //    searchBar.sizeToFit()
        UISearchBar.appearance().barTintColor = UIColor.candyGreen()
        UISearchBar.appearance().tintColor = UIColor.blue
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = UIColor.candyGreen()
        //navigationItem.titleView = searchBar
    
    }
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.characters.count == 0 {
            if let char = text.cString(using: String.Encoding.utf8) {
                let isBackSpace = strcmp(char, "\\b")
                if (isBackSpace == -92 ) {
                    print("In searchBar shouldChangeTextIn Range text is a backspace")
                }
            }
        } else {
            print("In searchBar shouldChangeTextIn Range text is: [\(text)], count is \(text.characters.count)")
        }
        return true
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        p("", "textDidChange")
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        removeSearchBar()
        p("", "searchBarCancelButtonClicked")
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        p("", "searchBarTextDidEndEditing")
        
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            if text.characters.count >= 2 {
                if !mainDatasource.collapsed {
                    mainDatasource.collapse {
                        print("In \(self.instanceType).searchBarSearchButtonClicked")
                    }
                }
                let query = filterQuery(text: text)
                manager.startDatasource(datasource: filterDatasource, query: query, callback: { (error) in
                    if let error = error {
                        error.printError()
                    }
                })
                
                
            }
        }
        p("", "searchBarSearchButtonClicked")
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //searchBar.showsCancelButton = true
        p("", "searchBarTextDidBeginEditing")
        
    }
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        p("", "searchBarBookmarkButtonClicked")
        
    }
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
        p("", "searchBarResultsListButtonClicked")
    }
}
