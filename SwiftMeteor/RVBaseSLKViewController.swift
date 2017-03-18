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
    var pipWindow: UIWindow?
    var commonInitDone: Bool = false
    var configuration: RVBaseConfiguration = RVBaseConfiguration()
    var stack = [RVBaseModel]()
    var tableViewInsetAdditionalHeight: CGFloat = 0.0
    //var manager = RVDSManager2()
    let searchController = UISearchController(searchResultsController: nil)
    var searchScopes: [String] { get {return ["Elmer", "Fudd"]}}
    var installSearchControllerInTableView: Bool { get { return false }}
    var searchBarPlaceholder: String { get { return "Search..." }}
    
    var dsScrollView: UIScrollView? {return self.tableView }
    var instanceType: String { get { return String(describing: type(of: self)) } }
    var deck: RVViewDeck { get { return RVViewDeck.sharedInstance }}
    
    var searchResult: [String]? // for SLKTextViewController, not sure why
    @IBAction func searchButtonTouched(_ sender: UIBarButtonItem) { searchController.isActive = true }
    @IBAction func menuButtonTouched(_ sender: UIBarButtonItem) { self.deck.toggleSide(side: .left) }
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
    func hideTopView() { if let view = TopOuterView { view.isHidden = true } }
    func putTopViewOnTop() {
        if let outerView = TopOuterView {
            self.view.bringSubview(toFront: outerView)
            outerView.isHidden = false
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.commonInit()
        if navigationController != nil {
            let navBarHeight: CGFloat = 62.0
            if let tableView = self.dsScrollView {
                let inset = tableView.contentInset
                tableView.contentInset = UIEdgeInsets(top: inset.top + navBarHeight, left: inset.left, bottom: inset.bottom, right: inset.right)
            }

        }
    }
    override func viewWillAppear(_ animated: Bool) {
        self.configureSLK()
     //   self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        super.viewWillAppear(animated)
        if !configuration.loaded {
            configuration.manager.scrollView = self.tableView
            configuration.configure(stack: self.stack, callback: {
                self.configuration.install(scrollView: self.tableView, callback: { (error) in
                    if let error = error {
                        error.append(message: "In \(self.classForCoder).viewWillAppear, got install error")
                        error.printError()
                    } else {
                       // print("In \(self.classForCoder).viewWillAPpear, returned from install")
                        self.updateTableViewInsetHeight()
                        self.configureNavBar()
                        self.putTopViewOnTop()
                        self.configureSearchController()
                    }
                })
            })
        } else {
            self.updateTableViewInsetHeight()
            configureNavBar()
            putTopViewOnTop()
            configureSearchController()
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
}
// SLK Configuration
extension RVBaseSLKViewController {
    func configureSLK() {


        // SLKTVC's configuration
        self.bounces = true
        self.shakeToClearEnabled = true
        self.isKeyboardPanningEnabled = true
        self.shouldScrollToBottomAfterKeyboardShows = false
        self.isInverted = configuration.SLKIsInverted
        
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
    }
    func commonInit() {
        if commonInitDone { return }
        commonInitDone = true
        // Register a SLKTextView subclass, if you need any special appearance and/or behavior customisation.
        self.registerClass(forTextView: RVSlackMessageTextView.classForCoder())
        if DEBUG_CUSTOM_TYPING_INDICATOR == true {
            // Register a UIView subclass, conforming to SLKTypingIndicatorProtocol, to use a custom typing indicator view.
            // self.registerClass(forTypingIndicatorView: RVSlackTypingIndicatorView.classForCoder())
        }
        self.autoCompletionView.register(RVMessageTableViewCell.classForCoder(), forCellReuseIdentifier: RVMessageTableViewCell.AutoCompletionCellIdentifier)
        NotificationCenter.default.addObserver(self.tableView!, selector: #selector(UITableView.reloadData), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
        NotificationCenter.default.addObserver(self,  selector: #selector(RVMemberViewController.textInputbarDidMove(_:)), name: NSNotification.Name.SLKTextInputbarDidMove, object: nil)
    }
    func textInputbarDidMove(_ note: Notification) {
        guard let pipWindow = self.pipWindow else { return }
        guard let userInfo = (note as NSNotification).userInfo else { return }
        guard let value = userInfo["origin"] as? NSValue else { return }
        var frame = pipWindow.frame
        frame.origin.y = value.cgPointValue.y - 60.0
        pipWindow.frame = frame
    }
}
extension RVBaseSLKViewController: RVFirstViewHeaderCellDelegate {
    func expandCollapseButtonTouched(view: RVFirstViewHeaderCell) -> Void {
        let transaction = RVTransaction()
        if let loggedInUser = RVCoreInfo2.shared.loggedInUserProfile {
            transaction.targetUserProfileId = loggedInUser.localId
            transaction.entityId = loggedInUser.localId
            transaction.entityModelType = .userProfile
            transaction.entityTitle = loggedInUser.fullName
        }
        transaction.transactionType = .added
        transaction.create { (model, error) in
            if let error = error {
                error.printError()
            } else if let transaction = model as? RVTransaction {
                print("In \(self.instanceType).expandCollapse, created transaction \(transaction.localId) \(transaction.createdAt)")
            } else {
                 print("In \(self.instanceType).expandCollapse, no error, but no result ")
            }
        }


        if let datasource = view.datasource {
            datasource.toggle {}
        } else {
            print("In \(self.instanceType).expandCollapseButtonTOuched no datasource")
        }
    }
}
// UITableViewDelegate 

extension RVBaseSLKViewController {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
      //  return 35.0
        return 40.0
    }
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerCell = view as? RVFirstViewHeaderCell {
            if section >= 0 && section < configuration.manager.sections.count {
                let datasource = configuration.manager.sections[section]
                headerCell.delegate = self
                headerCell.configure(model: nil, datasource: datasource)
                headerCell.transform = tableView.transform
            }
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


// UITableViewDatasource
extension RVBaseSLKViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if tableView == self.tableView {
            //print("In \(self.classForCoder).numberOfSections \(configuration.manager.numberOfSections(scrollView: tableView))")
            return configuration.manager.numberOfSections(scrollView: tableView)
        } else {
            // print("In \(self.classForCoder).numberOfSections not self tableView")
            return 1
        }
        
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return configuration.manager.numberOfItems(section: section)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            return primaryCellForRowAtIndexPath(tableView: tableView, indexPath)
        } else {
            return self.autoCompletionCellForRowAtIndexPath(indexPath)
        }
    }
    func primaryCellForRowAtIndexPath(tableView: UITableView, _ indexPath: IndexPath) -> RVTransactionTableViewCell {
       // print("IN \(self.classForCoder).messageCellForRowAtIndexPath")
        let cell = tableView.dequeueReusableCell(withIdentifier: RVTransactionTableViewCell.identifier) as! RVTransactionTableViewCell
        
        if cell.gestureRecognizers?.count == nil {
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(RVMemberViewController.didLongPressCell(_:)))
            cell.addGestureRecognizer(longPress)
        }
        cell.item = configuration.manager.item(indexPath: indexPath)
 

        
        //        cell.titleLabel.text = message.username
        //        cell.bodyLabel.text = message.text
//        cell.messageContentLabel.text = message.text
//        cell.titleLabel.text = message.username
        cell.configureSubviews()
      //  cell.indexPath = indexPath
     //   cell.usedForMessage = true
        
        
        
        // Cells must inherit the table view's transform
        // This is very important, since the main table view may be inverted
        cell.transform = tableView.transform
        
        return cell
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
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.navigationController?.present(alertController, animated: true, completion: nil)
        }
        else {
            //self.editCellMessage(gesture)
        }
    }
}
extension RVBaseSLKViewController: UISearchResultsUpdating {
    
    func configureSearchController() {
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
