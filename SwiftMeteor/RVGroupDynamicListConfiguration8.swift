//
//  RVGroupDynamicListConfiguration8.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/17/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
class RVGroupDynamicListConfiguration8<T: RVSubbaseModel>: RVBaseConfiguration8<T> {

    
    required init(scrollView: UIScrollView? ) {
        super.init(scrollView: scrollView)
        self.subscription           = RVGroupListSubscription8(front: true, showResponse: false)
        self.configurationName      = "RVGroupDynamicListConfiguration8"
        self.navigationBarTitle     = "Groups"
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
        self.manager = RVDSManagerDynamicGroupList8<T>(scrollView: scrollView, maxSize: 80, managerType: .main, dynamicSections: true, useZeroCell: true)
        self.manager.subscription = RVGroupListSubscription8(front: true, showResponse: false)
        
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
        let datasource = RVGroupListDatasource8<T>(manager: self.manager, datasourceType: .main, maxSize: 80)
        datasource.subscription = self.subscription
        return datasource
    }
    override var filterDatasource: RVBaseDatasource4<T> {
        return RVGroupListDatasource8<T>(manager: self.manager, datasourceType: .filter, maxSize: self.mainDatasourceMaxSize)
    }
    override func baseTopQuery() -> (RVQuery, RVError?) {
        let query = RVQuery()
        query.addSort(sortTerm: RVSortTerm(field: .createdAt, order: .ascending))
        return (query, nil)
    }
    override func baseMainQuery() -> (RVQuery, RVError?) {
       // print("In \(self.instanceType).baseMainQuery()")
        let (query, error) = RVGroup.baseQuery
   //     query.addAnd(term: .special, value: RVSpecial.root.rawValue as AnyObject , comparison: .eq)
        if let root = core.rootGroup {
            if let rootId = root.localId {
                query.addAnd(term: .parentId, value: rootId as AnyObject , comparison: .eq)
            } else {
                print("In \(self.instanceType).baseMainQuery, no core.rootGroup.id")
            }
        } else {
            print("In \(self.instanceType).baseMainQuery, no core.rootGroup")
        }
        return (query, error)
    }
    override func baseFilterQuery() -> (RVQuery, RVError?) {
        return RVGroup.baseQuery
    }
    
    
}
