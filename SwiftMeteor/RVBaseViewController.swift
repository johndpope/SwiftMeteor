//
//  RVBaseViewController.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 11/27/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import UIKit

class RVBaseViewController: UIViewController {
    let searchController = UISearchController(searchResultsController: nil)
   // var scopes: [[String: RVKeys]] = [["Handle": RVKeys.handle], ["Title": RVKeys.title]  , ["Comment": RVKeys.comment]]
    var titles = [String]()
    var instanceType: String { get { return String(describing: type(of: self)) } }
    var stack = [RVBaseModel]()
    var operation: RVOperation = RVOperation(active: false)
    var mainState: RVMainViewControllerState? = nil
    var dontUseManager: Bool = false
    var listeners = [RVListener]()
    func p(_ message: String, _ method: String = "") { print("In \(instanceType) \(method) \(message)") }
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    var topViewHeightConstraintConstant:CGFloat = 0.0
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    var dsScrollView: UIScrollView? {
        if let tableView = self.tableView {
            return tableView
        } else if let collectionView = self.collectionView {
            return collectionView
        }
        return nil
    }
    var refreshControl = UIRefreshControl()
    /*
    private var _manager: RVDSManager? = nil
    var manager: RVDSManager? {
        get {
            if dontUseManager { return nil}
            if let manager = self._manager { return manager }
            if let scrollView = self.dsScrollView {
                let manager = RVDSManager(scrollView: scrollView)
                _manager = manager
                return manager
            }
            return nil
        }
    }
 */
    /*
    private var _mainDatasource: RVBaseDataSource? = nil
    var mainDatasource: RVBaseDataSource {
        get {
            
            if let datasource = self._mainDatasource { return datasource }
            let datasource = provideMainDatasource()
            self._mainDatasource = datasource
            return datasource
        }
    }
    func provideMainDatasource() -> RVBaseDataSource {
        print("In \(instanceType). need to override provideMainDatasource()")
        return RVBaseDataSource()
    }
    var _filterDatasource: RVBaseDataSource? = nil
    var filterDatasource: RVBaseDataSource {
        get {
            if let datasource = self._filterDatasource { return datasource }
            let datasource = provideFilteredDatasource()
            self._filterDatasource = datasource
            return datasource
        }
    }
    func provideFilteredDatasource() -> RVBaseDataSource {
        print("In \(instanceType). need to override provideFilteredDatasource()")
        return RVBaseDataSource()
    }
 */
    override func viewDidLoad() {
        super.viewDidLoad()
    
    //    if let manager = self.manager {
            if let tableView = dsScrollView as? UITableView {
                searchController.searchResultsUpdater = self
                searchController.dimsBackgroundDuringPresentation = false
                self.titles = [String]()
                if let mainState = self.mainState {
                    for scopeTerm in mainState.scopes {
                        if let (title, _) = scopeTerm.first {
                            self.titles.append(title)
                        }
                    }
                }

                let searchBar = searchController.searchBar
                searchBar.scopeButtonTitles = titles
                searchBar.selectedScopeButtonIndex = 0
                searchBar.delegate = self
                
                searchBar.prompt = nil
               // searchBar.searchBarStyle = UISearchBarStyle.prominent
                searchBar.showsSearchResultsButton = false
                searchBar.placeholder = " Search..."
               // searchBar.isTranslucent = false
              //  searchBar.backgroundImage = UIImage()
               // searchBar.showsCancelButton = true
              //  UISearchBar.appearance().barTintColor = UIColor.orange
              //  UISearchBar.appearance().tintColor = UIColor.blue
              //  UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = UIColor.candyGreen()
                definesPresentationContext = true
                tableView.tableHeaderView = searchController.searchBar
     //           if let mainState = self.mainState {
     //               for section in mainState.datasources {
     //                   manager.addSection(section: section)
     //               }
     //           }
            //    manager.addSection(section: mainDatasource)
            //    manager.addSection(section: filterDatasource)
            }
     //   } else {
           // print("In \(instanceType).viewDidLoad, , manager not set")
     //   }
        if let topViewConstraint = self.topViewHeightConstraint {
            self.topViewHeightConstraintConstant = topViewConstraint.constant
        }
        setupTopView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // self.installObservers()
        showTopView()
       // addLogInOutListeners()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // addLogInOutListeners()
    }
    func addLogInOutListeners() {
        print("In \(self.classForCoder).addLogInOutListeners in RVBaseViewController need to override this method")
        var listener = RVSwiftDDP.sharedInstance.addListener(listener: self, eventType: .userDidLogin) { (_ info: [String: AnyObject]? ) -> Bool in
            print("In \(self.classForCoder).addLogInOutListeners, \(RVSwiftEvent.userDidLogin.rawValue) returned")
            return true
        }
        if let listener = listener { listeners.append(listener) }
        listener = RVSwiftDDP.sharedInstance.addListener(listener: self, eventType: .userDidLogout, callback: { (_ info: [String: AnyObject]? ) -> Bool in
            print("In \(self.classForCoder).addLogInOutListeners, \(RVSwiftEvent.userDidLogout.rawValue) returned")
            return true
        })
        if let listener = listener { listeners.append(listener) }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.uninstallObservers()
        self.removeLogInOutListeners()
    }
    func removeLogInOutListeners() {
        for listener in listeners {
            RVSwiftDDP.sharedInstance.removeListener(listener: listener)
        }
        self.listeners = [RVListener]()
    }
    deinit {
        self.uninstallObservers()
    }

    // searchBar
    let backspace = String(describing: UnicodeScalar(8))
    let tab = "\t"
    let sparklingHeart = "\u{1F496}"

    /*
    func filterQuery(text: String, scopeIndex: Int) -> RVQuery? {
        let query = mainDatasource.basicQuery().duplicate()
        print("In \(self.instanceType).filterQuery base class. Need to override")
        query.addAnd(term: RVKeys.commentLowercase, value: text.lowercased() as AnyObject, comparison: .gte)
        query.removeAllSortTerms()
        query.addSort(field: .commentLowercase, order: .ascending)
        return query
    }
 */
    
    func setupTopView() {
        if let _ = self.topView {
            print("In \(instanceType).setupTopView, need to override")
        }
    }
    func showTopView() {
        if let topView = self.topView {
            topView.isHidden = false
            if let constraint = tableViewTopConstraint {
                constraint.constant = constraint.constant + self.topViewHeightConstraintConstant            }
        } else {
            //p("in showSegmentView, no segmentedView")
        }
    }
    func hideTopView() {
        if let topView = self.topView {
            topView.isHidden = true
            if let constraint = tableViewTopConstraint {
                constraint.constant = constraint.constant - self.topViewHeightConstraintConstant
            }
        }
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
    var manager: RVDSManager? {
        get {
            if let state = self.mainState {
                return state.manager
            }
            return nil
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
            if let manager = self.manager {
                if section >= 0 && section < manager.sections.count {
                    let datasource = manager.sections[section]
                    headerCell.delegate = self
                    headerCell.configure(model: nil, datasource: datasource)
                }
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
    func numberOfSections(in tableView: UITableView) -> Int {
        //print("In \(self.classForCoder).numberOfSections... \(manager.sections.count)")
        if let manager = self.manager {
            let count = manager.sections.count
            if count == 0 {
                showNoMessage(tableView: tableView)
            } else {
                tableView.backgroundView = self.refreshControl
                tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLineEtched
            }
            return count
        } else  { return 0}
    }
}
extension RVBaseViewController: UITableViewDataSource {

    func showNoMessage(tableView: UITableView) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        messageLabel.text = "No data is currently available. Please pull down to refresh."
        messageLabel.textColor = UIColor.black
        messageLabel.textAlignment = NSTextAlignment.center
        messageLabel.font = UIFont(name: "Palatino-Italic", size: 20)
        messageLabel.sizeToFit()
        tableView.backgroundView = messageLabel
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //    print("In \(self.instanceType).cellForRow...")
        if let cell = tableView.dequeueReusableCell(withIdentifier: RVTaskTableViewCell.identifier, for: indexPath) as? RVTaskTableViewCell {
            if let manager = self.manager { cell.model = manager.item(indexPath: indexPath) }
            return cell
        } else {
            print("In \(self.instanceType).cellForRowAt, did not dequeue first cell type")
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let manager = self.manager {
            return manager.numberOfItems(section: section)
        } else {
            return 0
        }

    }
    func userDidLogin(notification: NSNotification) {
        print("In \(self.instanceType).userDidLogin notification target")
        if let userInfo = notification.userInfo {
            if let username = userInfo["user"] as? String {
                print("Username is \(username)")
            } else {
                print("In \(self.classForCoder).userDidLogin, no username")
            }
        } else {
            print("In \(self.classForCoder).userDidLogin, no userInfo")
        }
    }
    func userDidLogout(notification: NSNotification) {
        print("In \(self.instanceType).userDidLogout RVBaseViewController notification target")
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
        if let manager = self.manager {
            if manager.sections.count > 0 {
                let datasource = manager.sections[0]
                datasource.loadFront()
            }
        }
        self.refreshControl.endRefreshing()
    }
    
    func hideView(view: UIView?) {
        if let view = view {
            view.isHidden = true
        }
    }
    func showView(view: UIView?) {
        if let view = view {
            view.isHidden = false
        }
    }
    
    
    
}

extension RVBaseViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        // p("Scope button did change index")
        searchBar.text = ""
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text { searchBar.text = text }
        //p("", "4 searchBarSearchButtonClicked")
    }
    
    
}
extension RVBaseViewController: UISearchResultsUpdating {
    // Called when the search bar's text or scope has changed or when the search bar becomes first responder.

    
    func updateSearchResults(for searchController: UISearchController) {
        if let topView  = self.topView {
            if searchController.isActive && (!topView.isHidden) {
                self.hideTopView()
            } else if !searchController.isActive && topView.isHidden {
                showTopView()
            }
        }
        updateSearchResultsHelper(searchController: searchController)
    }
    func updateSearchResultsHelper(searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scopeIndex = getScopeIndex(searchBar: searchBar)
        if let mainState = self.mainState {
            if scopeIndex >= 0 && scopeIndex < mainState.scopes.count {
                if let (title, _) = mainState.scopes[scopeIndex].first {
                    searchBar.placeholder = "Search by \(title)"
                } else {
                    searchBar.prompt = nil
                }
            } else {
                searchBar.prompt = nil
            }
        } else {
            searchBar.prompt = nil
        }
        /*
        if scopeIndex >= 0 && scopeIndex < scopes.count {
            if let (title, _) = scopes[scopeIndex].first {
                searchBar.placeholder = "Search by \(title)"
            } else {
                searchBar.prompt = nil
            }
        } else {
            searchBar.prompt = nil
        }
 */
        let searchText = searchBar.text != nil ?  searchBar.text! : ""
        //p("in updateSearchResults, scopeIndex = \(scopeIndex) and text is \(searchText)")
        var operation = self.operation
        if operation.active {
            operation = replaceOperation(operation: operation, operationName: searchText)
            self.runInner2(searchController: searchController, operation: operation, searchText: searchText, scopeIndex: scopeIndex)
        } else {
            
            if operation.cancelled {
                operation = RVOperation(active: true, name: searchText)
                self.operation = operation
            }
            operation.name = searchText
            operation.active = true
            self.runInner2(searchController: searchController, operation: operation, searchText: searchText, scopeIndex: scopeIndex)
        }
    }
    func runInner2(searchController: UISearchController, operation: RVOperation, searchText: String, scopeIndex: Int) {
        DispatchQueue.main.async {
            if let mainState = self.mainState {
                if let manager = self.manager {
                    if let filterDatasource = mainState.findDatasource(type: RVBaseDataSource.DatasourceType.filter) {
                        manager.stopAndResetDatasource(datasource: filterDatasource, callback: { (error) in
                            if let error = error {
                                error.append(message: "In \(self.instanceType).runSearch, got error stopping")
                            } else {
                                // self.p("After stopAndReset \(operation.name)")
                                let params: [String: AnyObject] = [RVMainViewControllerState.textLabel: searchText as AnyObject, RVMainViewControllerState.scopeIndexLabel: scopeIndex as AnyObject]
                                if let filterQueryFunction = mainState.queryFunctions[RVBaseDataSource.DatasourceType.filter] {
                                    let query = filterQueryFunction(params)
                                    if let mainDatasource = mainState.findDatasource(type: RVBaseDataSource.DatasourceType.main) {
                                        if let filterDatasource = mainState.findDatasource(type: RVBaseDataSource.DatasourceType.filter) {
                                            if operation.sameOperationAndNotCancelled(operation: self.operation) {
                                                if !mainDatasource.collapsed { mainDatasource.collapse {} }
                                                if searchController.isActive {
                                                    manager.startDatasource(datasource: filterDatasource, query: query, callback: { (error) in
                                                        //self.p("After startDatasource \(operation.name)")
                                                        if let error = error {
                                                            error.append(message: "In \(self.instanceType).textDidChange, got error")
                                                            error.printError()
                                                        }
                                                        let _ = self.replaceOperation(operation: operation)
                                                    })
                                                } else {
                                                    searchController.searchBar.prompt = nil
                                                    searchController.searchBar.placeholder = "Search..."
                                                    if let tableView = self.dsScrollView as? UITableView {
                                                        let indexPath = IndexPath(row: 0, section: 0)
                                                        if mainDatasource.collapsed {
                                                            mainDatasource.expand {
                                                                if manager.numberOfItems(section: manager.section(datasource: mainDatasource)) > 0 {
                                                                    tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
                                                                }
                                                            }
                                                        } else {
                                                            if manager.numberOfItems(section: manager.section(datasource: mainDatasource)) > 0 {
                                                                tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
                                                            }
                                                        }
                                                        let _ = self.replaceOperation(operation: operation)
                                                    }
                                                }
                                                
                                            } else {
                                                self.p("Same operation and not cancelled \(operation.name) --------")
                                            }
                                        }
                                    }
                                }
                                
                                
                                /*
                                 
                                 let query = self.filterQuery(text: searchText, scopeIndex: scopeIndex)
                                 if operation.sameOperationAndNotCancelled(operation: self.operation) {
                                 if !self.mainDatasource.collapsed { self.mainDatasource.collapse {} }
                                 if searchController.isActive {
                                 if let query = query {
                                 manager.startDatasource(datasource: self.filterDatasource, query: query, callback: { (error) in
                                 //self.p("After startDatasource \(operation.name)")
                                 if let error = error {
                                 error.append(message: "In \(self.instanceType).textDidChange, got error")
                                 error.printError()
                                 }
                                 let _ = self.replaceOperation(operation: operation)
                                 })
                                 }
                                 } else {
                                 searchController.searchBar.prompt = nil
                                 searchController.searchBar.placeholder = "Search..."
                                 if let tableView = self.dsScrollView as? UITableView {
                                 let indexPath = IndexPath(row: 0, section: 0)
                                 if self.mainDatasource.collapsed {
                                 self.mainDatasource.expand {
                                 if manager.numberOfItems(section: manager.section(datasource: self.mainDatasource)) > 0 {
                                 tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
                                 }
                                 }
                                 } else {
                                 if manager.numberOfItems(section: manager.section(datasource: self.mainDatasource)) > 0 {
                                 tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
                                 }
                                 }
                                 let _ = self.replaceOperation(operation: operation)
                                 }
                                 }
                                 
                                 } else {
                                 self.p("Same operation and not cancelled \(operation.name) --------")
                                 }
                                 */
                            }
                        })
                    }

                }
            }
        }
    }
    func replaceOperation(operation: RVOperation, operationName: String = "") -> RVOperation {
        if operation.sameOperation(operation: self.operation) {
            operation.cancelled = true
            self.operation = RVOperation(active: false, name: operationName)
            operation.active = false
            return self.operation
        }
        return operation
    }
    func getScopeIndex(searchBar: UISearchBar) -> Int {
        var scopeIndex = -1
        if let scopeButtonTitles = searchBar.scopeButtonTitles {
            let selectedIndex = searchBar.selectedScopeButtonIndex
            if selectedIndex >= 0 && selectedIndex < scopeButtonTitles.count {
                scopeIndex = selectedIndex
            }
        }
        return scopeIndex
    }
}

extension RVBaseViewController: RVFirstViewHeaderCellDelegate {
    func expandCollapseButtonTouched(view: RVFirstViewHeaderCell) -> Void {
        if let datasource = view.datasource {
            datasource.toggle {}
        } else {
            print("In \(self.instanceType).expandCollapseButtonTOuched no datasource")
        }
    }
}

