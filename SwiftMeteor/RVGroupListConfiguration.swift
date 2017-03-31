//
//  RVGroupListConfiguration.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/21/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation

class RVGroupListConfiguration: RVBaseConfiguration {
    override func configureUI() {
        self.showSearch             = true
        self.showTopView            = true
        self.installRefresh         = false
        self.SLKIsInverted          = false
        self.navigationBarTitle     = "Transactions"
        self.showTextInputBar       = true
        self.topInTopAreaHeight     = 0.0
        self.middleInTopAreaHeight  = 0.0
        self.bottomInTopAreaHeight  = 0.0
        self.scopes = [[RVKeys.title.rawValue: RVKeys.title], [RVKeys.fullName.rawValue: RVKeys.fullName]]
    }
    override func instantiateTopDatasource() -> RVBaseDataSource? {
        let topViewDatasource = RVBaseTopViewDatasource()
        topViewDatasource.datasourceType = .top
        return topViewDatasource
    }
    override func instantiateMainDatasource() -> RVBaseDataSource? {
        let mainDatasource = RVTransactionDatasource2()
        mainDatasource.datasourceType = .main
        
        return mainDatasource
    }
    override func instantiateFilterDatasource() -> RVBaseDataSource? {
        let filterDatasource = RVTransactionDatasource2(maxArraySize: RVBaseConfiguration.DefaultFilterSize, filterMode: true)
        filterDatasource.datasourceType = .filter
        return filterDatasource
    }
    func date() -> Date {
            let dateFormatter = DateFormatter()
            let dateAsString = "2017-03-28 05:12"
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            return dateFormatter.date(from: dateAsString)!
        
    }
    override func createQueries() {
        print("In \(self.instanceType).createQueries")
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
             //   query.addAnd(term: .createdAt, value: RVEJSON.convertToEJSONDate(Date()) as AnyObject, comparison: .lte)
                query.removeAllSortTerms()
                query.addSort(field: .createdAt, order: .descending)
                query.addAnd(term: .createdAt, value: Date() as AnyObject, comparison: .lte)
                //query.addAnd(term: .createdAt, value: self.date() as AnyObject, comparison: .lte)
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
                if let sortField = params[RVFilterTerms.Keys.sortField.rawValue] as? RVKeys  {
                    switch(sortField) {
                        
                    case .fullName, .title:
                        if let text = params[RVFilterTerms.Keys.value.rawValue] as? String {
                            query.fixedTerm = RVQueryItem(term: sortField, value: text.lowercased() as AnyObject, comparison: .regex)
                        } else {
                            query.fixedTerm = RVQueryItem(term: sortField, value: "a" as AnyObject, comparison: .regex)
                        }
                        query.addSort(field: sortField, order: .ascending)
                    case .createdAt:
                        query.fixedTerm = RVQueryItem(term: .createdAt, value: RVEJSON.convertToEJSONDate(Date()) as AnyObject, comparison: .lte)
                        query.addSort(field: .createdAt, order: .ascending)
                    default:
                        print("In \(self.instanceType).configure, \(RVBaseConfiguration.sortField) \(sortField.rawValue), not implemented")
                    }
                }
                return query
            }
            queryFunctions[.filter] = filterQuery
        }
        
    }
}
