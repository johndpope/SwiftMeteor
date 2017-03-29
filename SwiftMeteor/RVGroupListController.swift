//
//  RVGroupListController.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/21/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
class RVGroupListController: RVTransactionListViewController {
    var manager4 = RVDSManager4(scrollView: nil)
    override func viewDidLoad() {
        manager4 = RVDSManager4(scrollView: self.dsScrollView)
        super.viewDidLoad()
        if let tableView = self.tableView {
            tableView.separatorStyle = .singleLine
            let nib = UINib(nibName: RVTransactionTableViewCell.identifier, bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: RVTransactionTableViewCell.identifier)
        }
        if let tableView = self.tableView { tableView.register(RVFirstViewHeaderCell.self, forHeaderFooterViewReuseIdentifier: RVFirstViewHeaderCell.identifier) }
        self.configuration = RVTransactionListConfiguration()
        configuration.configure(stack: self.stack) { }
    }
    override func performSearch(searchText: String, field: RVKeys, order: RVSortOrder = .ascending) {
        
    }
    override func freshenState(completion: @escaping (RVError?) -> Void) {
        completion(nil)
    }
    override func runConfiguration() {
        print("In \(self.classForCoder).runConfiguration")
        let datasource = RVTransactionDatasource44(manager: self.manager4, datasourceType: .main, maxSize: 300)
        manager4.appendSections(datasources: [datasource]) { (models, error) in
            if let error = error {
                error.printError()
            } else {
                print("In \(self.instanceType).runConfiguration success")
                let (query, error) = RVTransaction.basicQuery
                query.addSort(field: .createdAt, order: .descending)
                query.addAnd(term: .createdAt, value: Date() as AnyObject, comparison: .lte)
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
        
    }
    override func expandCollapseButtonTouched(view: RVFirstViewHeaderCell) {
        if let datasource = view.datasource4 {
            manager4.toggle(datasource: datasource, callback: { (models, error) in
                if let error = error {
                    error.printError()
                } else {
                    print("In \(self.classForCoder).expandCollapseButtonTouched. Successful return")
                }
            })
        }
    }
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerCell = view as? RVFirstViewHeaderCell {
            if let datasource = manager4.datasourceInSection(section: 0) {
               // headerCell.datasourceType = datasource.datasourceType
                headerCell.datasource4 = datasource
            }
            headerCell.delegate = self
            headerCell.configure(model: nil)
            headerCell.transform = tableView.transform
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int { return manager4.numberOfSections}
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return manager4.numberOfItems(section: section)}
    override func primaryCellForRowAtIndexPath(tableView: UITableView, _ indexPath: IndexPath) -> RVTransactionTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RVTransactionTableViewCell.identifier) as! RVTransactionTableViewCell
        if cell.gestureRecognizers?.count == nil {
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(RVMemberViewController.didLongPressCell(_:)))
            cell.addGestureRecognizer(longPress)
        }
        cell.item = manager4.item(indexPath: indexPath)
        cell.transform = tableView.transform
        cell.configureSubviews()
        return cell
    }
    
    override func endSearch() {
        
    }
    
}
