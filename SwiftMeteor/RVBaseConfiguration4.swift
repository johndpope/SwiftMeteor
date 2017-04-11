//
//  RVBaseConfiguration4.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/4/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
import SlackTextViewController

class RVBaseConfiguration4 {
    var instanceType: String { get { return String(describing: type(of: self)) } }
    var configurationName: String   = "RVBaseConfiguration4"
    var navigationBarTitle: String  = "Replace"
    var showSearch: Bool            = true
    var showTopView:Bool            = true
    var installRefresh: Bool        = false
    var searchBarPlaceholder: String = "... Search"
    var mainDatasourceMaxSize: Int  = 300
    var filterDatasourceMaxSize: Int = 300
    var topAreaMaxHeights: [CGFloat] = [0.0, 0.0, 0.0]
    var topAreaMinHeights: [CGFloat] = [0.0, 0.0, 0.0]
    let LAST_SORT_STRING = "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"

    var searchScopes: [[String : RVKeys]]     = [[RVKeys.title.rawValue: RVKeys.title], [RVKeys.fullName.rawValue: RVKeys.fullName]]
    var defaultSortOrder: RVSortOrder = .ascending
    var installSearchControllerInTableView: Bool = false
    var manager: RVDSManager5<RVBaseModel> = RVDSManager5<RVBaseModel>(scrollView: nil, managerType: .filter, dynamicSections: false)
    var navigationBarColor: UIColor = UIColor.facebookBlue()
    
    // SLK
    var SLKIsInverted: Bool                             = false
    var SLKbounces: Bool                                = true
    var SLKshakeToClearEnabled: Bool                    = true
    var SLKisKeyboardPanningEnabled: Bool               = true
    var SLKshouldScrollToBottomAfterKeyboardShows: Bool = false
    var SLKshowTextInputBar: Bool                       = true
    
    
    var topDatasource: RVBaseDatasource4<RVBaseModel>? {
        return nil
    }
    var mainDatasource: RVBaseDatasource4<RVBaseModel> {
        return RVBaseDatasource4<RVBaseModel>(manager: self.manager, datasourceType: .main , maxSize: self.mainDatasourceMaxSize)
    }
    var filterDatasource: RVBaseDatasource4<RVBaseModel> {
        return RVBaseDatasource4<RVBaseModel>(manager: self.manager, datasourceType: .filter, maxSize: self.filterDatasourceMaxSize)
    }
    
    init(scrollView: UIScrollView? ) {
        /*
        self.configurationName      = "RVBaseConfiguration4"
        self.navigationBarTitle     = "Replace"
        self.navigationBarColor     = UIColor.facebookBlue()
        self.showSearch             = true
        self.showTopView            = true
        self.installRefresh         = false
        self.defaultSortOrder       = .ascending
        self.installSearchControllerInTableView = false
        self.searchBarPlaceholder   = "... Search"
        self.topAreaMaxHeights          = [0.0, 0.0, 0.0]
        self.topAreaMinHeights          = [0.0, 0.0, 0.0]
        self.mainDatasourceMaxSize      = 300
        self.filterDatasourceMaxSize    = 300
        self.searchScopes               = [[RVKeys.title.rawValue: RVKeys.title], [RVKeys.fullName.rawValue: RVKeys.fullName]]
         */
        self.manager = RVDSManager5<RVBaseModel>(scrollView: scrollView, managerType: .filter, dynamicSections: false)
        configureSLK()
    }
    func configureSLK() {
        self.SLKIsInverted                             = false
        self.SLKbounces                                = true
        self.SLKshakeToClearEnabled                    = true
        self.SLKisKeyboardPanningEnabled               = true
        self.SLKshouldScrollToBottomAfterKeyboardShows = false
        self.SLKshowTextInputBar                       = true
    }
    func removeAllSections(callback: @escaping RVCallback<RVBaseModel>) {
        self.manager.removeAllSections(callback: callback)
    }
    func baseTopQuery() -> (RVQuery, RVError?) {
        print("In \(self.instanceType).baseTopQuery(). Needs to be overridden")
        return RVTransaction.baseQuery
    }
    func baseMainQuery() -> (RVQuery, RVError?) {
        print("In \(self.instanceType).baseMainQuery(). Needs to be overridden")
        return RVTransaction.baseQuery
    }
    func baseFilterQuery() -> (RVQuery, RVError?) {
        print("In \(self.instanceType).baseFilterQuery(). Needs to be overridden")
        return RVTransaction.baseQuery
    }
    func buildQuery(query: RVQuery, andTerms: [RVQueryItem], sortTerm: RVSortTerm) -> RVQuery {
        let query = query.duplicate()
        query.addSort(sortTerm: sortTerm)
        let comparison = sortTerm.order == .descending ? RVComparison.lte : RVComparison.gte
        var value: AnyObject = "" as AnyObject
        switch (sortTerm.field) {
        case .createdAt, .updatedAt:
            value = sortTerm.order == .descending ? Date() as AnyObject : query.decadeAgo as AnyObject
        default:
            value = sortTerm.order == .descending ?   self.LAST_SORT_STRING as AnyObject : "" as AnyObject
        }
        query.addAnd(term: sortTerm.field, value: value as AnyObject, comparison: comparison)
        for and in andTerms { query.addAnd(term: and.term, value: and.value, comparison: and.comparison) }
        return query
    }
    func topQuery(andTerms: [RVQueryItem] = [RVQueryItem](), sortTerm: RVSortTerm = RVSortTerm(field: .createdAt, order: .descending)) -> (RVQuery, RVError?) {
        let (query, error) = baseTopQuery()
        if let error = error {
            error.append(message: "In \(self.instanceType).mainQuery, got error sourcing Base Query")
            return (query, error)
        } else {
            let query = buildQuery(query: query, andTerms: andTerms, sortTerm: sortTerm)
            return (query, nil)
        }
    }
    func mainQuery(andTerms: [RVQueryItem] = [RVQueryItem](), sortTerm: RVSortTerm = RVSortTerm(field: .createdAt, order: .descending)) -> (RVQuery, RVError?) {
        let (query, error) = baseMainQuery()
        if let error = error {
            error.append(message: "In \(self.instanceType).mainQuery, got error sourcing Base Query")
            return (query, error)
        } else {
            let query = buildQuery(query: query, andTerms: andTerms, sortTerm: sortTerm)
            return (query, nil)
        }
    }
    func filterQuery(andTerms: [RVQueryItem] = [RVQueryItem](), matchTerm: RVQueryItem, sortTerm: RVSortTerm = RVSortTerm(field: .createdAt, order: .descending)) -> (RVQuery, RVError?) {
        let (query, error) = baseFilterQuery()
        if let error = error {
            error.append(message: "In \(self.instanceType).filterQuery, got error sourcing Base Query")
            return (query, error)
        } else {
            let query = buildQuery(query: query, andTerms: andTerms, sortTerm: sortTerm)
            query.fixedTerm = matchTerm
            return (query, nil)
        }
    }
    func loadTop(query: RVQuery, callback: @escaping(RVError?)->Void) {
        //print("In \(self.instanceType).loadTop query: \(query)")
        if let top = self.topDatasource {
            manager.appendSections(datasources: [top], sectionTypesToRemove: [.top, .main, .filter]) { (models, error) in
                if let error = error {
                    error.append(message: "In \(self.instanceType).loadMain \(#line). Got error on datasource append")
                    callback(error)
                    return
                } else {
                    self.manager.restart(datasource: top, query: query, callback: { (models, error) in
                        if let error = error {
                            error.append(message: "In \(self.instanceType).loadTop \(#line). Got error on datasource restart")
                        }
                        callback(error)
                    })
                }
            }
            return
        } else {
            callback(nil)
        }
        
    }
    func loadMain(query: RVQuery, callback: @escaping(RVError?)->Void) {
        loadDatasource(datasource: mainDatasource, query: query, callback: callback)
    }
    func loadSearch(query: RVQuery, callback: @escaping(RVError?)->Void) {
        loadDatasource(datasource: filterDatasource, query: query, callback: callback)
    }
    func loadDatasource(datasource: RVBaseDatasource4<RVBaseModel>, query: RVQuery, callback: @escaping(RVError?)->Void) {
        //print("In \(self.instanceType).loadDatasource before append")
        manager.appendSections(datasources: [datasource], sectionTypesToRemove: [.main, .filter]) { (models, error) in
            if let error = error {
                error.append(message: "In \(self.instanceType).loadMain \(#line). Got error on datasource append")
                callback(error)
                return
            } else {
                self.manager.restart(datasource: datasource, query: query, callback: { (models, error) in
                    if let error = error {
                        error.append(message: "In \(self.instanceType).loadMain \(#line). Got error on datasource restart")
                    }
                    callback(error)
                })
            }
        }
    }
    func initializeDatasource(callback: @escaping(RVError?) -> Void) {
        if !manager.dynamicSections {
            let (query, _) = self.topQuery()
            self.loadTop(query: query, callback: { (error) in
                if let error = error {()
                    error.append(message: "In \(self.instanceType).initializeDatasource, got error from loadTOp")
                    callback(error)
                    return
                } else {
                    self.getQueryAndLoadMain(callback: { (error) in
                        if let error = error {
                            error.append(message: "In \(self.instanceType).initializeDatasource, got error from getQueryAndLoadMain")
                            callback(error)
                            return
                        } else {
                            callback(nil)
                            return
                        }
                    })
                    return
                }
            })
            return
        } else {
            loadDynamicSections(callback: { (error) in
                if let error = error {
                    error.printError()
                }
            })
        }
    }
    func getQueryAndLoadMain(callback: @escaping(RVError?) -> Void) {
        let (query, error) = self.mainQuery()
        if let error = error {
            error.append(message: "In \(self.instanceType).getQueryAndLoadMain, got error creating Query")
            callback(error)
            return
        } else {
            self.loadMain(query: query, callback: { (error) in
                if let error = error {
                    error.append(message: "In \(self.instanceType).getQueryAndLoadMain, got error")
                }
                callback(error)
            })
        }
    }
    func loadDynamicSections(callback: @escaping(RVError?) -> Void) {
        var (query, error) = self.mainQuery()
        query = query.duplicate()
        query.addSort(field: .createdAt, order: .ascending)
        query.limit = 3
        if let error = error {
            error.append(message: "In \(self.instanceType).loadMain, got error creating Query")
            callback(error)
        } else {
            self.manager.restartSectionDatasource(query: query, callback: { (datasources, error) in
                if let error = error {
                    error.append(message: "IN \(self.instanceType).doSectionText, have error on restart callback")
                    callback(error)
                    return
                } else {
                    print("In \(self.instanceType).doSectionTest, successful return")
                }
            })
        }
    }

}
