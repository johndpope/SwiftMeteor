//
//  RVMainViewControllerState.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/26/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
class RVMainViewControllerState {

    var datasources = [RVBaseDataSource]()
    static let scopeIndexLabel = "scopeIndex"
    static let textLabel = "text"
    var stack = [RVBaseModel]()
    typealias queryFunction = (_ params: [String: AnyObject]) -> (RVQuery)
    typealias QueryElement = [RVBaseDataSource.DatasourceType : queryFunction]
    var queryFunctions = QueryElement()
    var scopes = [[String: RVKeys]]()
    var manager: RVDSManager
    init(scrollView: UIScrollView) {
        self.manager = RVDSManager(scrollView: scrollView)
    }
    func findDatasource(type: RVBaseDataSource.DatasourceType) -> RVBaseDataSource? {
        for datasource in datasources {
            if datasource.datasourceType == type { return datasource }
        }
        return nil
    }

    class func tasksState(scrollView: UIScrollView)-> RVMainViewControllerState {
        let state = RVMainViewControllerState(scrollView: scrollView)
        state.scopes = [["Handle": RVKeys.handle], ["Title": RVKeys.title]  , ["Comment": RVKeys.comment]]
        let mainDatasource = RVTaskDatasource()
        mainDatasource.datasourceType = .main
        state.datasources.append(mainDatasource)
        let filterDatasource = RVTaskDatasource(maxArraySize: 500, filterMode: true)
        filterDatasource.datasourceType = .filter
        state.datasources.append(filterDatasource)
        for datasource in state.datasources {
            state.manager.addSection(section: datasource)
        }
        
        //mainDatasource.scrollView = scrollView
        //filterDatasource.scrollView = scrollView
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
        
        return state
    }
}
