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
    var topDatasource:      RVBaseDataSource? = nil
    var mainDatasource:     RVBaseDataSource? = nil
    var filterDatasource:   RVBaseDataSource? = nil
    var showSearch:         Bool = false
    var showTopView:        Bool = false
    var installRefresh:     Bool = false
    var scopes              = [[String: RVKeys]]()
    var topInTopAreaHeight:     CGFloat = 0.0
    var middleInTopAreaHeight:  CGFloat = 0.0
    var bottomInTopAreaHeight:  CGFloat = 0.0
    var stack = [RVBaseModel]()
    var datasources =      [RVBaseDataSource]()
    var navigationBarColor = UIColor.facebookBlue()
    var SLKIsInverted: Bool = true
    typealias queryFunction = (_ params: [String: AnyObject]) -> (RVQuery)
    typealias QueryElement = [RVBaseDataSource.DatasourceType : queryFunction]
    var queryFunctions = QueryElement()
    var installSearchController:    Bool   = true
    var installRefreshControl:      Bool   = true
    var loggedInUserProfile:        RVUserProfile?  { get { return RVCoreInfo2.shared.loggedInUserProfile }}
    var loggedInUserProfileId:      String? {
        get {
            if let profile = self.loggedInUserProfile { return profile.localId }
            return nil
        }
    }
    var domain:                     RVDomain?       { get { return RVCoreInfo2.shared.domain }}
    var domainId:                   String?         { get { return RVCoreInfo2.shared.domainId }}
    func configure(stack: [RVBaseModel], callback: @escaping () -> Void) {
        self.stack = stack
        configureUI()
        createDatasources()
        createQueries()
        callback()
    }
    func configureUI() {
        print("In \(self.instanceType).configureUI needs to be overridden")
    }
    func createDatasources() {
        print("In \(self.instanceType).createDatasources needs to be overridden")
    }
    func createQueries() {
        print("In \(self.instanceType).createQueries needs to be overridden")
    }
    

}

extension RVBaseConfiguration {
    func install(scrollView: UIScrollView?, callback: @escaping(RVError?) -> Void) {
      //  print("In \(self.instanceType).install")
        self.unwind {
                //    print("In \(self.instanceType).install; unwound")
                        self.loaded = true
            self.createDatasources()
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
        self.datasources.append(section)
    }
    func unwind(callback: @escaping() -> Void ) {
        manager.removeAllSections {
            self.datasources = [RVBaseDataSource]()
            self.loaded = false
            callback()
        }
    }
    func findDatasource(candidate: RVBaseDataSource) -> RVBaseDataSource? {
        for datasource in datasources { if datasource === candidate { return datasource } }
        return nil
    }
}
