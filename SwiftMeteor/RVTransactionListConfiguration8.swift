//
//  RVTransactionListConfiguration8.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/16/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
class RVTransactionListConfiguration8: RVBaseConfiguration8 {
    
    
    override init(scrollView: UIScrollView? ) {
        super.init(scrollView: scrollView)
        self.subscription           = RVTransactionSubscription8(front: true, showResponse: false)
        self.configurationName      = "RVTransactionListConfiguration8"
        self.navigationBarTitle     = "Transactions"
        self.navigationBarColor     = UIColor.facebookBlue()
        self.showSearch             = true
        self.showTopView            = true
        self.installRefresh         = false
        self.defaultSortOrder       = .ascending
        self.installSearchControllerInTableView = false
        self.searchBarPlaceholder   = "... Search"
        self.topAreaMaxHeights          = [30.0, 0.0, 0.0]
        self.topAreaMinHeights          = [30.0, 0.0, 0.0]

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
    override var topDatasource: RVBaseDatasource4<RVBaseModel>? {
        return RVDummyTopDatasource4<RVBaseModel>(manager: self.manager, datasourceType: .top, maxSize: 100)
    }
    override var mainDatasource: RVBaseDatasource4<RVBaseModel> {
        let datasource = RVTransactionListDatasource8<RVBaseModel>(manager: self.manager, datasourceType: .main, maxSize: 80)
        datasource.subscription = self.subscription
        return datasource
    }
    override var filterDatasource: RVBaseDatasource4<RVBaseModel> {
        return RVTransactionListDatasource8<RVBaseModel>(manager: self.manager, datasourceType: .filter, maxSize: self.mainDatasourceMaxSize)
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
