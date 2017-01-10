//
//  RVBaseViewController.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 11/27/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import UIKit

extension RVBaseViewController: UISearchResultsUpdating {
    // Called when the search bar's text or scope has changed or when the search bar becomes first responder.
    public func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text != nil ?  searchController.searchBar.text! : ""
        var operation = self.operation
        if operation.active {
            operation.cancelled = true
            self.operation = RVOperation(active: true, name: searchText)
            operation = self.operation
            self.runInner2(operation: operation, searchText: searchText)
        } else {
            if operation.cancelled {
                operation = RVOperation(active: true, name: searchText)
                self.operation = operation
            }
            operation.name = searchText
            operation.active = true
            self.runInner2(operation: operation, searchText: searchText)
        }
    }
    func runInner2(operation: RVOperation, searchText: String) {
        DispatchQueue.main.async {
            self.manager.stopAndResetDatasource(datasource: self.filterDatasource, callback: { (error) in
                if let error = error {
                    error.append(message: "In \(self.instanceType).runSearch, got error stopping")
                } else {
                    // self.p("After stopAndReset \(operation.name)")
                    let query = self.filterQuery(text: searchText)
                    if operation.sameOperationAndNotCancelled(operation: self.operation) {
                        if !self.mainDatasource.collapsed { self.mainDatasource.collapse {} }
                        self.manager.startDatasource(datasource: self.filterDatasource, query: query, callback: { (error) in
                            //self.p("After startDatasource \(operation.name)")
                            if let error = error {
                                error.append(message: "In \(self.instanceType).textDidChange, got error")
                                error.printError()
                            }
                            if operation.sameOperation(operation: self.operation) {
                                operation.cancelled = true
                                self.operation = RVOperation(active: false)
                                operation.active = false
                            }
                        })
                    } else {
                        self.p("Same operation and not cancelled \(operation.name) --------")
                    }
                }
            })
        }
    }
}
class RVBaseViewController: UIViewController {
    let searchController = UISearchController(searchResultsController: nil)
    var instanceType: String { get { return String(describing: type(of: self)) } }
    var stack = [RVBaseModel]()
    var operation: RVOperation = RVOperation(active: false)
    func p(_ message: String, _ method: String = "") {
        print("In \(instanceType) \(method) \(message)")
    }
    weak var dsScrollView: UIScrollView?
    var refreshControl = UIRefreshControl()
    var manager: RVDSManager!
    var mainDatasource: RVBaseDataSource = RVBaseDataSource()
    var filterDatasource: RVBaseDataSource = RVBaseDataSource()
    override func viewDidLoad() {
        super.viewDidLoad()

  //      configureSearchBar()
        if let scrollView = self.dsScrollView {
            self.manager = RVDSManager(scrollView: scrollView)
            if let tableView = scrollView as? UITableView {
                searchController.searchResultsUpdater = self
                searchController.dimsBackgroundDuringPresentation = false
                definesPresentationContext = true
                tableView.tableHeaderView = searchController.searchBar
            }
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
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerCell = view as? RVFirstViewHeaderCell {
            if section >= 0 && section < manager.sections.count {
                let datasource = manager.sections[section]
                headerCell.delegate = self
                headerCell.configure(model: nil, expand: true, datasource: datasource)
            }
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: RVFirstViewHeaderCell.identifier) as? RVFirstViewHeaderCell {
            return headerCell
        } else {
            return UIView()
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
}
extension RVBaseViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        //  print("In \(self.classForCoder).numberOfSections... \(manager.sections.count)")
        let count = manager.sections.count
        if count == 0 {
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
            messageLabel.text = "No data is currently available. Please pull down to refresh."
            messageLabel.textColor = UIColor.black
            messageLabel.textAlignment = NSTextAlignment.center
            messageLabel.font = UIFont(name: "Palatino-Italic", size: 20)
            messageLabel.sizeToFit()
            tableView.backgroundView = messageLabel
            tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        } else {
            tableView.backgroundView = self.refreshControl
            tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLineEtched
        }
        return count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //    print("In \(self.instanceType).cellForRow...")
        if let cell = tableView.dequeueReusableCell(withIdentifier: RVTaskTableViewCell.identifier, for: indexPath) as? RVTaskTableViewCell {
            cell.model = manager.item(indexPath: indexPath)
            return cell
        } else {
            print("In \(self.instanceType).cellForRowAt, did not dequeue first cell type")
        }
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

    

    func installRefresh(tableView: UITableView) {
        self.refreshControl.backgroundColor = UIColor.purple
        self.refreshControl.tintColor = UIColor.white
        self.refreshControl.addTarget(self , action: #selector(refresh), for: UIControlEvents.valueChanged)
        tableView.backgroundView = self.refreshControl
        tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLineEtched
    }
    func refresh() {
        // self.tableView.reloadData
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        let title = "Last update: \(formatter.string(from: Date()))"
        let attrsDictionary = [NSForegroundColorAttributeName : UIColor.white]
        let attributedTitle = NSAttributedString(string: title, attributes: attrsDictionary)
        self.refreshControl.attributedTitle = attributedTitle
        if manager.sections.count > 0 {
            let datasource = manager.sections[0]
            datasource.loadFront()
        }
        self.refreshControl.endRefreshing()
    }
    
    
    
    
    
}

extension RVBaseViewController: RVFirstViewHeaderCellDelegate {
    func expandCollapseButtonTouched(view: RVFirstViewHeaderCell) -> Void {
       // print("In \(self.instanceType).expandCollapseButtonTOuched")
        if let datasource = view.datasource {
            //print("In \(self.instanceType).expandCollapseButtonTOuched have datasource")

                if !datasource.collapsed { datasource.collapse {
                    //print("In \(self.instanceType).expandCollapseButtonTouched return from collapse")
                    }
                } else {
                    datasource.expand {
                        //  print("In \(self.instanceType).expandCollapseButtonTouched return from expand")
                    }
                }
            
        } else {
            print("In \(self.instanceType).expandCollapseButtonTOuched no datasource")
        }
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
          //  print("In searchBar shouldChangeTextIn Range text is: [\(text)], count is \(text.characters.count)")
        }
        return true
    }
    func runInner(operation: RVOperation, searchText: String) {
        // p("runInner searchText = \(searchText)")
        DispatchQueue.main.async {
            self.manager.stopAndResetDatasource(datasource: self.filterDatasource, callback: { (error) in
                if let error = error {
                    error.append(message: "In \(self.instanceType).runSearch, got error stopping")
                } else {
                   // self.p("After stopAndReset \(operation.name)")
                    let query = self.filterQuery(text: searchText)
                    if operation.sameOperationAndNotCancelled(operation: self.operation) {
                        if !self.mainDatasource.collapsed { self.mainDatasource.collapse {} }
                        self.manager.startDatasource(datasource: self.filterDatasource, query: query, callback: { (error) in
                            //self.p("After startDatasource \(operation.name)")
                            if let error = error {
                                error.append(message: "In \(self.instanceType).textDidChange, got error")
                                error.printError()
                            }
                            if operation.sameOperation(operation: self.operation) {
                                operation.cancelled = true
                                self.operation = RVOperation(active: false)
                                operation.active = false
                            }
                        })
                    } else {
                        self.p("Same operation and not cancelled \(operation.name) --------")
                    }
                }
            })
        }
    }
    func runSearch(searchText: String) {
        if searchText.characters.count >= 0 {
            var operation = self.operation
            if operation.active {
                operation.cancelled = true
                self.operation = RVOperation(active: true, name: searchText)
                operation = self.operation
                self.runInner(operation: operation, searchText: searchText)
            } else {
                if operation.cancelled {
                    operation = RVOperation(active: true, name: searchText)
                    self.operation = operation
                }
                operation.name = searchText
                operation.active = true
                self.runInner(operation: operation, searchText: searchText)
            }
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        runSearch(searchText: searchText)
       // p("", "0 textDidChange")
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        removeSearchBar()
        manager.stopAndResetDatasource(datasource: filterDatasource) { (error ) in
            if let error = error {
                error.append(message: "searchBarCancelButtonClicked. stop filterDatasource, got error")
            }
        }
        if mainDatasource.collapsed {
            mainDatasource.expand {
                
            }
        }
        //p("", "searchBarCancelButtonClicked")
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
      //  p("", "5 searchBarTextDidEndEditing")
        
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        /*
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
 */
  //      p("", "4 searchBarSearchButtonClicked")
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {

    //   p("", "1 searchBarTextDidBeginEditing")
        
    }
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
      //  p("", "2 searchBarBookmarkButtonClicked")
        
    }
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {

        return true
    }
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
      //  p("", "3 searchBarResultsListButtonClicked")
    }
}
