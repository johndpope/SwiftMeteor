//
//  RVTransactionListConfiguration.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/17/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation

class RVTransactionListConfiguration: RVBaseConfiguration {
    override func configureUI() {
        self.showSearch         = true
        self.showTopView        = true
        self.installRefresh     = false
        self.SLKIsInverted      = false
        self.navigationBarTitle     = "Transactions"
        self.topInTopAreaHeight     = 0.0
        self.middleInTopAreaHeight  = 0.0
        self.bottomInTopAreaHeight  = 0.0
        self.scopes = [[RVKeys.title.rawValue: RVKeys.title], [RVKeys.fullName.rawValue: RVKeys.fullName]]
    }
    override func createDatasources() {
        let topViewDatasource = RVBaseTopViewDatasource()
        topViewDatasource.datasourceType = .top
        self.topDatasource = topViewDatasource
        
        let mainDatasource = RVTransactionDatasource2()
        mainDatasource.datasourceType = .main
        self.mainDatasource = mainDatasource
        let filterDatasource = RVTransactionDatasource2(maxArraySize: RVBaseConfiguration.DefaultFilterSize, filterMode: true)
        filterDatasource.datasourceType = .filter
        self.filterDatasource = filterDatasource
    }
    override func createQueries() {
        queryFunctions[.top] = {(params) in return RVQuery() } // dummy value
        if let datasource = self.mainDatasource {
            let mainQuery: queryFunction = {(params) in
                let query = datasource.basicQuery()
                if let top = self.stack.last {
                    query.addAnd(term: .parentId, value: top.localId as AnyObject, comparison: .eq)
                }
                if let loggedInUserProfileId = self.loggedInUserProfileId {
                    query.addAnd(term: .targetUserProfileId, value: loggedInUserProfileId as AnyObject, comparison: .eq)
                }
                query.addAnd(term: .createdAt, value: RVEJSON.convertToEJSONDate(Date()) as AnyObject, comparison: .lte)
                query.removeAllSortTerms()
                query.addSort(field: .createdAt, order: .descending)
                query.addAnd(term: .createdAt, value: Date() as AnyObject, comparison: .lte)
                return query
            }
            queryFunctions[.main] = mainQuery
        }
        if let datasource = self.filterDatasource {
            let filterQuery: queryFunction = {(params) in
                let query = datasource.basicQuery()
                query.removeAllSortTerms()
                if let top = self.stack.last {
                    query.addAnd(term: .parentId, value: top.localId as AnyObject, comparison: .eq)
                }
                if let rawSortField = params[RVBaseConfiguration.sortField] as? String {
                    if let sortField = RVKeys(rawValue: rawSortField) {
                        switch(sortField) {
                        case .fullName:
                            if let text = params[RVBaseConfiguration.textField] as? String {
                                query.fixedTerm = RVQueryItem(term: .fullName, value: text.lowercased() as AnyObject, comparison: .regex)
                            } else {
                                query.fixedTerm = RVQueryItem(term: .fullName, value: "a" as AnyObject, comparison: .regex)
                            }
                            query.addSort(field: .fullName, order: .ascending)
                        case .createdAt:
                            query.fixedTerm = RVQueryItem(term: .createdAt, value: RVEJSON.convertToEJSONDate(Date()) as AnyObject, comparison: .lte)
                            query.addSort(field: .createdAt, order: .ascending)
                        default:
                            print("In \(self.instanceType).configure, \(RVBaseConfiguration.sortField) \(rawSortField), not implemented")
                        }
                    } else {
                        print("In \(self.instanceType).configure, invalid \(RVBaseConfiguration.sortField) \(rawSortField)")
                    }
                } else {
                    print("In \(self.instanceType).configure, no \(RVBaseConfiguration.sortField) provided")
                }
                
                return query
            }
            queryFunctions[.filter] = filterQuery
        }

    }
}
