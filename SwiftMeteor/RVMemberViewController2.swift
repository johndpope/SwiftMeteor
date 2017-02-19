//
//  RVMemberViewController2.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 2/18/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit

class RVMemberViewController2: RVMemberViewController {
    @IBOutlet weak var outerTopAreaView: UIView!
    @IBOutlet weak var topViewInTopArea: UIView!
    @IBOutlet weak var controllerOuterSegementedControlView: UIView!
    @IBOutlet weak var controllerSegmentedControl: UISegmentedControl!
    @IBOutlet weak var bottomViewInTopArea: UIView!

    @IBOutlet weak var topViewInTopAreaHeightConstraint: NSLayoutConstraint!
    var originalTopViewInTopAreaHeightConstant: CGFloat = 0.0
    @IBOutlet weak var controllerOuterSegmentControlViewHeightConstraint: NSLayoutConstraint!
    var originalControllerOuterSegmentControlViewHeightConstant: CGFloat = 0.0
    @IBOutlet weak var bottomViewInTopAreaHeightConstraint: NSLayoutConstraint!
    var originalBottomViewInTopAreaHeightConstrant: CGFloat = 0.0
    var tableViewInsetAdditionalHeight: CGFloat = 0.0
    var topAreaHeight: CGFloat {
        let top = heightConstant(constraint: topViewInTopAreaHeightConstraint)
        let middle = heightConstant(constraint: controllerOuterSegmentControlViewHeightConstraint)
        let bottom = heightConstant(constraint: bottomViewInTopAreaHeightConstraint)
        return top + middle + bottom
    }

    var dsScrollView: UIScrollView? {return tableView }
    var instanceType: String { get { return String(describing: type(of: self)) } }
    var coreInfo: RVCoreInfo { get { return RVCoreInfo.sharedInstance }}
    var appState: RVBaseAppState { get {return coreInfo.appState} set {coreInfo.appState = newValue}}
    var manager: RVDSManager { get { return appState.manager }}
    var deck: RVViewDeck { get { return RVViewDeck.sharedInstance }}
    var searchController = UISearchController(searchResultsController: nil)
    var operation: RVOperation = RVOperation(active: false)
    var refreshControl = UIRefreshControl()
    func userProfileAndDomainId() -> (RVUserProfile, String)? { return coreInfo.userAndDomain() }

}
extension RVMemberViewController2 {
    override func viewDidLoad() {
        setupSLKDatasource = false
        super.viewDidLoad()

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        installUIComponents()
        print("In \(self.classForCoder).viewDidAppear just before appState initialize \(appState.state.rawValue) -------")
        
        appState.initialize(scrollView: self.dsScrollView) { (error) in
            if let error = error {
                error.append(message: "In \(self.classForCoder).viewDidAppear, got initialize error")
                error.printError()
            } else {
                 print("In \(self.classForCoder).viewDidAppear returned from appState initialize \(self.appState.state.rawValue) ----------")
            }
        }
 
 
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView == self.tableView {
            let message = appState.manager.item(indexPath: indexPath)
           // let message = self.messages[(indexPath as NSIndexPath).row]
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .byWordWrapping
            paragraphStyle.alignment = .left
            
            let pointSize =  RVMessageTableViewCell.defaultFontSize()
            
            let attributes = [
                NSFontAttributeName : UIFont.systemFont(ofSize: pointSize),
                NSParagraphStyleAttributeName : paragraphStyle
            ]
            
            var width = tableView.frame.width-RVMessageTableViewCell.AvatarHeight
            width -= 25.0
            var username = ""
            var messageContent = ""
            if let message = message as? RVMessage {
                if let fullName = message.fullName { username = fullName }
                if let content = message.text { messageContent = content }
            }
            
            let titleBounds = (username as NSString).boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
            let bodyBounds = (messageContent as NSString).boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
            
            //if message.text.characters.count == 0 { return 0 }
            
            var height = titleBounds.height
            height += bodyBounds.height
            height += 30
            // height += 10
            if height < RVMessageTableViewCell.MinimumHeight { height = RVMessageTableViewCell.MinimumHeight}
            return height
        }
        else {
            return RVMessageTableViewCell.MinimumHeight
        }
    }
}
extension RVMemberViewController2 {
    func reload() {
        appState.unwind {
            self.appState.unloadAllDatasources(callback: { (error) in
                if let error = error {
                    error.printError()
                } else {
                    
                    self.appState.initialize(scrollView: self.dsScrollView , callback: { (error) in
                        if let error = error {
                            error.append(message: "In \(self.classForCoder).unloadAllDatasources line \(#line) error")
                            error.printError()
                        }
                    })
                    
                }
            })
        }
    }
    func updateTableViewInsetHeight() {
        if let tableView = self.dsScrollView as? UITableView {
            let height = topAreaHeight - tableViewInsetAdditionalHeight
            tableViewInsetAdditionalHeight = topAreaHeight
            let inset = tableView.contentInset
            tableView.contentInset = UIEdgeInsets(top: inset.top + height, left: inset.left, bottom: inset.bottom, right: inset.right)
            // print("in \(instanceType) topAreaHeight = \(topAreaHeight) height = \(height), original top was: \(inset.top) and is now \(tableView.contentInset.top), additionalHeight : \(tableViewInsetAdditionalHeight)")
        }
    }
    func handleLeftBarButton(barButton: UIBarButtonItem) {
        if !coreInfo.setActiveButtonIfNotActive(nil, barButton) { return }
        appState.unwind {
            self.appState = RVMenuAppState()
            self.deck.toggleSide(side: .left)
            let _ = self.coreInfo.clearActiveButton(nil, barButton)
        }
        
    }
    func handleRightBarButton(barButton: UIBarButtonItem) {
        if !coreInfo.setActiveButtonIfNotActive(nil, barButton) { return }
        print("In \(instanceType).handleRightBarButton RVBaseViewController3 base method. Need to override")
        let _ = coreInfo.clearActiveButton(nil, barButton)
    }
    func zeroTopArea() {
        setHeightConstant(constraint: topViewInTopAreaHeightConstraint, constant: 0)
        setHeightConstant(constraint: controllerOuterSegmentControlViewHeightConstraint, constant: 0)
        if let control = controllerSegmentedControl { control.isHidden = true }
        if let view = controllerOuterSegementedControlView {
            view.isHidden = true
            view.backgroundColor = appState.navigationBarColor
        }
        setHeightConstant(constraint: bottomViewInTopAreaHeightConstraint, constant: 0)
        hideOrUnhideConstraintedView(view: topViewInTopArea, constraint: topViewInTopAreaHeightConstraint)
        hideOrUnhideConstraintedView(view: controllerOuterSegementedControlView, constraint: controllerOuterSegmentControlViewHeightConstraint)
        hideOrUnhideConstraintedView(view: bottomViewInTopArea, constraint: bottomViewInTopAreaHeightConstraint)
        updateTableViewInsetHeight()
    }
    func setupTopArea() {
        // print("In \(instanceType).setupTopArea, top: \(appState.topInTopAreaHeight), control: \(appState.controllerOuterSegmentedViewHeight) bottom: \(appState.bottomInTopAreaHeight)")
        setHeightConstant(constraint: topViewInTopAreaHeightConstraint, constant: appState.topInTopAreaHeight)
        if let control = controllerSegmentedControl { control.isHidden = (appState.controllerOuterSegmentedViewHeight == 0) ? true : false }
        if let view = controllerOuterSegementedControlView {
            view.isHidden = (appState.controllerOuterSegmentedViewHeight == 0) ? true : false
            view.backgroundColor = appState.navigationBarColor
        }
        setHeightConstant(constraint: controllerOuterSegmentControlViewHeightConstraint, constant: appState.controllerOuterSegmentedViewHeight)
        setHeightConstant(constraint: bottomViewInTopAreaHeightConstraint, constant: appState.bottomInTopAreaHeight)
        hideOrUnhideConstraintedView(view: topViewInTopArea, constraint: topViewInTopAreaHeightConstraint)
        hideOrUnhideConstraintedView(view: controllerOuterSegementedControlView, constraint: controllerOuterSegmentControlViewHeightConstraint)
        hideOrUnhideConstraintedView(view: bottomViewInTopArea, constraint: bottomViewInTopAreaHeightConstraint)
        updateTableViewInsetHeight()
    }
    func getOriginalHeightConstants() -> Void {
        originalTopViewInTopAreaHeightConstant  = heightConstant(constraint: topViewInTopAreaHeightConstraint)
        originalControllerOuterSegmentControlViewHeightConstant = heightConstant(constraint: controllerOuterSegmentControlViewHeightConstraint)
        originalBottomViewInTopAreaHeightConstrant = heightConstant(constraint: bottomViewInTopAreaHeightConstraint)
    }
    func heightConstant(constraint: NSLayoutConstraint!) -> CGFloat {
        if let constraint = constraint { return constraint.constant }
        return 0
    }
    func setHeightConstant(constraint: NSLayoutConstraint!, constant: CGFloat) {
        if let constraint = constraint { constraint.constant = constant }
    }
    func hideOrUnhideConstraintedView(view: UIView? = nil, constraint: NSLayoutConstraint? = nil) {
        if let view = view { if let constraint = constraint { view.isHidden = (constraint.constant == 0) ? true : false } }
    }
    func configureNavBar() {
        if let navController = self.navigationController {
            //navController.navigationBar.barStyle = .black
            // navController.navigationBar.isTranslucent = false
            navController.navigationBar.barTintColor = appState.navigationBarColor
            self.title = appState.navigationBarTitle
            
            navController.navigationBar.tintColor = UIColor.white
            if let font = UIFont(name: "Avenir", size: 20) { // UIFont(font:"Kelvetica Nobis" size:20.0)
                let shadow = NSShadow()
                shadow.shadowOffset = CGSize(width: 2.0, height: 2.0)
                shadow.shadowColor = UIColor.black
                //
                navController.navigationBar.titleTextAttributes = [ NSFontAttributeName: font, NSShadowAttributeName: shadow,  NSForegroundColorAttributeName: UIColor.white]
            }
            setNeedsStatusBarAppearanceUpdate()
            
            /* Also in advance, you can add these line to hide the text that comes up in back button in action bar when you navigate to another view within the navigation controller.
             
             [[UIBarButtonItem appearance]
             setBackButtonTitlePositionAdjustment:UIOffsetMake(-1000, -1000)
             forBarMetrics:UIBarMetricsDefault];
             */
        }
    }
    override func didPressRightButton(_ sender: Any!) {
        
        // This little trick validates any pending auto-correction or auto-spelling just after hitting the 'Send' button
        self.textView.refreshFirstResponder()
        /*
        let message = RVSlackMessage()
        message.username = LoremIpsum.name()
        message.text = self.textView.text
        */
        let indexPath = IndexPath(row: 0, section: 0)
        let rowAnimation: UITableViewRowAnimation = self.isInverted ? .bottom : .top
        let scrollPosition: UITableViewScrollPosition = self.isInverted ? .bottom : .top
        
        self.tableView.beginUpdates()
        print("In \(self.classForCoder).didPressRightButtton need to fix")
       // self.messages.insert(message, at: 0)
        self.tableView.insertRows(at: [indexPath], with: rowAnimation)
        self.tableView.endUpdates()
        
        self.tableView.scrollToRow(at: indexPath, at: scrollPosition, animated: true)
        
        // Fixes the cell from blinking (because of the transform, when using translucent cells)
        // See https://github.com/slackhq/SlackTextViewController/issues/94#issuecomment-69929927
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
        
        super.didPressRightButton(sender)
    }
    override func editCellMessage(_ gesture: UIGestureRecognizer) {
        
        guard let cell = gesture.view as? RVMessageTableViewCell else { return }
        print("In \(self.classForCoder).editCellMessage. Need to fix")
        // self.editingMessage = self.messages[cell.indexPath.row]
        self.editText(self.editingMessage.text)
        
        self.tableView.scrollToRow(at: cell.indexPath, at: .bottom, animated: true)
    }
    

    
    override func editLastMessage(_ sender: AnyObject?) {
        
        if self.textView.text.characters.count > 0 {
            return
        }
        
        let lastSectionIndex = self.tableView.numberOfSections-1
        let lastRowIndex = self.tableView.numberOfRows(inSection: lastSectionIndex)-1
        print("In \(self.classForCoder).editLastMessage. Need to fix")
       // let lastMessage = self.messages[lastRowIndex]
        
        // self.editText(lastMessage.text)
        
        self.tableView.scrollToRow(at: IndexPath(row: lastRowIndex, section: lastSectionIndex), at: .bottom, animated: true)
    }
    func installUIComponents() {
        configureSearchController()
        configureRefresh()
        installSearchController()
        installRefresh()
        installTableInteractivity()
        configureNavBar()
        setupTopArea()
    }
}
extension RVMemberViewController2 {
    func configureRefresh() {
        self.refreshControl.backgroundColor = UIColor.purple
        self.refreshControl.tintColor = UIColor.white
        self.refreshControl.addTarget(self , action: #selector(refresh), for: UIControlEvents.valueChanged)
    }
    func installRefresh() {
        if let tableView = dsScrollView as? UITableView {
            if appState.installRefreshControl {
                //print("in \(self.classForCoder).installRefresh() ")
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
        refreshControl.attributedTitle = attributedTitle
        reload()
        refreshControl.endRefreshing()
    }
}
extension RVMemberViewController2: UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) { installSearchControllerScope() }
    func didDismissSearchController(_ searchController: UISearchController) {}
    func installSearchControllerScope() {
        var titles = [String]()
        for scopeTerm in appState.scopes { if let (title, _) = scopeTerm.first { titles.append(title) } }
        let searchBar = searchController.searchBar
        if titles.count > 0 { searchBar.scopeButtonTitles = titles}
        else {searchBar.scopeButtonTitles = nil }
        searchBar.selectedScopeButtonIndex = 0
    }
    func installSearchController() {
                    print("In \(self.classForCoder).installSearchController")
        if appState.installSearchController {
            print("In \(self.classForCoder).installSearchController passed test \(appState.state.rawValue)")
            if let tableView = self.dsScrollView as? UITableView { tableView.tableHeaderView = self.searchController.searchBar }
            return
        } else if let tableView = self.dsScrollView as? UITableView { if let _ = tableView.tableHeaderView as? UISearchBar { tableView.tableHeaderView = nil } }
        print("In \(self.classForCoder).installSearchController failed test \(appState.state.rawValue)")
    }
    func installTableInteractivity() { if let tableView = dsScrollView as? UITableView { tableView.isUserInteractionEnabled = appState.tableViewInteractive } }
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
        searchBar.barTintColor = appState.navigationBarColor
    }
}
extension RVMemberViewController2: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) { searchBar.text = "" }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {}
}
extension RVMemberViewController2: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        //print("In updateSearchResults active: [\(searchController.isActive)]")
        if searchController.isActive { zeroTopArea()}
        else if !searchController.isActive {setupTopArea()}
        if searchController.isActive { tableView.backgroundView = nil }
        else { tableView.backgroundView = self.refreshControl }
        updateSearchResultsHelper(searchController: searchController)
    }
    func updateSearchResultsHelper(searchController: UISearchController) {
        print("In \(self.classForCoder).updateSearchResultsController. Should not be here -------------------------------")
        let searchBar = searchController.searchBar
        let scopeIndex = getScopeIndex(searchBar: searchBar)
        
        if scopeIndex >= 0 && scopeIndex < appState.scopes.count {
            if let (title, _) = appState.scopes[scopeIndex].first { searchBar.placeholder = "Search by \(title)"
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
            if let filterDatasource = self.appState.findDatasource(type: RVBaseDataSource.DatasourceType.filter) {
                manager.stopAndResetDatasource(datasource: filterDatasource, callback: { (error) in
                    if let error = error {
                        error.append(message: "In \(self.instanceType).runSearch, got error stopping")
                    } else {
                        // self.p("After stopAndReset \(operation.name)")
                        let params: [String: AnyObject] = [RVMainViewControllerState.textLabel: searchText as AnyObject, RVMainViewControllerState.scopeIndexLabel: scopeIndex as AnyObject]
                        if let filterQueryFunction = self.appState.queryFunctions[RVBaseDataSource.DatasourceType.filter] {
                            let query = filterQueryFunction(params)
                            // print("In \(self.classForCoder).runInner2, have new Query")
                            if let mainDatasource = self.appState.findDatasource(type: RVBaseDataSource.DatasourceType.main) {
                                if let filterDatasource = self.appState.findDatasource(type: RVBaseDataSource.DatasourceType.filter) {
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

// UITableViewDataSource
extension RVMemberViewController2 {
    override func numberOfSections(in tableView: UITableView) -> Int {
        //print("In \(self.classForCoder).numberOfSections \(appState.state.rawValue), \(appState.manager.sections.count)")
        if appState.state == .MemberToMemberChat { return manager.sections.count}
        else { return 0 }

    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                print("In \(self.classForCoder).numberOfItems \(appState.manager.numberOfItems(section: section))")
        if appState.state == .MemberToMemberChat {
            return appState.manager.numberOfItems(section: section)
        } else {
            return 0
        }
    }

    
    override func messageCellForRowAtIndexPath(_ indexPath: IndexPath) -> RVMessageTableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: RVMessageTableViewCell.identifier) as! RVMessageTableViewCell
        
        if cell.gestureRecognizers?.count == nil {
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(RVMemberViewController.didLongPressCell(_:)))
            cell.addGestureRecognizer(longPress)
        }
        if let message = appState.manager.item(indexPath: indexPath) as? RVMessage {
            cell.model = message
            var username = ""
            var messageContent = ""
            if let fullName = message.fullName { username = fullName }
            if let content = message.text { messageContent = content }
            cell.messageContentLabel.text = messageContent
            cell.titleLabel.text = username
        }

        
        //        cell.titleLabel.text = message.username
        //        cell.bodyLabel.text = message.text

        cell.configureSubviews()
        cell.indexPath = indexPath
        cell.usedForMessage = true

        
        
        // Cells must inherit the table view's transform
        // This is very important, since the main table view may be inverted
        cell.transform = self.tableView.transform
        
        return cell
    }
    
    
    func showNoMessage(tableView: UITableView) {
        print("In showNoMessage")
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
        messageLabel.text = "No data. Please pull down to refresh."
        messageLabel.textColor = UIColor.black
        messageLabel.textAlignment = NSTextAlignment.center
        messageLabel.font = UIFont(name: "Palatino-Italic", size: 20)
        messageLabel.sizeToFit()
        tableView.backgroundView = messageLabel
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
    }
}
