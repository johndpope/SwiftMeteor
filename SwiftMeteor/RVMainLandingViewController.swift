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

        /*
        RVSwiftDDP.sharedInstance.connect {

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
                } else if let _ = task {
                    self.p("In \(self.instanceType).viewDidLoad, have Root Task")

                } else {
                    self.p("In \(self.instanceType).viewDidLoad no error but no root task")
                }
            }
            let query = self.mainDatasource.basicQuery()
            query.addAnd(term: RVKeys.title, value: "Dee" as AnyObject, comparison: .regex)
            self.manager.startDatasource(datasource: self.mainDatasource, query: query) { (error ) in
                if let error = error {
                    print("In \(self.instanceType).subscribeToTasks(), got error starting task datasource")
                    error.printError()
                } else {
                   // print("In \(self.instanceType).viewDidLoad, started Datasource")
                }
            }
        }
 */

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let _ = RVSwiftDDP.sharedInstance.username {
            // do nothing for now
        } else {
            print("In \(self.instanceType).viewWillAppear, already connected ")
            loadup()
        }
    }
    func loadup() {
        RVSeed.createRootTask { (root, error) in
            if let error = error {
                error.printError()
                return
            } else if let root = root {
              //  print("In \(self.instanceType).loadup() Have root task: \(root._id), \(root.special.rawValue)")
                self.stack = [root]
                let query = self.mainDatasource.basicQuery()
                if let top = self.stack.last {
                    query.addAnd(term: RVKeys.parentId, value: top._id as AnyObject, comparison: .eq)
                    query.addAnd(term: RVKeys.parentModelType, value: top.modelType.rawValue as AnyObject, comparison: .eq )
                }
                self.manager.startDatasource(datasource: self.mainDatasource, query: query, callback: { (error) in
                    if let error = error {
                        error.append(message: "In \(self.instanceType).loadUp, got error starting main database")
                        error.printError()
                    }
                })
            } else {
                print("In \(self.instanceType).loadup no root")
            }
            //RVSeed.populateTasks(count: 200)
        }
        /*
        RVSeed.createTaskRoot { (task, error) in
            if let error = error {
                error.printError()
            } else if let root = task {
                //self.p("In \(self.instanceType).viewDidLoad, have Root Task")
                self.stack = [root]
                let query = self.mainDatasource.basicQuery()
                if let top = self.stack.last {
                    query.addAnd(term: RVKeys.parentId, value: top._id as AnyObject, comparison: .eq)
                    query.addAnd(term: RVKeys.parentModelType, value: top.modelType.rawValue as AnyObject, comparison: .eq )
                }
                self.manager.startDatasource(datasource: self.mainDatasource, query: query, callback: { (error) in
                    if let error = error {
                        error.append(message: "In \(self.instanceType).loadUp, got error starting main database")
                        error.printError()
                    }
                })
            } else {
                self.p("In \(self.instanceType).viewDidLoad no error but no root task")
            }
        }
 */
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
        return query
    }
    override func filterQuery(text: String ) -> RVQuery {
        let query = filterDatasource.basicQuery().duplicate()
        query.setTextSearch(value: text.lowercased())
        if let top = self.stack.last {
            query.addAnd(term: RVKeys.parentId, value: top._id as AnyObject, comparison: .eq)
            query.addAnd(term: RVKeys.parentModelType, value: top.modelType.rawValue as AnyObject, comparison: .eq )
        }
        query.removeAllSortTerms()
        query.limit = 100
      //  query.addSort(field: .handleLowercase, order: .ascending)
        return query
    }
    override func userDidLogin(notification: NSNotification) {
        //print("In \(self.instanceType).userDidLogin notification target")
        loadup()
        
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
       // print("Header section \(view.section)")
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
extension RVMainLandingViewController {
    func setUpTasks(root: RVTask) {
        let query = RVQuery()
        query.limit = 700
        query.addAnd(term: RVKeys._id, value: root._id as AnyObject, comparison: .ne)
        query.addSort(field: .createdAt, order: .descending)
        query.addAnd(term: .createdAt, value: EJSON.convertToEJSONDate(Date()) as AnyObject, comparison: .lte)
        RVTask.bulkQuery(query: query, callback: { (models, error) in
            if let error = error {
                error.printError()
            } else if let models = models {
                var index = 0
                for model in models {
                    if let task = model as? RVTask {
                        print("\(index) In \(self.instanceType).viewDidLoad, parentID = \(task.parentId), model = \(task.parentModelType)")
                        index = index + 1
                        /*
                         task.parentId = root._id
                         task.parentModelType = root.modelType
                         task.update(callback: { (error) in
                         if let error = error {
                         error.printError()
                         }
                         })
                         */
                    }
                }
            }
        })
        //  RVSeed.populateTasks(count: 20)
    }
}
