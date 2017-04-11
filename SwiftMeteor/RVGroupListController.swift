//
//  RVGroupListController.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/21/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
class RVGroupListController: RVTransactionListViewController {
    var manager4 = RVDSManager5<RVBaseModel>(scrollView: nil, managerType: .filter)
    var configuration4 = RVTransactionConfiguration4(scrollView: nil)
    var lastSearchTerm: String = "DummyValue"
    override var installSearchControllerInTableView: Bool { get { return false }}
    

    override func viewDidLoad() {
        //manager4 = RVDSManager5<RVBaseModel>(scrollView: self.dsScrollView)
        configuration4 = RVTransactionConfiguration4(scrollView: self.dsScrollView)
        super.viewDidLoad()
        if let tableView = self.tableView {
            tableView.separatorStyle = .singleLine
            let nib = UINib(nibName: RVTransactionTableViewCell.identifier, bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: RVTransactionTableViewCell.identifier)
        }
        if let tableView = self.tableView { tableView.register(RVFirstViewHeaderCell.self, forHeaderFooterViewReuseIdentifier: RVFirstViewHeaderCell.identifier) }
        
     //   self.updateTableViewInsetHeight()
        configureNavBar()
      //  putTopViewOnTop()
        configureSearchController()

        
        //self.configuration = RVTransactionListConfiguration()
        //configuration.configure(stack: self.stack) { }
        let (query, _) = configuration4.topQuery()
        print("In \(self.classForCoder).viewDidLoad query: \(query)")
        configuration4.loadTop(query: query, callback: { (error) in
            print("In \(self.classForCoder).viewDidLoad query: \(query)")
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
    }
    func loadMain(callback: @escaping(RVError?) -> Void) {
        let (query, error) = self.configuration4.mainQuery()
        if let error = error {
             error.append(message: "In \(self.instanceType).loadMain, got error creating Query")
            callback(error)
        } else {
            self.configuration4.loadMain(query: query, callback: { (error) in
                if let error = error {
                    error.append(message: "In \(self.instanceType).loadMain, got error")
                }
                callback(error)
            })
        }
    }
    override func performSearch(searchText: String, field: RVKeys, order: RVSortOrder = .ascending) {
        print("In \(self.classForCoder).performSearch \(searchText), field: \(field.rawValue) \(order.rawValue)")
        if lastSearchTerm == searchText { return }
        lastSearchTerm = searchText.lowercased()
        let matchTerm = RVQueryItem(term: field, value: searchText.lowercased() as AnyObject, comparison: .regex)
        let andTerms = [RVQueryItem]()
        let (query, error) = self.configuration4.filterQuery(andTerms: andTerms, matchTerm: matchTerm, sortTerm: RVSortTerm(field: field, order: order))
        if let error = error {
            error.printError()
        } else {
            self.configuration4.loadSearch(query: query) { (error) in
                if let error = error {
                    error.printError()
                }
            }
        }

    }
    override func freshenState(completion: @escaping (RVError?) -> Void) {
        completion(nil)
    }
    func date() -> Date {
        let dateFormatter = DateFormatter()
        let dateAsString = "2017-03-27 20:09"
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.date(from: dateAsString)!
        
    }
    override func runConfiguration() {
        /*
        print("In \(self.classForCoder).runConfiguration")
        let datasource = RVTransactionDatasource44(manager: self.manager4, datasourceType: .main, maxSize: 100)
        datasource.subscription = RVTransactionSubscription(front: true , showResponse: false)
        manager4.appendSections(datasources: [datasource]) { (models, error) in
            if let error = error {
                error.printError()
            } else {
                print("In \(self.instanceType).runConfiguration success adding section")
                let (query, _) = RVTransaction.baseQuery
                query.addSort(field: .createdAt, order: .descending)
            //    query.addAnd(term: .createdAt, value: Date() as AnyObject, comparison: .lte)
                                query.addAnd(term: .createdAt, value: self.date() as AnyObject, comparison: .lte)
                self.manager4.restart(datasource: datasource, query: query, callback: { (models, error) in
                    if let error = error {
                        error.append(message: "In \(self.classForCoder).runConfiguration, got error")
                        error.printError()
                    } else {
                        print("In \(self.classForCoder) successfully started datasource")
                    }
                })
            }
        }
 */
        
    }
    override func expandCollapseButtonTouched(view: RVFirstViewHeaderCell) {
        if let datasource = view.datasource4 {
            configuration4.manager.toggle(datasource: datasource) { (models, error) in
                if let error = error {
                    error.printError()
                } else {
                  // print("In \(self.classForCoder).expandCollapseButtonTouched. Successful return")
                }
            }
        }

        if let datasource = view.datasource4 {
            manager4.toggle(datasource: datasource, callback: { (models, error) in
                if let error = error {
                    error.printError()
                } else {
                   // print("In \(self.classForCoder).expandCollapseButtonTouched. Successful return")
                }
            })
        }
    }
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        print("In \(self.classForCoder).willDisplayHeaderView....")
        if let headerCell = view as? RVFirstViewHeaderCell {
            /*
            if let datasource = manager4.datasourceInSection(section: 0) {
               // headerCell.datasourceType = datasource.datasourceType
                headerCell.datasource4 = datasource
            }
 */
            if let datasource = configuration4.manager.datasourceInSection(section: section) {
                headerCell.datasource4 = datasource
            }
            headerCell.delegate = self
            headerCell.configure(model: nil)
            headerCell.transform = tableView.transform
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return configuration4.manager.numberOfSections
      //  return manager4.numberOfSections
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return configuration4.manager.numberOfItems(section: section)
      //  return manager4.numberOfItems(section: section)
    }
    override func primaryCellForRowAtIndexPath(tableView: UITableView, _ indexPath: IndexPath) -> RVTransactionTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RVTransactionTableViewCell.identifier) as! RVTransactionTableViewCell
        if cell.gestureRecognizers?.count == nil {
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(RVMemberViewController.didLongPressCell(_:)))
            cell.addGestureRecognizer(longPress)
        }
        cell.transform = tableView.transform
    //    cell.item = manager4.item(indexPath: indexPath)
        cell.item = configuration4.manager.item(indexPath: indexPath, scrollView: tableView)
        //cell.configureSubviews()
        return cell
    }
    
    override func endSearch() {
        self.loadMain { (error) in
            if let error = error {
                error.append(message: "In \(self.classForCoder).endSearch, got error")
            }
        }
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let tableView = scrollView as? UITableView {
            if tableView == self.dsScrollView {
                if let indexPaths = tableView.indexPathsForVisibleRows {
                    if let first = indexPaths.first {
                        configuration4.manager.scrolling(indexPath: first, scrollView: tableView)
                      //  self.manager4.scrolling(indexPath: first, scrollView: tableView)
                    }
                    if let last = indexPaths.last {
                        configuration4.manager.scrolling(indexPath: last, scrollView: tableView)
                     //   self.manager4.scrolling(indexPath: last, scrollView: tableView)
                    }
                }
            }
        }
    }
    
}
