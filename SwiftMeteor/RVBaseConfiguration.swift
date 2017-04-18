//
//  RVBaseConfiguration.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/11/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
class RVBaseConfiguration {
    static let textField = "text"
    static let sortField = "sortField"
    static let DefaultFilterSize: Int = 300
    var loaded: Bool = false
    var instanceType: String { get { return String(describing: type(of: self)) } }
    var configurationName: String = "RVBaseConfiguration"
    var navigationBarTitle: String = "Replace"
    var manager =           RVDSManager2()
    var subscriptionId:     String? = nil
    fileprivate var _top: RVBaseDataSource? = nil
    fileprivate var _main: RVBaseDataSource? = nil
    fileprivate var _filter: RVBaseDataSource? = nil
    var topDatasource:      RVBaseDataSource? {
        get {
            if let ds = _top { return ds }
            _top = instantiateTopDatasource()
            return _top
        }
    }
    var mainDatasource:     RVBaseDataSource? {
        get {
            if let ds = _main { return ds }
            _main = instantiateMainDatasource()
            return _main
        }
    }
    var filterDatasource:   RVBaseDataSource? {
        get {
            if let ds = _filter { return ds }
            _filter = instantiateFilterDatasource()
            return _filter
        }
    }
    var showSearch:         Bool = false
    var showTopView:        Bool = false
    var installRefresh:     Bool = false
    var scopes              = [[String: RVKeys]]()
    var topInTopAreaHeight:     CGFloat = 0.0
    var middleInTopAreaHeight:  CGFloat = 0.0
    var bottomInTopAreaHeight:  CGFloat = 0.0
    var stack = [RVBaseModel]()
    //var datasources =      [RVBaseDataSource]()
    var navigationBarColor = UIColor.facebookBlue()
    var SLKIsInverted: Bool = true
    var showTextInputBar: Bool = true
    typealias queryFunction = (_ params: [String: AnyObject]) -> (RVQuery)
    typealias queryFunction4 = (_ dynamicAnds: [RVQueryItem], _ matches: RVQueryItem?) -> RVQuery
    func dynamicQuery(_ dynamicAnds: [RVQueryItem], _ match: RVQueryItem? = nil, _ sortTerms: [RVSortTerm] = [RVSortTerm()]) -> (RVQuery, RVError?){
        let (query, error) = RVTransaction.baseQuery
        if let error = error {
            error.append(message: "In \(self.instanceType).dynamicQuery, got error")
        } else {
            for and in dynamicAnds  { query.addAnd(term: and.term, value: and.value, comparison: and.comparison) }
            if let match = match    { query.fixedTerm = match }
            for sort in sortTerms   { query.addSort(sortTerm: sort) }
        }
        return (query, error)
    }
    typealias QueryElement = [RVBaseDataSource.DatasourceType : queryFunction]
    var queryFunctions = QueryElement()
    var installSearchController:    Bool   = true
    var installRefreshControl:      Bool   = true
    var loggedInUserProfile:        RVUserProfile?  { get { return RVBaseCoreInfo8.sharedInstance.loggedInUserProfile }}
    var loggedInUserProfileId:      String?         { get { return RVBaseCoreInfo8.sharedInstance.loggedInUserProfileId }}
    var domain:                     RVDomain?       { get { return RVBaseCoreInfo8.sharedInstance.domain }}
    var domainId:                   String?         { get { return RVBaseCoreInfo8.sharedInstance.domainId }}
    func configure(stack: [RVBaseModel], callback: @escaping () -> Void) {
        self.stack = stack
        configureUI()
        createQueries()
        callback()
    }
    func configureUI() {
        print("In \(self.instanceType).configureUI needs to be overridden")
    }
    func createQueries() {
        print("In \(self.instanceType).createQueries needs to be overridden")
    }
    func instantiateTopDatasource() -> RVBaseDataSource? {
        return nil
    }
    func instantiateMainDatasource() -> RVBaseDataSource? {
        return nil
    }
    func instantiateFilterDatasource() -> RVBaseDataSource? {
        return nil
    }
    func nullOutDatasources() {
        _top        = nil
        _main       = nil
        _filter     = nil
    }

}

extension RVBaseConfiguration {
    func performSearch(scrollView: UIScrollView?, searchParams: [String: AnyObject], callback: @escaping(RVError?) -> Void) {
        if let filterDatasource = self.filterDatasource {

                    if let queryFunction = self.queryFunctions[.filter] {
                        let query = queryFunction(searchParams)
                        self.manager.startDatasource(datasource: filterDatasource, query: query, callback: { (error) in
                            DispatchQueue.main.async {
                                if let error = error {
                                    error.append(message: "In \(self.instanceType).performSearch, got error")
                                    callback(error)
                                    return
                                } else {
                                    callback(nil)
                                }
                            }

                        })
                        return
                    } else {
                        print("In \(self.instanceType).performSearch no Filter Query Function.............")
                        callback(nil)
                    }
                }
    

    }
    func install(scrollView: UIScrollView?, callback: @escaping(RVError?) -> Void) {
      //  print("In \(self.instanceType).install")
        self.unwind {
                //    print("In \(self.instanceType).install; unwound")
                        self.loaded = true
            self.manager = RVDSManager2(scrollView: scrollView)
            if let datasource = self.topDatasource      { self.addSection(section: datasource) }
            if let datasource = self.mainDatasource     { self.addSection(section: datasource) }
            if let datasource = self.filterDatasource   { self.addSection(section: datasource) }


            if let datasource = self.topDatasource {
                                 //   print("In \(self.instanceType).install; haveTopDatasource")
                if let queryFunction = self.queryFunctions[.top] {
                    let query = queryFunction([String: AnyObject]())
                   // print("In \(self.instanceType).install; haveTopDatasource Query")
                    self.manager.startDatasource(datasource: datasource , query: query, callback: { (error) in
                      //  print("In \(self.instanceType).install;  returned from topDatasource start")
                        if let error = error {
                            error.append(message: "In \(self.instanceType).unwind, got error starting TopDatasource")
                            callback(error)
                            return
                        } else {
                           // print("In \(self.instanceType)linstall, starting Main Datasource)")
                            if let datasource = self.mainDatasource {
                                if let queryFunction = self.queryFunctions[.main] {
                                    let query = queryFunction([String: AnyObject]())
                                    self.manager.startDatasource(datasource: datasource, query: query, callback: { (error) in
                                        if let error = error {
                                            error.append(message: "In \(self.instanceType).install, got error starting main Datasource")
                                            callback(error)
                                            return
                                        } else {
                                            callback(nil)
                                            return
                                        }
                                    })
                                    return
                                } else {
                                    print("In \(self.instanceType).install, no queryFunction for top")
                                    let error = RVError(message: "In \(self.instanceType).install, no queryFunction for main")
                                    callback(error)
                                }
                            } else {
                                let error = RVError(message: "In \(self.instanceType).install, no main Datasource")
                                callback(error)
                                return
                            }
                        }
                    })
                    return
                } else {
                    print("In \(self.instanceType).install, no queryFunction for top")
                    let error = RVError(message: "In \(self.instanceType).install, no queryFunction for top")
                    callback(error)
                }
                
            } else {
                print("In \(self.instanceType).install, no top Datasource")
                let error = RVError(message: "In \(self.instanceType).install, no queryFunction for top")
                callback(error)
            }
        }
    }
    func addSection(section: RVBaseDataSource) {
        self.manager.addSection(section: section)
        //self.datasources.append(section)
    }
    func unwind(callback: @escaping() -> Void ) {
        manager.removeAllSections {
            self.nullOutDatasources()
            self.loaded = false
            callback()
        }
    }
    /*
    func findDatasource(candidate: RVBaseDataSource) -> RVBaseDataSource? {
        for datasource in datasources { if datasource === candidate { return datasource } }
        return nil
    }
 */
    func findDatasource(type: RVBaseDataSource.DatasourceType ) -> RVBaseDataSource? {
        switch(type) {
        case .top:
            return _top
        case .main:
            return _main
        case .filter:
            return _filter
        default:
            print("In \(self.instanceType).findDatasource, unaddressed type: \(type.rawValue)")
            return nil
        }
    }
}
