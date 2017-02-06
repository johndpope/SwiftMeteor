//
//  RVMainStateTask.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/27/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
class RVMainStateTask: RVMainViewControllerState {
    override func configure() {
        let state = self
        state.scopes = [["Handle": RVKeys.handle], ["Title": RVKeys.title]  , ["Comment": RVKeys.comment]]
        state.segmentViewFields = [.WatchGroupInfo, .WatchGroupMembers, .WatchGroupMembers]
        let mainDatasource = RVTaskDatasource()
        mainDatasource.datasourceType = .main
        state.datasources.append(mainDatasource)
        let filterDatasource = RVTaskDatasource(maxArraySize: 500, filterMode: true)
        filterDatasource.datasourceType = .filter
        state.datasources.append(filterDatasource)
        for datasource in state.datasources {
            state.manager.addSection(section: datasource)
        }
        let mainQuery: queryFunction = ({(params) in
            let query = mainDatasource.basicQuery().duplicate()
            if let top = state.stack.last {
                query.addAnd(term: RVKeys.parentId, value: top.localId as AnyObject, comparison: .eq)
                query.addAnd(term: RVKeys.parentModelType, value: top.modelType.rawValue as AnyObject, comparison: .eq )
            }
            return query
        })
        state.queryFunctions[RVBaseDataSource.DatasourceType.main] = mainQuery
        let filterQuery: queryFunction = ({(params) in
            let query = filterDatasource.basicQuery().duplicate()
            query.removeAllSortTerms()
            if let top = state.stack.last {
                query.addAnd(term: RVKeys.parentId, value: top.localId as AnyObject, comparison: .eq)
                query.addAnd(term: RVKeys.parentModelType, value: top.modelType.rawValue as AnyObject, comparison: .eq )
            }
            if let index = params[RVMainViewControllerState.scopeIndexLabel] as? Int {
                if index >= 0 && index < state.scopes.count {
                    if let (_, field) = state.scopes[index].first {
                        if let text = params[RVMainViewControllerState.textLabel] as? String {
                            // print("In \(self.classForCoder).filterQuery, scope is \(field.rawValue)")
                            if field == .handle || field == .handleLowercase {
                                // query.addAnd(term: RVKeys.handle, value: text.lowercased() as AnyObject, comparison: .gte)
                                query.fixedTerm = RVQueryItem(term: RVKeys.handle, value: text.lowercased() as AnyObject, comparison: .regex) // necessary for keeping filter equal or gt filter term
                                query.addSort(field: .handle, order: .ascending)
                            } else if field == .title {
                                //   query.addAnd(term: RVKeys.title, value: text.lowercased() as AnyObject, comparison: .gte)
                                query.fixedTerm = RVQueryItem(term: RVKeys.title, value: text.lowercased() as AnyObject, comparison: .regex) // necessary for keeping filter equal or gt filter term
                                query.addSort(field: .title, order: .ascending)
                            } else if field == .comment || field == .commentLowercase {
                                //   query.addAnd(term: RVKeys.comment, value: text.lowercased() as AnyObject, comparison: .gte)
                                query.fixedTerm = RVQueryItem(term: RVKeys.comment, value: text.lowercased() as AnyObject, comparison: .regex) // necessary for keeping filter equal or gt filter term
                                query.addSort(field: .comment, order: .ascending)
                            }
                        }
                    }
                }
            } else {
                if let text = params[RVMainViewControllerState.textLabel] as? String {
                    query.fixedTerm = RVQueryItem(term: RVKeys.handle, value: text.lowercased() as AnyObject, comparison: .regex) // necessary for keeping filter equal or gt filter term
                }
                query.addSort(field: .handle, order: .ascending)
            }
            return query
        })
        state.queryFunctions[RVBaseDataSource.DatasourceType.filter] = filterQuery
    }

    override func initialize(scrollView: UIScrollView?, callback: @escaping (_ error: RVError?) -> Void) {
        self.manager = RVDSManager(scrollView: scrollView)
        RVSeed.createRootTask { (root, error) in
            if let error = error {
                error.printError()
                callback(error)
                return
            } else if let root = root {
                self.stack = [root]
                if let mainDatasource = self.findDatasource(type: RVBaseDataSource.DatasourceType.main) {
                    if let queryFunction = self.queryFunctions[RVBaseDataSource.DatasourceType.main] {
                        let query = queryFunction([String: AnyObject]())
                        self.manager.stopAndResetDatasource(datasource: mainDatasource, callback: { (error) in
                            if let error = error {
                                error.append(message: "In \(self.instanceType).loadUp, got error stoping main database")
                                error.printError()
                                callback(error)
                            } else {
                                self.manager.startDatasource(datasource: mainDatasource, query: query, callback: { (error) in
                                    if let error = error {
                                        error.append(message: "In \(self.instanceType).loadUp, got error starting main database")
                                        error.printError()
                                        callback(error)
                                    } else {
                                        callback(error)
                                    }
                                })
                                return
                            }
                        })
                        return
                    } else {
                        print("In \(self.instanceType).initialize, no queryFunction")
                        let error = RVError(message: "In \(self.instanceType).initialize, no queryFunction")
                        callback(error)
                    }
                } else {
                    print("In \(self.instanceType).initialize, no mainDatasource")
                    let error = RVError(message: "In \(self.instanceType).initialize, no mainDatasource")
                    callback(error)
                }
            } else {
                print("In \(self.instanceType).initialize no root")
                let error = RVError(message: "In \(self.instanceType).initialize no root")
                callback(error)
            }
        }
    }
}
