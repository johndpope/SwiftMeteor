//
//  RVMainLandingViewController.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/4/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
import SwiftDDP

class RVMainLandingViewController: RVBaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentView: UIView!
    @IBOutlet weak var segmentedView: UIView!
    @IBOutlet weak var segmentedViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var refreshControl = UIRefreshControl()
    let topConstraintDelta: CGFloat = 30.0
    var segmentedViewTopConstraintConstant:CGFloat = 0.0
    var tableViewTopConstraintConstant: CGFloat = 0.0
  //  var taskDatasource = RVTaskDatasource()
   // var filterDatasource = RVTaskDatasource()
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
    }
    
    @IBAction func doneButtonTouched(_ sender: UIBarButtonItem) {
        RVViewDeck.sharedInstance.toggleSide(side: RVViewDeck.Side.left)
    }
    @IBAction func searchButtonTouched(_ sender: UIBarButtonItem) {
        showSearchBar()
        segmentedView.isHidden = false
    }
    override func viewDidLoad() {
        //RVSeed.tryIt()

        self.dsScrollView = tableView
        mainDatasource = RVTaskDatasource()
        filterDatasource = RVTaskDatasource()
        super.viewDidLoad()
        tableView.register(RVFirstViewHeaderCell.self, forHeaderFooterViewReuseIdentifier: RVFirstViewHeaderCell.identifier)
        Meteor.connect("wss://rnmpassword-nweintraut.c9users.io/websocket") {
            // do something after the client connects
            print("Returned after connect")
            /*
             Meteor.loginWithUsername("neil.weintraut@gmail.com", password: "password", callback: { (result, error: DDPError?) in
             if let error = error {
             print(error)
             } else {
             print("After loginWIthUsernmae \(result)")
             }
             })
             */
            
            RVSeed.createTaskRoot { (task, error) in
                if let error = error {
                    error.printError()
                } else if task != nil {
                    self.p("In \(self.instanceType).viewDidLoad, have Root Task")
                  //  RVSeed.populateTasks(count: 20)
                } else {
                    self.p("In \(self.instanceType).viewDidLoad no error but no root task")
                }
            }
 
            self.manager.startDatasource(datasource: self.mainDatasource, query: self.mainDatasource.basicQuery()) { (error ) in
                if let error = error {
                    print("In \(self.instanceType).subscribeToTasks(), got error starting task datasource")
                    error.printError()
                } else {
                   // print("In \(self.instanceType).viewDidLoad, started Datasource")
                }
            }
        }

    }
    func userDidLogin() {
        print("The user just signed in!")
    }
    func filterQuery0(text: String ) -> RVQuery {
        let query = filterDatasource.basicQuery().duplicate()
        query.addAnd(term: RVKeys.handleLowercase, value: text.lowercased() as AnyObject, comparison: .gte)
        query.fixedTerm = RVQueryItem(term: RVKeys.handleLowercase, value: text.lowercased() as AnyObject, comparison: .gte)
        query.removeAllSortTerms()
        query.addSort(field: .handleLowercase, order: .ascending)
        filterDatasource.inSearchTermMode = false
        return query
    }
    override func filterQuery(text: String ) -> RVQuery {
        let query = filterDatasource.basicQuery().duplicate()
        query.setTextSearch(value: text.lowercased())
        query.removeAllSortTerms()
        filterDatasource.inSearchTermMode = true
        query.limit = 100
      //  query.addSort(field: .handleLowercase, order: .ascending)
        return query
    }
}

extension RVMainLandingViewController {
    override func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        super.searchBarCancelButtonClicked(searchBar)
        segmentedView.isHidden = true
    }
    override func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
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

}
extension RVMainLandingViewController: RVFirstHeaderContentViewDelegate{
    func expandCollapseButtonTouched(button: UIButton, view: RVFirstHeaderContentView) -> Void {
        print("Header section \(view.section)")
        if view.section >= 0 {
            let datasource =  manager.sections[view.section]
            if !datasource.collapsed { datasource.collapse {
                print("return from collapse")
                }
            } else {
                datasource.expand {
                    print("return from expand")
                }
            }
        }
        print("Expand / Collapse")
    }
}
extension RVMainLandingViewController {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }
    func loadHeaderFromNib() -> RVFirstHeaderContentView? {
        let bundle = Bundle(for: RVFirstHeaderContentView.self)
        let nib = UINib(nibName: "RVFirstHeaderContentView", bundle: bundle)
        if let view = nib.instantiate(withOwner: self, options: nil)[0] as? RVFirstHeaderContentView {
            return view
        }
        return nil
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerCell = view as? RVFirstViewHeaderCell {
            let contentView = headerCell.contentView
            for subview in contentView.subviews {
                if let _ = subview as? RVFirstHeaderContentView {
                    print("In \(self.instanceType).willDisplayHeaderInSection, found target")
                    return
                }
            }
            if let target = loadHeaderFromNib() {
                target.frame = headerCell.contentView.bounds
                target.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                contentView.addSubview(target)
                target.delegate = self
                target.section = section
                target.configure(section: section, expand: true)
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
    /*
     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
     return "Section \(section)"
     }
     */
}
extension RVMainLandingViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //    print("In \(self.instanceType).cellForRow...")
        if let cell = tableView.dequeueReusableCell(withIdentifier: RVTaskTableViewCell.identifier, for: indexPath) as? RVTaskTableViewCell {
            cell.model = manager.item(indexPath: indexPath)
            return cell
        } else {
            print("In \(self.instanceType).cellForRowAt, did not dequeue first cell type")
        }
        return UITableViewCell()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //    print("In \(self.classForCoder).numberOfRowsInSection \(section) \(manager.numberOfItems(section: section))")
        return manager.numberOfItems(section: section)
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
      //  print("In \(self.classForCoder).numberOfSections... \(manager.sections.count)")
        let count = manager.sections.count
        if count == 0 {
            
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
            messageLabel.text = "No data is currently available. Please pull down to refresh."
            messageLabel.textColor = UIColor.black
            messageLabel.textAlignment = NSTextAlignment.center
            messageLabel.font = UIFont(name: "Palatino-Italic", size: 20)
            messageLabel.sizeToFit()
            self.tableView.backgroundView = messageLabel
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        } else {
            self.tableView.backgroundView = self.refreshControl
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLineEtched
        }
        return count
    }
    func installRefresh() {
        self.refreshControl.backgroundColor = UIColor.purple
        self.refreshControl.tintColor = UIColor.white
        self.refreshControl.addTarget(self , action: #selector(refresh), for: UIControlEvents.valueChanged)
        self.tableView.backgroundView = self.refreshControl
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLineEtched
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
