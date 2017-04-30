//
//  RVListControllerConfigurationProtocol.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/28/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
protocol RVListControllerConfigurationProtocol: class {
    //associatedtype T: RVSubbaseModel
//    var manager: RVDSManager5<RVSubbaseModel> { get }
    var NOTOPDATASOURCE: Bool { get set}
    var instanceType: String { get }
    var dynamicSections: Bool { get set}
    var sectionDatasourceType: RVDatasourceType { get set}
    var configurationName: String   { get set}
    var navigationBarTitle: String  { get set}
    var showSearch: Bool            { get set}
    var showTopView:Bool            { get set}
    var installRefresh: Bool        { get set}
    var searchBarPlaceholder: String { get set}
    var mainDatasourceMaxSize: Int  { get set}
    var filterDatasourceMaxSize: Int { get set}
    var topAreaMaxHeights: [CGFloat] { get set}
    var topAreaMinHeights: [CGFloat] { get set}
    var LAST_SORT_STRING: String { get set}
    var subscription: RVSubscription? { get set}
    
    var topTopMinimumHeight: CGFloat { get set}
    var topMiddleMinimumHeight: CGFloat { get set}
    var topBottomMinimumHeight: CGFloat { get set}
    
    var topTopMaximumHeight: CGFloat { get set}
    var topMiddleMaximumHeight: CGFloat { get set}
    var topBottomMaximumHeight: CGFloat { get set}
    
    var searchScopes: [[String : RVKeys]]     { get set}
    var defaultSortOrder: RVSortOrder { get set}
    var installSearchControllerInTableView: Bool { get set}
//    var manager: RVDSManager5<T> { get set}
    var navigationBarColor: UIColor{ get set}
    
    // SLK
    var SLKIsInverted: Bool                            { get set}
    var SLKbounces: Bool                               { get set}
    var SLKshakeToClearEnabled: Bool                   { get set}
    var SLKisKeyboardPanningEnabled: Bool               { get set}
    var SLKshouldScrollToBottomAfterKeyboardShows: Bool { get set}
    var SLKshowTextInputBar: Bool                       { get set}
    
    
//    var topDatasource: RVBaseDatasource4<T>? { get set}
//    var mainDatasource: RVBaseDatasource4<T> { get set}
//    var filterDatasource: RVBaseDatasource4<T> { get set}
    init(scrollView: UIScrollView? )
    func configureSLK() -> Void
    func removeAllSections() -> Void
//    func removeAllSections(callback: @escaping RVCallback<T>) -> Void
    func baseTopQuery() -> (RVQuery, RVError?)
    func baseMainQuery() -> (RVQuery, RVError?)
    func baseFilterQuery() -> (RVQuery, RVError?)
    func buildQuery(query: RVQuery, andTerms: [RVQueryItem], sortTerm: RVSortTerm) -> RVQuery
    func topQuery(andTerms: [RVQueryItem], sortTerm: RVSortTerm) -> (RVQuery, RVError?)
    func mainQuery(andTerms: [RVQueryItem], sortTerm: RVSortTerm ) -> (RVQuery, RVError?)
    func filterQuery(andTerms: [RVQueryItem] , matchTerm: RVQueryItem, sortTerm: RVSortTerm ) -> (RVQuery, RVError?)
    func loadTop(query: RVQuery, callback: @escaping(RVError?)->Void) -> Void
    func loadMain2(andTerms: [RVQueryItem], callback: @escaping(RVError?)-> Void) -> Void
    func loadMain(query: RVQuery, callback: @escaping(RVError?)->Void) -> Void
    func loadSearch(searchText: String, field: RVKeys, order: RVSortOrder, andTerms: [RVQueryItem], callback: @escaping(RVError?)->Void) -> Void
    func endSearch(mainAndTerms: [RVQueryItem], callback: @escaping(RVError? ) -> Void) -> Void
    func loadSearch(query: RVQuery, callback: @escaping(RVError?)->Void) -> Void
//    func loadDatasource(datasource: RVBaseDatasource4<T>, query: RVQuery, callback: @escaping(RVError?)->Void) -> Void
    func initializeDatasource(sectionDatasourceType: RVDatasourceType, mainAndTerms: [RVQueryItem], callback: @escaping(RVError?) -> Void) -> Void
    func getQueryAndLoadMain(andTerms: [RVQueryItem], callback: @escaping(RVError?) -> Void) -> Void
    func loadDynamicSections(sectionDatasourceType: RVDatasourceType, callback: @escaping(RVError?) -> Void) -> Void
    func numberOfSections(tableView: UITableView) -> Int
    func numberOfItems(section: Int) -> Int
    func item(indexPath: IndexPath, scrollView: UIScrollView?) -> RVBaseModel?
    func datasourceInSection(section: Int) -> RVSubbaseModel?
    func toggle(datasource: AnyObject, callback: @escaping (RVError?) -> Void)
    func unsubscribe () -> Void
    func cancelAllOperations() -> Void
    func scrolling(indexPath: IndexPath, scrollView: UIScrollView) -> Void
    var managerDynamicSections: Bool { get }
}
