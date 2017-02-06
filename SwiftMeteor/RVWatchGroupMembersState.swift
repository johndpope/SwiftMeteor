//
//  RVWatchGroupMembers.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/28/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
class RVWatchGroupMembersState: RVWatchGroupInfoState {
    override func configure() {
        super.configure()
        showTopView = true
        self.state = .WatchGroupMembers
        configure2() // temporary NEIL
    }
    
    
    // Temporary
    override func initialize(scrollView: UIScrollView?, callback: @escaping (_ error: RVError?) -> Void) {
        self.manager = RVDSManager(scrollView: scrollView )
        if self.stack.count < 2 {
            print("In \(self.instanceType).initialize, stack count is less than 2")
        } else {
            loadMain(callback: callback)
        }
        /*
        if let domain = RVCoreInfo.sharedInstance.domain {
            stack = [domain]
            self.loadMain()
        } else {
            RVCoreInfo.sharedInstance.getDomain(callback: { (domain , error) in
                if let error = error {
                    error.append(message: "In \(self.instanceType).initialize, error getting domain")
                    error.printError()
                } else if let domain = domain {
                    self.stack = [domain]
                    self.loadMain()
                } else {
                    print("In \(self.instanceType).initialize, no error but no domain")
                }
            })
        }
 */
    }
    override func loadMain(callback: @escaping (_ error: RVError?) -> Void) {
        // self.clearAndCreateWatchGroups()
        for datasource in datasources { manager.addSection(section: datasource)}
        if let mainDatasource = self.findDatasource(type: RVBaseDataSource.DatasourceType.main) {
            if let queryFunction = self.queryFunctions[RVBaseDataSource.DatasourceType.main] {
                let query = queryFunction([String: AnyObject]())
                self.manager.stopAndResetDatasource(datasource: mainDatasource, callback: { (error) in
                    if let error = error {
                        error.append(message: "In \(self.instanceType).loadMain, got error stoping main database")
                        error.printError()
                    } else {
                        self.manager.startDatasource(datasource: mainDatasource, query: query, callback: { (error) in
                            if let error = error {
                                error.append(message: "In \(self.instanceType).loadMain, got error starting main database")
                                error.printError()
                            } else {
                                // print("In \(self.instanceType).loadMain, completed start")
                            }
                        })
                    }
                })
                return
            } else {
                print("In \(self.instanceType).loadMain, no queryFunction")
            }
        } else {
            print("In \(self.instanceType).loadMain, no mainDatasource")
        }
    }
}
extension RVWatchGroupMembersState {
    func configure2() {
       // showTopView = false
        //        showTopView = true
        let mainDatasource = RVWatchGroupDatasource()
        mainDatasource.datasourceType =  .main
        datasources.append(mainDatasource)
        let filterDatasource = RVWatchGroupDatasource(maxArraySize: 300, filterMode: true)
        filterDatasource.datasourceType = .filter
        datasources.append(filterDatasource)

        let mainQuery: queryFunction = {(params) in
            let query = mainDatasource.basicQuery()
            if let _ = self.stack.first as? RVDomain {
                if let group = self.stack[1] as? RVWatchGroup {
                    if let groupId = group.localId {
                        query.addAnd(term: .followedId, value: groupId as AnyObject, comparison: .eq)
                        query.addSort(field: .fullName, order: .ascending)
                        query.addAnd(term: .fullName, value: "" as AnyObject, comparison: .gte)
                        return query
                    }
                }
            }
            print("In \(self.instanceType).configure2, missing domain or gruop")
            return query
        }
        queryFunctions[.main] = mainQuery
        let filterQuery: queryFunction = {(params) in
            let query = mainDatasource.basicQuery()
            query.removeAllSortTerms()
            if let _ = self.stack.first as? RVDomain {
                if let group = self.stack[1] as? RVWatchGroup {
                    if let groupId = group.localId {
                        query.addAnd(term: .followedId, value: groupId as AnyObject, comparison: .eq)

                        query.addAnd(term: .fullName, value: "" as AnyObject, comparison: .gte)
                        if let text = params[RVMainViewControllerState.textLabel] as? String {
                            query.fixedTerm = RVQueryItem(term: .fullName, value: text.lowercased() as AnyObject, comparison: .regex)
                            query.addSort(field: .fullName, order: .ascending)
                        } else {
                            print("IN \(self.instanceType).configure, filterQueryFunction, setting fixedTerm to .title, no text")
                            query.fixedTerm = RVQueryItem(term: .fullName, value: "a" as AnyObject, comparison: .regex)
                            query.addSort(field: .fullName, order: .ascending)
                        }
                        return query
                    }
                }
            }
            print("In \(self.instanceType).configure2, missing domain or gruop")
            return query
        }
        queryFunctions[.filter] = filterQuery
    }


}
