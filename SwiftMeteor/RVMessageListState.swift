//
//  RVMessageListState.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 2/4/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit

class RVMessageListState: RVBaseAppState {
    
    override func configure() {
        self.state = .MessageListState
        scopes = [[String: RVKeys]]()
        segmentViewFields = [.WatchGroupInfo, .WatchGroupMembers, .WatchGroupMessages]
        showTopView = true
        showSearchBar = true
        let mainDatasource = RVMessageDatasource()
        mainDatasource.datasourceType =  .main
        datasources.append(mainDatasource)
        
        let filterDatasource = RVMessageDatasource(maxArraySize: 300, filterMode: true)
        filterDatasource.datasourceType = .filter
        datasources.append(filterDatasource)
        //        for datasource in datasources { manager.addSection(section: datasource) }
        let mainQuery: queryFunction = {(params) in
            let query = mainDatasource.basicQuery()
            if let top = self.stack.last {
                query.addAnd(term: .parentId, value: top.localId as AnyObject, comparison: .eq)
            }
            query.addAnd(term: .createdAt, value: RVEJSON.convertToEJSONDate(Date()) as AnyObject, comparison: .lte)
            return query
        }
        queryFunctions[.main] = mainQuery
        let filterQuery: queryFunction = {(params) in
            let query = filterDatasource.basicQuery()
            query.removeAllSortTerms()
            if let top = self.stack.last {
                query.addAnd(term: .parentId, value: top.localId as AnyObject, comparison: .eq)
            }
            if let text = params[RVMainViewControllerState.textLabel] as? String {
                query.fixedTerm = RVQueryItem(term: .fullName, value: text.lowercased() as AnyObject, comparison: .regex)
                query.addSort(field: .title, order: .ascending)
            } else {
                print("IN \(self.instanceType).configure, filterQueryFunction, setting fixedTerm to .title, no text")
                query.fixedTerm = RVQueryItem(term: .fullName, value: "a" as AnyObject, comparison: .regex)
                query.addSort(field: .title, order: .ascending)
            }
            return query
        }
        queryFunctions[.filter] = filterQuery
    }
}
