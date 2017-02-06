//
//  RVBaseViewController2.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/29/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit

class RVBaseViewController2: UIViewController {
    var refreshControl = UIRefreshControl()
    let searchController = UISearchController(searchResultsController: nil)
    var instanceType: String { get { return String(describing: type(of: self)) } }
    var operation: RVOperation = RVOperation(active: false)
    var mainState: RVBaseAppState {
        get { return RVCoreInfo.sharedInstance.appState }
        set { RVCoreInfo.sharedInstance.appState = newValue}
    }
    var userProfile: RVUserProfile? { get { return RVCoreInfo.sharedInstance.userProfile }}
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    var topViewHeightConstraintConstant:CGFloat = 0.0
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var dsScrollView: UIScrollView? {
        if let tableView = self.tableView { return tableView
        } else if let collectionView = self.collectionView { return collectionView }
        return nil
    }
    var manager: RVDSManager { get { return mainState.manager } }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
/*
        if let tableView = self.tableView {
            let inset = self.tableView.contentInset
            tableView.contentInset = UIEdgeInsets(top: inset.top + 200, left: inset.left, bottom: inset.bottom, right: inset.right)
        }
 */
        configure()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //print("IN \(self.classForCoder).viewWIllAppear")
        install()
    }
    func configure() {
        configureSearchController()
        configureTopView()
        configureRefresh()
    }
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.delegate = self
        let searchBar = searchController.searchBar
        searchBar.delegate = self
        searchBar.prompt = nil
        searchBar.showsSearchResultsButton = false
        searchBar.placeholder = "Search..."
        definesPresentationContext = true
    }
    func install() {
        //print("In \(self.classForCoder).install")
        installSearchController()
        installTopView()
        installNavigationTitle()
        installRefresh()
        installTableInteractivity()
        
    }
    func installTableInteractivity() {
        if let tableView = dsScrollView as? UITableView {
            tableView.isUserInteractionEnabled = mainState.tableViewInteractive
        }
    }
    func installSearchController() {
        if mainState.installSearchController {
            if let tableView = self.dsScrollView as? UITableView { tableView.tableHeaderView = self.searchController.searchBar }
           // installSearchControllerScope()
        } else if let tableView = self.dsScrollView as? UITableView { if let _ = tableView.tableHeaderView as? UISearchBar { tableView.tableHeaderView = nil } }
    }
    func installSearchControllerScope() {
        var titles = [String]()
        for scopeTerm in mainState.scopes { if let (title, _) = scopeTerm.first { titles.append(title) } }
        let searchBar = searchController.searchBar
        if titles.count > 0 { searchBar.scopeButtonTitles = titles}
        else {searchBar.scopeButtonTitles = nil }
        searchBar.selectedScopeButtonIndex = 0
    }
    func configureRefresh() {
        self.refreshControl.backgroundColor = UIColor.purple
        self.refreshControl.tintColor = UIColor.white
        self.refreshControl.addTarget(self , action: #selector(refresh), for: UIControlEvents.valueChanged)
    }
    func installRefresh() {
        if let tableView = dsScrollView as? UITableView {
            if mainState.installRefreshControl {
                tableView.backgroundView = self.refreshControl
                tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLineEtched
            }
        }
    }
    func refresh() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        let title = "Last update: \(formatter.string(from: Date()))"
        let attrsDictionary = [NSForegroundColorAttributeName : UIColor.white]
        let attributedTitle = NSAttributedString(string: title, attributes: attrsDictionary)
        self.refreshControl.attributedTitle = attributedTitle
        refreshDatasources()
        self.refreshControl.endRefreshing()
    }
    func refreshDatasources() {
        for datasource in mainState.datasources {
            if datasource.datasourceType == .main {
                if let queryFunction = self.mainState.queryFunctions[RVBaseDataSource.DatasourceType.main] {
                    let query = queryFunction([String: AnyObject]())
                    mainState.manager.stopAndResetDatasource(datasource: datasource, callback: { (error) in
                        if let error = error {
                            error.printError()
                        } else {
                            self.mainState.manager.startDatasource(datasource: datasource, query: query , callback: { (error ) in
                                if let error = error {
                                    error.printError()
                                }
                            })
                        }
                    })
                }
                
            }
        }
    }
    func configureTopView() { if let _ = self.topView { print("In \(instanceType).setupTopView, need to override") } }
    func installTopView() {
        showTopView()
    }
    func installNavigationTitle() {
        navigationController?.title = mainState.navigationBarTitle
    }
    func installSegmentView() {
        if let control = self.segmentedControl {
            var index = 0
            control.removeAllSegments()
            if mainState.segmentViewFields.count > 0 {
                for segment in mainState.segmentViewFields {
                    control.insertSegment(withTitle: segment.segmentLabel, at: index, animated: true)
                    index = index + 1
                }
                let state = mainState.state
                for index in (0..<mainState.segmentViewFields.count) {
                    if state == mainState.segmentViewFields[index] {
                        control.selectedSegmentIndex = index
                        break
                    }
                }
            }
        }
    }

}

extension RVBaseViewController2: UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        installSearchControllerScope()
    }
    func didDismissSearchController(_ searchController: UISearchController) {}
}
extension RVBaseViewController2: UISearchResultsUpdating {
    
    func hideTopView() {
        print("In \(self.instanceType).hideTopView) with state \(mainState) and showTopView: \(mainState.showTopView)")
        if let view = topView { view.isHidden = true }
    }
    func showTopView() {
        print("In \(self.instanceType).showTopView) with state \(mainState) and showTopView: \(mainState.showTopView)")
        if let view = topView { if mainState.showTopView { view.isHidden = false }}
    }
    func updateSearchResults(for searchController: UISearchController) {
        if let topView  = self.topView {
            if searchController.isActive && (!topView.isHidden) { self.hideTopView()
            } else if !searchController.isActive && topView.isHidden {showTopView()}
        }
        if searchController.isActive { tableView.backgroundView = nil
        } else { tableView.backgroundView = self.refreshControl }
        updateSearchResultsHelper(searchController: searchController)
    }
    func updateSearchResultsHelper(searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scopeIndex = getScopeIndex(searchBar: searchBar)
        
        if scopeIndex >= 0 && scopeIndex < mainState.scopes.count {
            if let (title, _) = mainState.scopes[scopeIndex].first { searchBar.placeholder = "Search by \(title)"
            } else { searchBar.placeholder = "Search" }
        }
        let searchText = searchBar.text != nil ?  searchBar.text! : ""
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
            let manager = self.manager
            if let filterDatasource = self.mainState.findDatasource(type: RVBaseDataSource.DatasourceType.filter) {
                manager.stopAndResetDatasource(datasource: filterDatasource, callback: { (error) in
                    if let error = error {
                        error.append(message: "In \(self.instanceType).runSearch, got error stopping")
                    } else {
                        // self.p("After stopAndReset \(operation.name)")
                        let params: [String: AnyObject] = [RVMainViewControllerState.textLabel: searchText as AnyObject, RVMainViewControllerState.scopeIndexLabel: scopeIndex as AnyObject]
                        if let filterQueryFunction = self.mainState.queryFunctions[RVBaseDataSource.DatasourceType.filter] {
                            let query = filterQueryFunction(params)
                            // print("In \(self.classForCoder).runInner2, have new Query")
                            if let mainDatasource = self.mainState.findDatasource(type: RVBaseDataSource.DatasourceType.main) {
                                if let filterDatasource = self.mainState.findDatasource(type: RVBaseDataSource.DatasourceType.filter) {
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
                                    }
                                }
                            }
                        }
                        
                    }
                })
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
            if selectedIndex >= 0 && selectedIndex < scopeButtonTitles.count { scopeIndex = selectedIndex }
        }
        return scopeIndex
    }

}
extension RVBaseViewController2: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) { searchBar.text = "" }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {}
}
extension RVBaseViewController2: UITableViewDelegate {
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
                headerCell.configure(model: nil, datasource: datasource)
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
extension RVBaseViewController2: UITableViewDataSource {
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
    func numberOfSections(in tableView: UITableView) -> Int {
        let count = manager.sections.count
        if count == 0 {
            showNoMessage(tableView: tableView)
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
}
extension RVBaseViewController2: RVFirstViewHeaderCellDelegate {
    func expandCollapseButtonTouched(view: RVFirstViewHeaderCell) -> Void {
        if let datasource = view.datasource {
            datasource.toggle {}
        } else {
            print("In \(self.instanceType).expandCollapseButtonTOuched no datasource")
        }
    }
}
