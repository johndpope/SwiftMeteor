//
//  RVBaseConfiguration4.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/4/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
import SlackTextViewController

class RVBaseConfiguration4<T: RVSubbaseModel>: RVListControllerConfigurationProtocol {
    var NOTOPDATASOURCE: Bool = true // NEIL PLUG
    var instanceType: String { get { return String(describing: type(of: self)) } }
    var dynamicSections: Bool = false
    var sectionDatasourceType: RVDatasourceType = .main
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
    var LAST_SORT_STRING = "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
    var subscription: RVSubscription? = nil
    
    var topTopMinimumHeight: CGFloat = 0.0
    var topMiddleMinimumHeight: CGFloat = 0.0
    var topBottomMinimumHeight: CGFloat = 0.0
    
    var topTopMaximumHeight: CGFloat = 0.0
    var topMiddleMaximumHeight: CGFloat = 0.0
    var topBottomMaximumHeight: CGFloat = 0.0

    var searchScopes: [[String : RVKeys]]     = [[RVKeys.title.rawValue: RVKeys.title], [RVKeys.fullName.rawValue: RVKeys.fullName]]
    var defaultSortOrder: RVSortOrder = .ascending
    var installSearchControllerInTableView: Bool = false
    var manager: RVDSManager5<T> = RVDSManager5<T>(scrollView: nil, managerType: .filter, dynamicSections: false)
    var navigationBarColor: UIColor = UIColor.facebookBlue()
    
    // SLK
    var SLKIsInverted: Bool                             = false
    var SLKbounces: Bool                                = true
    var SLKshakeToClearEnabled: Bool                    = true
    var SLKisKeyboardPanningEnabled: Bool               = true
    var SLKshouldScrollToBottomAfterKeyboardShows: Bool = false
    var SLKshowTextInputBar: Bool                       = true
    
    var zeroCellModeOn: Bool {
        return self.manager.useZeroCell
    }
    var topDatasource: RVBaseDatasource4<T>? {
        return nil
    }
    var mainDatasource: RVBaseDatasource4<T> {
        return RVBaseDatasource4<T>(manager: self.manager, datasourceType: .main , maxSize: self.mainDatasourceMaxSize)
    }
    var filterDatasource: RVBaseDatasource4<T> {
        return RVBaseDatasource4<T>(manager: self.manager, datasourceType: .filter, maxSize: self.filterDatasourceMaxSize)
    }
    
    required init(scrollView: UIScrollView? ) {
        /*
         self.subscription          = nil
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
        self.manager = RVDSManager5<T>(scrollView: scrollView, managerType: .filter, dynamicSections: false)
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
    func removeAllSections() {
        self.manager.removeAllSections { (models, error) in
            if let error = error {
                error.printError()
            }
        }
    }
    func removeAllSections(callback: @escaping (RVError?) -> Void) {
        self.manager.removeAllSections { (models, error) in
            callback(error)
        }
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
        if NOTOPDATASOURCE {
            callback(nil)
            return
        }
        //print("In \(self.instanceType).loadTop query: \(query)")
        if let top = self.topDatasource {
            manager.appendSections(datasources: [top], sectionTypesToRemove: [.top, .main, .filter]) { (models, error) in
                if let error = error {
                    error.append(message: "In \(self.instanceType).loadMain \(#line). Got error on datasource append")
                    callback(error)
                    return
                } else {
                    self.manager.restart(datasource: top, query: query, sectionsDatasourceType: .top, callback: { (models, error ) in
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
    func loadMain2(andTerms: [RVQueryItem], callback: @escaping(RVError?)-> Void) {
        let (query, error) = self.mainQuery(andTerms: andTerms)
        if let error = error {
            error.append(message: "In \(self.instanceType).loadMain2, got error creating Query")
            callback(error)
        } else {
            self.loadMain(query: query, callback: { (error) in
                if let error = error {
                    error.append(message: "In \(self.instanceType).loadMain, got error")
                }
                callback(error)
            })
        }
    }
    func loadMain(query: RVQuery, callback: @escaping(RVError?)->Void) {
        loadDatasource(datasource: mainDatasource, query: query, callback: callback)
    }
    func loadSearch(searchText: String, field: RVKeys, order: RVSortOrder = .ascending, andTerms: [RVQueryItem], callback: @escaping(RVError?)->Void) {
        
        let matchTerm = RVQueryItem(term: field, value: searchText.lowercased() as AnyObject, comparison: .regex)
      //  let andTerms = [RVQueryItem]()
        let (query, error) = self.filterQuery(andTerms: andTerms, matchTerm: matchTerm, sortTerm: RVSortTerm(field: field, order: order))
        if let error = error {
            error.append(message: "In \(self.instanceType).loadSearch2, got error generating query")
        } else{
            if !self.manager.dynamicSections {
                loadDatasource(datasource: filterDatasource, query: query, callback: callback)
            } else {
                self.manager.restartSectionDatasource(sectionsDatasourceType: .filter, query: query, datasourceType: .filter, callback: { (datasources, error) in
                    if let error = error {
                        error.append(message: "IN \(self.instanceType).loadSearch, have error on restart callback")
                        callback(error)
                        return
                    } else {
                        callback(nil)
                    }
                })
            }
        }
    }
    func endSearch(mainAndTerms: [RVQueryItem], callback: @escaping(RVError? ) -> Void) {
       // print("In \(self.instanceType).endSerach")
        if !self.manager.dynamicSections {
            self.loadMain2(andTerms: mainAndTerms) { (error) in
                if let error = error {
                    error.append(message: "In \(self.instanceType).endSearch, got error")
                }
           //     print("In \(self.instanceType).endSerach have callback")
                callback(error)
            }
        } else {
           
            self.initializeDatasource(sectionDatasourceType: .main, mainAndTerms: mainAndTerms, callback: { (error) in
                if let error = error {
                    error.append(message: "In \(self.instanceType).endSearch, got error initializing")
                }
            //    print("In \(self.instanceType).endSerach have callback")
                callback(error)
            })
        }
        
    }
    
    func loadSearch(query: RVQuery, callback: @escaping(RVError?)->Void) {
        print("In \(self.instanceType).loadSearch. don't use this version")
        if !self.manager.dynamicSections {
            loadDatasource(datasource: filterDatasource, query: query, callback: callback)
        } else {
            //print("In \(self.instanceType).loadSearch, with dynamicSections. Need to implement")
            self.manager.restartSectionDatasource(sectionsDatasourceType: .filter, query: query, datasourceType: .filter, callback: { (datasources, error) in
                if let error = error {
                    error.append(message: "IN \(self.instanceType).doSectionText, have error on restart callback")
                    callback(error)
                    return
                } else {
                    callback(nil)
                }
            })
        }
        
    }
 
    func loadDatasource(datasource: RVBaseDatasource4<T>, query: RVQuery, callback: @escaping(RVError?)->Void) {
        //print("In \(self.instanceType).loadDatasource before append")
        manager.appendSections(datasources: [datasource], sectionTypesToRemove: [.main, .filter]) { (models, error) in
            if let error = error {
                error.append(message: "In \(self.instanceType).loadMain \(#line). Got error on datasource append")
                callback(error)
                return
            } else {
                self.manager.restart(datasource: datasource, query: query , sectionsDatasourceType: .main, callback: { (models , error ) in
                    if let error = error {
                        error.append(message: "In \(self.instanceType).loadMain \(#line). Got error on datasource restart")
                    }
                    callback(error)
                })
            }
        }
    }
    func initializeDatasource(sectionDatasourceType: RVDatasourceType, mainAndTerms: [RVQueryItem], callback: @escaping(RVError?) -> Void) {
    //    if let subscription = self.subscription { subscription.unsubscribe {} }
        //print("IN \(self.instanceType).initializeDatasource with dynamicSections: \(manager.dynamicSections)")
        if !manager.dynamicSections {
            
            let (query, _) = self.topQuery()
            self.loadTop(query: query, callback: { (error) in
                if let error = error {()
                    error.append(message: "In \(self.instanceType).initializeDatasource, got error from loadTOp")
                    callback(error)
                    return
                } else {
                    self.getQueryAndLoadMain(andTerms: mainAndTerms, callback: { (error) in
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
            loadDynamicSections(sectionDatasourceType: sectionDatasourceType, callback: { (error) in
                if let error = error {
                    error.printError()
                }
                callback(nil)
            })
        }
    }
    func getQueryAndLoadMain(andTerms: [RVQueryItem], callback: @escaping(RVError?) -> Void) {
        let (query, error) = self.mainQuery(andTerms: andTerms)
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
    func loadDynamicSections(sectionDatasourceType: RVDatasourceType, callback: @escaping(RVError?) -> Void) {
        print("In \(self.instanceType).loadDynamicSections(sectionDatasourceType with manager: \(self.manager)")
        var (query, error) = self.mainQuery(andTerms: [RVQueryItem](), sortTerm: RVSortTerm(field: .createdAt, order: .descending))
        query = query.duplicate()
        //query.addSort(field: .createdAt, order: .ascending)
        query.limit = 60
        if let error = error {
            error.append(message: "In \(self.instanceType).loadMain, got error creating Query")
            callback(error)
        } else {
            self.manager.restartSectionDatasource(sectionsDatasourceType: sectionDatasourceType, query: query, datasourceType: sectionDatasourceType, callback: { (datasources, error) in
                if let error = error {
                    error.append(message: "IN \(self.instanceType).doSectionText, have error on restart callback")
                    callback(error)
                    return
                } else {
                    callback(nil)
                }
            })
        }
    }
    func numberOfSections(tableView: UITableView) -> Int {
        return manager.numberOfSections
    }
    func numberOfItems(section: Int) -> Int {
        return manager.numberOfItems(section: section)
    }
    func item(indexPath: IndexPath, scrollView: UIScrollView?) -> RVBaseModel? {
        if let item = manager.item(indexPath: indexPath, scrollView: scrollView) as? RVBaseModel { return item}
        return nil
    }
    func itemWithoutTrigger(indexPath: IndexPath, scrollView: UIScrollView?) -> RVBaseModel? {
        if let item = manager.itemWithoutTrigger(indexPath: indexPath, scrollView: scrollView) as? RVBaseModel { return item }
        return nil
    }
    func datasourceInSection(section: Int, trigger: Bool = true) -> RVSubbaseModel?  {
        return manager.datasourceInSection(section: section, trigger: trigger)
    }
    func toggle(datasource: AnyObject, callback: @escaping (RVError?) -> Void) {
        if let datasource = datasource as? RVBaseDatasource4<T> {
            manager.toggle(datasource: datasource) { (models, error) in
                callback(error)
            }
        } else {
            let rvError = RVError(message: "In \(self.instanceType).toggle, datasource did not cast \(datasource)")
            callback(rvError)
        }

    }
    func unsubscribe() {
        manager.unsubscribe ()
    }
    func cancelAllOperations() {
        manager.cancelAllOperations()
    }
    func scrolling(indexPath: IndexPath, scrollView: UIScrollView) -> Void  {
        manager.scrolling(indexPath: indexPath, scrollView: scrollView)
    }
    var managerDynamicSections: Bool { return manager.dynamicSections }
    
}
