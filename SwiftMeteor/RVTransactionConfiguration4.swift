//
//  RVTransactionConfiguration4.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/5/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
class RVTransactionConfiguration4: RVBaseConfiguration4 {
    
    
    override init(scrollView: UIScrollView? ) {
        super.init(scrollView: scrollView)
        self.configurationName      = "RVBaseConfiguration4"
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
    override var topDatasource: RVBaseDatasource4? {
        return RVDummyTopDatasource4(manager: self.manager, datasourceType: .top, maxSize: 100)
    }
    override var mainDatasource: RVBaseDatasource4 {
        return RVTransactionDatasource44(manager: self.manager, datasourceType: .main, maxSize: 80)
    }
    override var filterDatasource: RVBaseDatasource4 {
        return RVTransactionDatasource44(manager: self.manager, datasourceType: .filter, maxSize: self.mainDatasourceMaxSize)
    }
    override func baseTopQuery() -> (RVQuery, RVError?) {
        return (RVQuery(), nil)
    }
    override func baseMainQuery() -> (RVQuery, RVError?) {
        return RVTransaction.baseQuery
    }
    override func baseFilterQuery() -> (RVQuery, RVError?) {
        return RVTransaction.baseQuery
    }
    

}
