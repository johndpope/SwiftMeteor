//
//  RVBaseViewController.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 11/27/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import UIKit

class RVBaseViewController: RVSlackMessageController {
    var instanceType: String { get { return String(describing: type(of: self)) } }
    let stack = [RVBaseModel]()
 //   weak var scrollView: UIScrollView? // NEIL!
    var manager: RVDSManager!
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchBar()
        if let scrollView = self.scrollView {
            self.manager = RVDSManager(scrollView: scrollView)
        } else {
            print("In \(instanceType).viewDidLoad, scrollView not set")
        }
    }
    func p(_ message: String, _ method: String = "") {
        print("In \(instanceType) \(method) \(message)")
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
    
    // Slack
//    var emojis: Array = ["-1", "m", "man", "machine", "block-a", "block-b", "bowtie", "boar", "boat", "book", "bookmark", "neckbeard", "metal", "fu", "feelsgood"]
//    var commands: Array = ["msg", "call", "text", "skype", "kick", "invite"]
}
extension RVBaseViewController {
// extension RVBaseViewController: UITableViewDelegate {
    /*
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("In \(instanceType).didSelectRowAt, not overridded")
    }
 */
}
extension RVBaseViewController {
// extension RVBaseViewController: UITableViewDataSource {
    /*
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
 */
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
// Slack
extension RVBaseViewController {
    /*
    func commonSlackInit() {
        NotificationCenter.default.addObserver(self.tableView, selector: #selector(UITableView.reloadData), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
        NotificationCenter.default.addObserver(self,  selector: #selector(MessageViewController.textInputbarDidMove(_:)), name: NSNotification.Name.SLKTextInputbarDidMove, object: nil)
    }
 */
}
