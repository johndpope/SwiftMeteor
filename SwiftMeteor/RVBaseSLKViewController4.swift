//
//  RVBaseSLKViewController4.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/7/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
import SlackTextViewController

class RVBaseSLKViewController4: SLKTextViewController {
    var sectionManager = RVDSManager5<RVBaseModel>(scrollView: nil, managerType: .main, dynamicSections: false)
    var sectionTest: Bool = false
    var instanceType: String { get { return String(describing: type(of: self)) } }
    var dsScrollView: UIScrollView? {return self.tableView }
    var deck: RVViewDeck { get { return RVViewDeck4.shared }}
    @IBOutlet weak var transparentTableViewBackground: UIView!
    @IBOutlet weak var searchControllerContainerView: UIView!
    @IBOutlet weak var TopOuterView:            UIView!
    @IBOutlet weak var TopTopView:              UIView!
    @IBOutlet weak var TopMiddleView:           UIView!
    @IBOutlet weak var TopBottomView:           UIView!
    @IBOutlet weak var TopTopHeightConstraint:    NSLayoutConstraint!
    @IBOutlet weak var TopMiddleHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var TopBottomHeightConstraint: NSLayoutConstraint!
    var tableViewInsetAdditionalHeight: CGFloat = 0.0
    let navBarHeight: CGFloat = 62.0
    var _lastSearchTerm: String = "Dummy Value"
    var lastSearchTerm: String  = "Dummy Value"
    var SLKIsInverted: Bool                             { return configuration.SLKIsInverted }
    var SLKbounces: Bool                                { return configuration.SLKbounces }
    var SLKshakeToClearEnabled: Bool                    { return configuration.SLKshakeToClearEnabled }
    var SLKisKeyboardPanningEnabled: Bool               { return configuration.SLKisKeyboardPanningEnabled }
    var SLKshouldScrollToBottomAfterKeyboardShows: Bool { return configuration.SLKshouldScrollToBottomAfterKeyboardShows }
    var SLKshowTextInputBar: Bool                       { return configuration.SLKshowTextInputBar }
    // SLK Stuff
    var pipWindow: UIWindow? // for SLK
    var users: Array = ["Allen", "Anna", "Alicia", "Arnold", "Armando", "Antonio", "Brad", "Catalaya", "Christoph", "Emerson", "Eric", "Everyone", "Steve"]
    var commands: Array = ["msg", "call", "text", "skype", "kick", "invite"]
    var channels: Array = ["General", "Random", "iOS", "Bugs", "Sports", "Android", "UI", "SSB"]
    var emojis: Array = ["-1", "m", "man", "machine", "block-a", "block-b", "bowtie", "boar", "boat", "book", "bookmark", "neckbeard", "metal", "fu", "feelsgood"]
    var setupSLKDatasource: Bool = true
    var searchResult: [String]? // for SLKTextViewController, not sure why
    var _configuration: RVBaseConfiguration4? = nil
    var configuration: RVBaseConfiguration4 {
        get {
            if let c = _configuration { return c }
            let configuration = instanceConfiguration
            _configuration = configuration
            return configuration    
        }
    }
    var instanceConfiguration: RVBaseConfiguration4 { return RVBaseConfiguration4(scrollView: dsScrollView) }
    // var configuration:      RVBaseConfiguration4 = RVBaseConfiguration4(scrollView: nil)
    var manager:            RVDSManager5<RVBaseModel> { get { return configuration.manager }}
    let searchController    = UISearchController(searchResultsController: nil)
    var searchScopes:       [[String: RVKeys]] { get { return configuration.searchScopes } }
    var defaultSortOrder:   RVSortOrder { get { return configuration.defaultSortOrder }}

    var installSearchControllerInTableView: Bool { get { return configuration.installSearchControllerInTableView }}
    var searchBarPlaceholder: String { get { return configuration.searchBarPlaceholder }}
    var coreInfo: RVCoreInfo2 { get { return RVCoreInfo2.shared }}
    var stack = [RVBaseModel]() { didSet { _priorStack = oldValue } }
    private var _priorStack = [RVBaseModel]()
    var sameStack: Bool {
        get {
            if stack.count == _priorStack.count {
                if stack.count == 0 { return true }
                for i in 0..<stack.count { if stack[i] != _priorStack[i] { return false } }
                return true
            } else { return false }
        }
    }
    @IBAction func searchButtonTouched(_ sender: UIBarButtonItem) {
        searchController.isActive = true
    }
    @IBAction func menuButtonTouched(_ sender: UIBarButtonItem) {
        RVStateDispatcher4.shared.changeState(newState: RVBaseAppState4(appState: .leftMenu))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       //sectionManager = RVDSManager5Transaction<RVBaseModel>(scrollView: self.dsScrollView, maxSize: 80, managerType: .main, dynamicSections: false)
        sectionManager = configuration.manager
        commonInit()
        configureNavBar()
        configureSearchController()
        configureSLK()
        adjustTableViewInsetForNavBar()
        updateTableViewInsetHeight()
        putTopViewOnTop()
        
        //standard()
        configuration.initializeDatasource(sectionDatasourceType: .main) { (error) in
            if let error = error {
                error.printError()
            }
        }
        
        makeTableViewTransparent()
    }
    /*
    func standard() {
        if !sectionTest {
            let (query, _) = configuration.topQuery()
            configuration.loadTop(query: query, callback: { (error) in
                if let error = error {
                    error.printError()
                } else {
                    self.loadMain(callback: { (error) in
                        if let error = error {
                            error.printError()
                        }
                    })
                }
                
            })
        } else {
            doSectionTest(callback: { (error) in
                if let error = error {
                    error.printError()
                }
            })
        }
    }
    func doSectionTest(callback: @escaping(RVError?) -> Void ) {
        print("In \(self.instanceType).doSectionTest need to override")
    }
 */
    func makeTableViewTransparent() {
        if let tableView = self.tableView {
            makeTransparent(view: tableView)
            makeTransparent(view: tableView.backgroundView)
        }
    }
    func performSearch(searchText: String, field: RVKeys, order: RVSortOrder = .ascending) {
        if lastSearchTerm == searchText { return }
        lastSearchTerm = searchText.lowercased()
        self.configuration.loadSearch(searchText: searchText, field: field, order: order) { (error ) in
            if let error = error {
                error.printError()
            } else {
                self.zeroTopView()
            }
        }
        
        /*
        let matchTerm = RVQueryItem(term: field, value: searchText.lowercased() as AnyObject, comparison: .regex)
        let andTerms = [RVQueryItem]()
        let (query, error) = self.configuration.filterQuery(andTerms: andTerms, matchTerm: matchTerm, sortTerm: RVSortTerm(field: field, order: order))
        if let error = error {
            error.printError()
        } else {
            self.zeroTopView()
            self.configuration.loadSearch(query: query) { (error) in
                if let error = error {
                    error.printError()
                }
            }
        }
 */
    }
    func endSearch() {
        self.configuration.endSearch { (error) in
            if let error = error {
                error.append(message: "In \(self.instanceType).endSearch2, got error ")
                error.printError()
            } else {
                self.expandTopView()
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        configuration.removeAllSections { (models, error) in
            if let error = error {
                error.append(message: "In \(self.instanceType).deinit got error removing All Sections")
                error.printError()
            }
        }
    }
    func makeTransparent(view: UIView?) {
        if let view = view {
            view.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
            view.isOpaque = false
            
        }
    }
    func makeOpaque(view: UIView?) {
        if let view = view {
            view.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
            view.isOpaque = true
            
        }
    }
    
// UITableViewDatasource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return manager.numberOfSections
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return manager.numberOfItems(section: section)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            return primaryCellForRowAtIndexPath(tableView: tableView, indexPath)
        } else {
            return self.autoCompletionCellForRowAtIndexPath(indexPath)
        }
    }
    func primaryCellForRowAtIndexPath(tableView: UITableView, _ indexPath: IndexPath) -> RVTransactionTableViewCell {
       // print("In \(self.classForCoder).primaryCell for indexPath \(indexPath.section) \(indexPath.row)")
        let cell = tableView.dequeueReusableCell(withIdentifier: RVTransactionTableViewCell.identifier) as! RVTransactionTableViewCell
        if cell.gestureRecognizers?.count == nil {
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(RVMemberViewController.didLongPressCell(_:)))
            cell.addGestureRecognizer(longPress)
        }
        if indexPath.section == 0 {
            self.makeTransparent(view: cell.backgroundView)
            self.makeTransparent(view: cell)
        } else {
            self.makeOpaque(view: cell.backgroundView)
        }
        cell.transform = tableView.transform
        //    cell.item = manager4.item(indexPath: indexPath)
        cell.item = manager.item(indexPath: indexPath, scrollView: tableView)
        //cell.configureSubviews()
        return cell
    }
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerCell = view as? RVFirstViewHeaderCell {
          //  print("In \(self.classForCoder).willDisplayHeaderView")
            if let datasource = manager.datasourceInSection(section: section) {
                headerCell.datasource4 = datasource
                headerCell.configure(model: datasource.sectionModel)
            }
            headerCell.delegate = self
          //  headerCell.configure(model: nil)
            headerCell.transform = tableView.transform
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let tableView = scrollView as? UITableView {
            if tableView == self.dsScrollView {
  
                if let indexPaths = tableView.indexPathsForVisibleRows {
                    if let first = indexPaths.first {
                        configuration.manager.scrolling(indexPath: first, scrollView: tableView)
                        //  self.manager4.scrolling(indexPath: first, scrollView: tableView)
                    }
                    if let last = indexPaths.last {
                        configuration.manager.scrolling(indexPath: last, scrollView: tableView)
                        //   self.manager4.scrolling(indexPath: last, scrollView: tableView)
                    }
                }

            }
        }
        super.scrollViewDidScroll(scrollView)
    }
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if configuration.manager.dynamicSections {
        }
        super.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
    }
}
// UITableViewDelegate
extension RVBaseSLKViewController4 {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }

}
// RVFirstViewHeaderCell
extension RVBaseSLKViewController4: RVFirstViewHeaderCellDelegate {
    func expandCollapseButtonTouched(view: RVFirstViewHeaderCell) {
        if let datasource = view.datasource4 {
            manager.toggle(datasource: datasource, callback: { (models, error ) in
                if let error = error {
                    error.append(message: "In \(self.classForCoder).expandCollapseBUtton line #\(#line), got error")
                    error.printError()
                } else {
                    // print("In \(self.classForCoder).expandCollapseButtonTouched. Successful return")
                }
            })
        }
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: RVFirstViewHeaderCell.identifier) as? RVFirstViewHeaderCell {
            return headerCell
        } else {
            return nil
        }
    }
}
// Notifications
extension RVBaseSLKViewController4 {
    func commonInit() {
        // Register a SLKTextView subclass, if you need any special appearance and/or behavior customisation.
        self.registerClass(forTextView: RVSlackMessageTextView.classForCoder())
        if DEBUG_CUSTOM_TYPING_INDICATOR == true {
            // Register a UIView subclass, conforming to SLKTypingIndicatorProtocol, to use a custom typing indicator view.
            // self.registerClass(forTypingIndicatorView: RVSlackTypingIndicatorView.classForCoder())
        }
        if let tableView = self.tableView {
            tableView.separatorStyle = .singleLine
            let nib = UINib(nibName: RVTransactionTableViewCell.identifier, bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: RVTransactionTableViewCell.identifier)
            tableView.register(RVFirstViewHeaderCell.self, forHeaderFooterViewReuseIdentifier: RVFirstViewHeaderCell.identifier)
        }
        self.autoCompletionView.register(RVMessageTableViewCell.classForCoder(), forCellReuseIdentifier: RVMessageTableViewCell.AutoCompletionCellIdentifier)
        NotificationCenter.default.addObserver(self.tableView!, selector: #selector(UITableView.reloadData), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
        NotificationCenter.default.addObserver(self,  selector: #selector(RVBaseSLKViewController4.textInputbarDidMove(_:)), name: NSNotification.Name.SLKTextInputbarDidMove, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RVBaseSLKViewController4.stateDidChange(_:)), name: NSNotification.Name(RVNotification.AppStateChanged.rawValue), object: nil)
    }
    func stateDidChange(_ notification: NSNotification) {
        print("In \(self.instanceType).stateDidChange")
        if let userInfo = notification.userInfo as? [String:AnyObject] {
            if let appState = userInfo["newAppState"] as? RVBaseAppState4 {
                print("and appState is \(appState.appState)")
            }
        }
    }
    func textInputbarDidMove(_ note: Notification) {
        guard let pipWindow = self.pipWindow else { return }
        guard let userInfo = (note as NSNotification).userInfo else { return }
        guard let value = userInfo["origin"] as? NSValue else { return }
        var frame = pipWindow.frame
        frame.origin.y = value.cgPointValue.y - 60.0
        pipWindow.frame = frame
    }
    func configureSLK() {
        
        
        // SLKTVC's configuration
        self.bounces = true
        self.shakeToClearEnabled = true
        self.isKeyboardPanningEnabled = true
        self.shouldScrollToBottomAfterKeyboardShows = false
        self.isInverted = self.SLKIsInverted
        if configuration.SLKshowTextInputBar {
            self.leftButton.setImage(UIImage(named: "icn_upload"), for: UIControlState())
            self.leftButton.tintColor = UIColor.gray
            
            self.rightButton.setTitle(NSLocalizedString("Send", comment: ""), for: UIControlState())
            // self.setTextInputbarHidden(false, animated: true)
            self.textInputbar.autoHideRightButton = true
            self.textInputbar.maxCharCount = 256
            self.textInputbar.counterStyle = .split
            self.textInputbar.counterPosition = .top
            
            self.textInputbar.editorTitle.textColor = UIColor.darkGray
            self.textInputbar.editorLeftButton.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
            self.textInputbar.editorRightButton.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
            
            if DEBUG_CUSTOM_TYPING_INDICATOR == false {
                self.typingIndicatorView!.canResignByTouch = true
            }
            self.registerPrefixes(forAutoCompletion: ["@",  "#", ":", "+:", "/"])
            
            self.textView.placeholder = "Message";
            
            self.textView.registerMarkdownFormattingSymbol("*", withTitle: "Bold")
            self.textView.registerMarkdownFormattingSymbol("_", withTitle: "Italics")
            self.textView.registerMarkdownFormattingSymbol("~", withTitle: "Strike")
            self.textView.registerMarkdownFormattingSymbol("`", withTitle: "Code")
            self.textView.registerMarkdownFormattingSymbol("```", withTitle: "Preformatted")
            self.textView.registerMarkdownFormattingSymbol(">", withTitle: "Quote")
        } else {
            self.setTextInputbarHidden(true, animated: false)
        }
    }
}
// Top Area
extension RVBaseSLKViewController4 {
    func adjustTableViewInsetForNavBar() {
        if navigationController != nil {
            if let tableView = self.dsScrollView {
                let inset = tableView.contentInset
                tableView.contentInset = UIEdgeInsets(top: inset.top + navBarHeight, left: inset.left, bottom: inset.bottom, right: inset.right)
            }
        }
    }
    var totalTopHeight: CGFloat {
        get {
            var height: CGFloat = 0.0
            height = (TopTopHeightConstraint    != nil) ? TopTopHeightConstraint.constant    + height : height
            height = (TopMiddleHeightConstraint != nil) ? TopMiddleHeightConstraint.constant + height : height
            height = (TopBottomHeightConstraint != nil) ? TopBottomHeightConstraint.constant + height : height
            return height
        }
    }
    func expandTopView() {
        setHeightConstraints(array: configuration.topAreaMaxHeights)
        self.updateTableViewInsetHeight()
    }
    func compressTopView() {
        setHeightConstraints(array: configuration.topAreaMinHeights)
        self.updateTableViewInsetHeight()
    }
    func zeroTopView() {
        setHeightConstraints(array: [0.0, 0.0, 0.0])
        self.updateTableViewInsetHeight()
    }
    func setHeightConstraints(array: [CGFloat]) {
        let top = 0; let middle = 1; let bottom = 2
        var cumulator: CGFloat = 0.0
        if array.count > top {
            changeConstraintConstant(constraint: self.TopTopHeightConstraint, newValue: array[top])
            cumulator = cumulator + array[top]
        } else {
            changeConstraintConstant(constraint: self.TopTopHeightConstraint, newValue: 0.0)
        }
        if array.count > middle {
            changeConstraintConstant(constraint: self.TopMiddleHeightConstraint, newValue: array[middle])
            cumulator = cumulator + array[middle]
        } else {
            changeConstraintConstant(constraint: self.TopMiddleHeightConstraint, newValue: 0.0)
        }
        if array.count > bottom {
            changeConstraintConstant(constraint: self.TopBottomHeightConstraint, newValue: array[bottom])
            cumulator = cumulator + array[bottom]
        } else {
            changeConstraintConstant(constraint: self.TopBottomHeightConstraint, newValue: 0.0)
        }
        if cumulator == 0 { self.hideTopView() }
        if cumulator == 0 { self.showTopView() }
    }
    func changeConstraintConstant(constraint: NSLayoutConstraint?, newValue: CGFloat) {
        if let constraint = constraint { constraint.constant = newValue }
    }
    func showTopView() { if let view = TopOuterView { view.isHidden = false } }
    func hideTopView() { if let view = TopOuterView { view.isHidden = true } }
    func putTopViewOnTop() {
        if let outerView = TopOuterView {
            self.view.bringSubview(toFront: outerView)
            outerView.isHidden = false
        }
    }
    func updateTableViewInsetHeight() {
        if let tableView = self.dsScrollView as? UITableView {
            let height = totalTopHeight - tableViewInsetAdditionalHeight
            tableViewInsetAdditionalHeight = totalTopHeight
            let inset = tableView.contentInset
            tableView.contentInset = UIEdgeInsets(top: inset.top + height, left: inset.left, bottom: inset.bottom, right: inset.right)
            // print("in \(instanceType) topAreaHeight = \(topAreaHeight) height = \(height), original top was: \(inset.top) and is now \(tableView.contentInset.top), additionalHeight : \(tableViewInsetAdditionalHeight)")
        } else {
            print("In \(self.classForCoder).updateTableViewInsetHeight no tableView")
        }
    }
    func configureNavBar() {
        if let navController = self.navigationController {
            //navController.navigationBar.barStyle = .black
            // navController.navigationBar.isTranslucent = false
            navController.navigationBar.barTintColor = configuration.navigationBarColor
            self.title = configuration.navigationBarTitle
            
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

    func loadMainOld(callback: @escaping(RVError?) -> Void) {
        let (query, error) = self.configuration.mainQuery()
        if let error = error {
            error.append(message: "In \(self.instanceType).loadMain, got error creating Query")
            callback(error)
        } else {
            self.configuration.loadMain(query: query, callback: { (error) in
                if let error = error {
                    error.append(message: "In \(self.instanceType).loadMain, got error")
                }
                callback(error)
            })
        }
    }
}

extension RVBaseSLKViewController4: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.isActive {
            let searchBar = searchController.searchBar
            let searchText = searchBar.text != nil ? searchBar.text! : ""
            var searchKey = RVKeys.title
            if searchBar.selectedScopeButtonIndex < searchScopes.count {
                let scope = searchScopes[searchBar.selectedScopeButtonIndex]
                if let (title, key) = scope.first {
                    searchKey = key
                    searchBar.placeholder = "Search by \(title)"
                } else {
                    searchBar.placeholder = "Search"
                }
            } else {
                searchBar.placeholder = "Search"
            }
            performSearch(searchText: searchText, field: searchKey, order: self.defaultSortOrder )
        } else {
            endSearch()
        }
    }
    func configureSearchController() {
        //print("In \(self.classForCoder).configureSearchController")
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchBar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        searchController.searchBar.barTintColor = UIColor.facebookBlue()
        searchController.dimsBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        searchController.searchBar.removeFromSuperview()
        if installSearchControllerInTableView {
            if let tableView = self.dsScrollView as? UITableView {
                tableView.tableHeaderView = searchController.searchBar
            }
        } else {
            if let containerView = self.searchControllerContainerView {
                containerView.addSubview(searchController.searchBar)
            } else {
                print("In \(self.instanceType).configureSearchController, no searchControllerContainerView")
            }
        }
    }
}
extension RVBaseSLKViewController4: UISearchControllerDelegate {
    // These methods are called when automatic presentation or dismissal occurs. They will not be called if you present or dismiss the search controller yourself.
    func willPresentSearchController(_ searchController: UISearchController) {
        configureScopeBar()
    }
    func configureScopeBar() {
        var scopeTitles = [String]()
        for scope in self.searchScopes { if let (title, _) = scope.first { scopeTitles.append(title) } }
        searchController.searchBar.scopeButtonTitles = scopeTitles
        searchController.searchBar.selectedScopeButtonIndex = 0
        searchController.searchBar.showsSearchResultsButton = false
        searchController.searchBar.placeholder = self.searchBarPlaceholder
    }
    
    
    func didPresentSearchController(_ searchController: UISearchController) {}
    
    func willDismissSearchController(_ searchController: UISearchController) {}
    
    func didDismissSearchController(_ searchController: UISearchController) {}
    
    // Called after the search controller's search bar has agreed to begin editing or when 'active' is set to YES. If you choose not to present the controller yourself or do not implement this method, a default presentation is performed on your behalf.
    func presentSearchController(_ searchController: UISearchController) {}
}
extension RVBaseSLKViewController4: UISearchBarDelegate {
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
// SLK Stuff
extension RVBaseSLKViewController4 {
    // MARK: - Overriden Methods
    
    override func ignoreTextInputbarAdjustment() -> Bool { return super.ignoreTextInputbarAdjustment() }
    
    override func forceTextInputbarAdjustment(for responder: UIResponder!) -> Bool {
        if #available(iOS 8.0, *) {
            guard let _ = responder as? UIAlertController else {
                // On iOS 9, returning YES helps keeping the input view visible when the keyboard if presented from another app when using multi-tasking on iPad.
                return UIDevice.current.userInterfaceIdiom == .pad
            }
            return true
        }
        else { return UIDevice.current.userInterfaceIdiom == .pad }
    }
    
    // Notifies the view controller that the keyboard changed status.
    override func didChangeKeyboardStatus(_ status: SLKKeyboardStatus) {
        switch status {
        case .willShow:
            print("Will Show Keyboard")
        case .didShow:
            print("Did Show Keyboard")
        case .willHide:
            print("Will Hide Keyboard")
        case .didHide:
            print("Did Hide Keyboard")
        }
    }
    
    // Notifies the view controller that the text will update.
    override func textWillUpdate() { super.textWillUpdate() }
    
    // Notifies the view controller that the text did update.
    override func textDidUpdate(_ animated: Bool) { super.textDidUpdate(animated) }
    
    // Notifies the view controller when the left button's action has been triggered, manually.
    override func didPressLeftButton(_ sender: Any!) {
        super.didPressLeftButton(sender)
        self.dismissKeyboard(true)
        print("IN \(self.classForCoder).needToImplement show camera")
        //  self.showCameraMenu()
    }
    func createTransaction(text: String, callback: @escaping()-> Void) {
        print("In \(self.classForCoder).createTransaction")
        let transaction = RVTransaction()
        if let loggedInUser = RVCoreInfo2.shared.loggedInUserProfile {
            transaction.targetUserProfileId = loggedInUser.localId
            transaction.entityId = loggedInUser.localId
            transaction.entityModelType = .userProfile
            transaction.entityTitle = loggedInUser.fullName
        }
        transaction.title = text
        transaction.everywhere = true
        transaction.transactionType = .updated
        transaction.create { (model, error) in
            if let error = error {
                error.printError()
            } else if let transaction = model as? RVTransaction {
                print("In \(self.instanceType).createTransaction, created transaction \(transaction.localId ?? " no LocalId") \(transaction.createdAt?.description ?? " no createdAt")")
            } else {
                print("In \(self.instanceType).createTransaction, no error, but no result ")
            }
            callback()
        }
    }
    // Notifies the view controller when the right button's action has been triggered, manually or by using the keyboard return key.
    override func didPressRightButton(_ sender: Any!) {
        
        if !setupSLKDatasource {
            super.didPressRightButton(sender)
            return
        }
        print("In \(self.classForCoder).didPressRightBUtton. should not be here")
        // This little trick validates any pending auto-correction or auto-spelling just after hitting the 'Send' button
        self.textView.refreshFirstResponder()
        
        self.createTransaction(text: self.textView.text) {
            let indexPath = IndexPath(row: 0, section: 0)
            //let rowAnimation: UITableViewRowAnimation = self.isInverted ? .bottom : .top
            let scrollPosition: UITableViewScrollPosition = self.isInverted ? .bottom : .top
            
            //        self.tableView.beginUpdates()
            //        self.messages.insert(message, at: 0)
            //        self.tableView.insertRows(at: [indexPath], with: rowAnimation)
            //        self.tableView.endUpdates()
            
            self.tableView?.scrollToRow(at: indexPath, at: scrollPosition, animated: true)
            
            // Fixes the cell from blinking (because of the transform, when using translucent cells)
            // See https://github.com/slackhq/SlackTextViewController/issues/94#issuecomment-69929927
            //   self.tableView?.reloadRows(at: [indexPath], with: .automatic)
        }
        super.didPressRightButton(sender)
    }
    
    override func didPressArrowKey(_ keyCommand: UIKeyCommand?) {
        
        guard let keyCommand = keyCommand else { return }
        
        if keyCommand.input == UIKeyInputUpArrow && self.textView.text.characters.count == 0 {
            //            self.editLastMessage(nil)
        }
        else {
            super.didPressArrowKey(keyCommand)
        }
    }
    
    override func keyForTextCaching() -> String? {
        
        return Bundle.main.bundleIdentifier
    }
    
    // Notifies the view controller when the user has pasted a media (image, video, etc) inside of the text view.
    override func didPasteMediaContent(_ userInfo: [AnyHashable: Any]) {
        
        super.didPasteMediaContent(userInfo)
        
        let mediaType = (userInfo[SLKTextViewPastedItemMediaType] as? NSNumber)?.intValue
        let contentType = userInfo[SLKTextViewPastedItemContentType]
        let data = userInfo[SLKTextViewPastedItemData]
        
        print("didPasteMediaContent : \(contentType ?? "no contentType") (type = \(mediaType?.description ?? " No mediaType") | data : \(data ?? " no data"))")
    }
    
    // Notifies the view controller when a user did shake the device to undo the typed text
    override func willRequestUndo() {
        super.willRequestUndo()
    }
    
    // Notifies the view controller when tapped on the right "Accept" button for commiting the edited text
    override func didCommitTextEditing(_ sender: Any) {
        
        //        self.editingMessage.text = self.textView.text
        //       self.tableView.reloadData()
        
        super.didCommitTextEditing(sender)
    }
    
    // Notifies the view controller when tapped on the left "Cancel" button
    override func didCancelTextEditing(_ sender: Any) { super.didCancelTextEditing(sender) }
    
    override func canPressRightButton() -> Bool {
        return super.canPressRightButton()
    }
    
    override func canShowTypingIndicator() -> Bool {
        
        if DEBUG_CUSTOM_TYPING_INDICATOR == true {
            return true
        }
        else {
            return super.canShowTypingIndicator()
        }
    }
    
    override func shouldProcessText(forAutoCompletion text: String) -> Bool {
        return true
    }
    
    override func didChangeAutoCompletionPrefix(_ prefix: String, andWord word: String) {
        
        var array:Array<String> = []
        let wordPredicate = NSPredicate(format: "self BEGINSWITH[c] %@", word);
        
        self.searchResult = nil
        
        if prefix == "@" {
            if word.characters.count > 0 {
                array = self.users.filter { wordPredicate.evaluate(with: $0) };
            }
            else {
                array = self.users
            }
        }
        else if prefix == "#" {
            
            if word.characters.count > 0 {
                array = self.channels.filter { wordPredicate.evaluate(with: $0) };
            }
            else {
                array = self.channels
            }
        }
        else if (prefix == ":" || prefix == "+:") && word.characters.count > 0 {
            array = self.emojis.filter { wordPredicate.evaluate(with: $0) };
        }
        else if prefix == "/" && self.foundPrefixRange.location == 0 {
            if word.characters.count > 0 {
                array = self.commands.filter { wordPredicate.evaluate(with: $0) };
            }
            else {
                array = self.commands
            }
        }
        
        var show = false
        
        if array.count > 0 {
            let sortedArray = array.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
            self.searchResult = sortedArray
            show = sortedArray.count > 0
        }
        
        self.showAutoCompletionView(show)
    }
    
    override func heightForAutoCompletionView() -> CGFloat {
        
        guard let searchResult = self.searchResult else {
            return 0
        }
        
        let cellHeight = self.autoCompletionView.delegate?.tableView!(self.autoCompletionView, heightForRowAt: IndexPath(row: 0, section: 0))
        guard let height = cellHeight else {
            return 0
        }
        return height * CGFloat(searchResult.count)
    }
    func simulateUserTyping(_ sender: AnyObject) {
        
        if !self.canShowTypingIndicator() { return }
        /*
         if DEBUG_CUSTOM_TYPING_INDICATOR == true {
         guard let view = self.typingIndicatorProxyView as? RVSlackTypingIndicatorView else {
         return
         }
         
         let scale = UIScreen.main.scale
         let imgSize = CGSize(width: RVSlackTypingIndicatorView.AvatarHeight*scale, height: RVSlackTypingIndicatorView.AvatarHeight*scale)
         
         // This will cause the typing indicator to show after a delay ¯\_(ツ)_/¯
         LoremIpsum.asyncPlaceholderImage(with: imgSize, completion: { (image) -> Void in
         guard let cgImage = image?.cgImage else {
         return
         }
         let thumbnail = UIImage(cgImage: cgImage, scale: scale, orientation: .up)
         view.presentIndicator(name: LoremIpsum.name(), image: thumbnail)
         })
         } else {
         */
        self.typingIndicatorView!.insertUsername("SomeUserName")
        // }
    }
    func autoCompletionCellForRowAtIndexPath(_ indexPath: IndexPath) -> RVMessageTableViewCell {
        print("In \(self.classForCoder).autoCompletionCellForRow. Wondering why this is being called")
        let cell = self.autoCompletionView.dequeueReusableCell(withIdentifier: RVMessageTableViewCell.AutoCompletionCellIdentifier) as! RVMessageTableViewCell
        cell.indexPath = indexPath
        cell.selectionStyle = .default
        
        guard let searchResult = self.searchResult else {
            return cell
        }
        
        guard let prefix = self.foundPrefix else {
            return cell
        }
        
        var text = searchResult[(indexPath as NSIndexPath).row]
        
        if prefix == "#" {
            text = "# " + text
        }
        else if prefix == ":" || prefix == "+:" {
            text = ":\(text):"
        }
        cell.titleLabel.text = text
        
        return cell
    }
    func didLongPressCell(_ gesture: UIGestureRecognizer) {
        
        guard let view = gesture.view else {
            return
        }
        
        if gesture.state != .began {
            return
        }
        
        if #available(iOS 8, *) {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alertController.modalPresentationStyle = .popover
            alertController.popoverPresentationController?.sourceView = view.superview
            alertController.popoverPresentationController?.sourceRect = view.frame
            
            alertController.addAction(UIAlertAction(title: "Edit Message", style: .default, handler: { [unowned self] (action) -> Void in
                //self.editCellMessage(gesture)
                print("In \(self.classForCoder).didLongPressCell action \(self)")
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.navigationController?.present(alertController, animated: true, completion: nil)
        }
        else {
            //self.editCellMessage(gesture)
        }
    }
}

