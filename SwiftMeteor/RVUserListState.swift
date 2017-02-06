//
//  RVUserListState.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 2/5/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
class RVUserListState: RVBaseAppState {
    override func configure() {
        self.state = .UserList
        navigationBarTitle = "User List"
        topInTopAreaHeight = 0
        controllerOuterSegmentedViewHeight = 32.0
        bottomInTopAreaHeight = 0
        scopes = [[String: RVKeys]]()
        segmentViewFields = [.WatchGroupInfo, .WatchGroupMembers, .WatchGroupMessages]
        showTopView = true
        showSearchBar = true
        
        let mainDatasource = RVUserDatasource()
        mainDatasource.datasourceType =  .main
        datasources.append(mainDatasource)
        
        let filterDatasource = RVUserDatasource(maxArraySize: 300, filterMode: true)
        filterDatasource.datasourceType = .filter
        datasources.append(filterDatasource)
        
        let mainQuery: queryFunction = {(params) in
            let query = mainDatasource.basicQuery()
            query.addAnd(term: .fullName, value: "" as AnyObject, comparison: .gte)
            query.addSort(field: .fullName, order: .ascending)
            return query
        }
        queryFunctions[.main] = mainQuery
        
        let filterQuery: queryFunction = {(params) in
            
            let query = filterDatasource.basicQuery()
            query.removeAllSortTerms()
            if let text = params[RVMainViewControllerState.textLabel] as? String {
                query.fixedTerm = RVQueryItem(term: .fullName, value: text.lowercased() as AnyObject, comparison: .regex)
                query.addSort(field: .fullName, order: .ascending)
            } else {
                query.fixedTerm = RVQueryItem(term: .fullName, value: "a" as AnyObject, comparison: .regex)
                query.addSort(field: .fullName, order: .ascending)
            }
            return query
        }
        queryFunctions[.filter] = filterQuery
    }

}
