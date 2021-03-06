//
//  RVWatchGroupState.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/27/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
class RVWatchGroupListState: RVMainViewControllerState {
    override func configure() {
        self.state = .WatchGroupList
        scopes = [["Handle": RVKeys.handle], ["Title": RVKeys.title]  , ["Comment": RVKeys.comment]]
        showTopView = false
//        showTopView = true
        let mainDatasource = RVWatchGroupDatasource()
        mainDatasource.datasourceType =  .main
        datasources.append(mainDatasource)
        let filterDatasource = RVWatchGroupDatasource(maxArraySize: 300, filterMode: true)
        filterDatasource.datasourceType = .filter
        datasources.append(filterDatasource)
//        for datasource in datasources { manager.addSection(section: datasource) }
        let mainQuery: queryFunction = {(params) in
            let query = mainDatasource.basicQuery()
            if let top = self.stack.last {
                query.addAnd(term: .domainId, value: top.localId as AnyObject, comparison: .eq)
            }
            query.addAnd(term: .title, value: "" as AnyObject, comparison: .gte)
            query.addSort(field: .title, order: .ascending)
            return query
        }
        queryFunctions[.main] = mainQuery
        let filterQuery: queryFunction = {(params) in
            let query = filterDatasource.basicQuery()
            query.removeAllSortTerms()
            if let top = self.stack.last {
                query.addAnd(term: .domainId, value: top.localId as AnyObject, comparison: .eq)
            }
            if let text = params[RVMainViewControllerState.textLabel] as? String {
                query.fixedTerm = RVQueryItem(term: .title, value: text.lowercased() as AnyObject, comparison: .regex)
                query.addSort(field: .title, order: .ascending)
            } else {
                print("IN \(self.instanceType).configure, filterQueryFunction, setting fixedTerm to .title, no text")
                query.fixedTerm = RVQueryItem(term: .title, value: "a" as AnyObject, comparison: .regex)
                query.addSort(field: .title, order: .ascending)
            }
            return query
        }
        queryFunctions[.filter] = filterQuery
    }
    override func initialize(scrollView: UIScrollView?, callback: @escaping (_ error: RVError?) -> Void) {
        self.manager = RVDSManager(scrollView: scrollView)
        if let domain = RVBaseCoreInfo8.sharedInstance.domain {
            stack = [domain]
            self.loadMain(callback: callback)
        } else {
            print("In \(self.instanceType).initialize. This needs to be redone vis-a-vs coreinfo")
            RVCoreInfo.sharedInstance.getDomain(callback: { (domain , error) in
                if let error = error {
                    error.append(message: "In \(self.instanceType).initialize, error getting domain")
                    error.printError()
                    callback(error)
                } else if let domain = domain {
                    self.stack = [domain]
                    self.loadMain(callback: callback)
                } else {
                    print("In \(self.instanceType).initialize, no error but no domain")
                    callback(nil)
                }
            })
        }
    }
    override func loadMain(callback: @escaping (_ error: RVError?) -> Void) {
       // self.clearAndCreateWatchGroups()
          for datasource in datasources { manager.addSection(section: datasource) }
        if let mainDatasource = self.findDatasource(type: RVBaseDataSource.DatasourceType.main) {
            if let queryFunction = self.queryFunctions[RVBaseDataSource.DatasourceType.main] {
                let query = queryFunction([String: AnyObject]())
                self.manager.stopAndResetDatasource(datasource: mainDatasource, callback: { (error) in
                    if let error = error {
                        error.append(message: "In \(self.instanceType).loadMain, got error stoping main database")
                        error.printError()
                        callback(error)
                    } else {
                        self.manager.startDatasource(datasource: mainDatasource, query: query, callback: { (error) in
                            if let error = error {
                                error.append(message: "In \(self.instanceType).loadMain, got error starting main database")
                                error.printError()
                                callback(error)
                            } else {
                                callback(error)
                                // print("In \(self.instanceType).loadMain, completed start")
                            }
                        })
                    }
                })
                return
            } else {
                print("In \(self.instanceType).loadMain, no queryFunction")
                let error = RVError(message: "In \(self.instanceType).loadMain, no queryFunction")
                callback(error)
            }
        } else {
            print("In \(self.instanceType).loadMain, no mainDatasource")
            let error = RVError(message: "In \(self.instanceType).loadMain, no mainDatasource")
            callback(error)
        }
    }
    func createWatchGroups() {
        let titles = ["Bear Gulch", "Golden Oak", "Corte Madera"]
        let handles = ["Joyce", "Lisa", "Jennifer"]
        let comments = ["Neat area", "A Shaped", "Hmmmmm"]
        if let domain = self.domain {
            if let userProfile = self.userProfile {
                for index in (0..<titles.count) {
                    let group = RVWatchGroup()
                    group.title = titles[index]
                    group.handle = handles[index]
                    group.comment = comments[index]
                    group.domainId = domain.localId
                    group.setOwner(owner: userProfile)
                    group.setParent(parent: domain)
                    group.create(callback: { (savedGroup, error) in
                        if let error = error {
                            error.printError()
                        } else if let savedGroup = savedGroup {
                            print("In \(self.instanceType).createWatchGroups, created \(savedGroup.title!), \(savedGroup.handle!), comment: \(savedGroup.comment!)")
                        } else {
                            print("In \(self.instanceType).createWatchGroups, no error but no result")
                        }
                    })
                }
            }
        }
    }
    func clearAndCreateWatchGroups() {
        RVWatchGroup.deleteAll { (error ) in
            if let error = error {
                error.printError()
            } else {
                print("In \(self.instanceType).clearWatchGroup, returned without error")
                self.createWatchGroups()
            }
        }
    }
}
