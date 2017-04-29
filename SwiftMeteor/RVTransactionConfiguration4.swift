//
//  RVTransactionConfiguration4.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/5/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
class RVTransactionConfiguration4<T: RVSubbaseModel>: RVBaseConfiguration4<T> {
    
    
    required init(scrollView: UIScrollView? ) {
        super.init(scrollView: scrollView)
        self.subscription           = RVTransactionSubscription8(front: true, showResponse: false)
        self.configurationName      = "RVTransactionConfiguration4"
        self.navigationBarTitle     = "Replace"
        self.navigationBarColor     = UIColor.facebookBlue()
        self.showSearch             = true
        self.showTopView            = true
        self.installRefresh         = false
        self.defaultSortOrder       = .ascending
        self.installSearchControllerInTableView = false
        self.searchBarPlaceholder   = "... Search"
        self.topAreaMaxHeights          = [30.0, 40.0, 20.0]
        self.topAreaMinHeights          = [10.0, 5.0, 2.0]
        self.mainDatasourceMaxSize      = 300
        self.filterDatasourceMaxSize    = 300
        self.searchScopes               = [[RVKeys.title.rawValue: RVKeys.title], [RVKeys.fullName.rawValue: RVKeys.fullName]]

    }
    override func configureSLK() {
        self.SLKIsInverted                             = false
        self.SLKbounces                                = true
        self.SLKshakeToClearEnabled                    = true
        self.SLKisKeyboardPanningEnabled               = true
        self.SLKshouldScrollToBottomAfterKeyboardShows = false
        self.SLKshowTextInputBar                       = true
    }
    override var topDatasource: RVBaseDatasource4<T>? {
        return RVDummyTopDatasource4<T>(manager: self.manager, datasourceType: .top, maxSize: 100)
    }
    override var mainDatasource: RVBaseDatasource4<T> {
        let datasource = RVTransactionDatasource44<T>(manager: self.manager, datasourceType: .main, maxSize: 80)
        datasource.subscription = self.subscription
        return datasource 
    }
    override var filterDatasource: RVBaseDatasource4<T> {
        return RVTransactionDatasource44<T>(manager: self.manager, datasourceType: .filter, maxSize: self.mainDatasourceMaxSize)
    }
    override func baseTopQuery() -> (RVQuery, RVError?) {
        let query = RVQuery()
        query.addSort(sortTerm: RVSortTerm(field: .createdAt, order: .ascending))
        return (query, nil)
    }
    override func baseMainQuery() -> (RVQuery, RVError?) {
        return RVTransaction.baseQuery
    }
    override func baseFilterQuery() -> (RVQuery, RVError?) {
        return RVTransaction.baseQuery
    }
    

}
