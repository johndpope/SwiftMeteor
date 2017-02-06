//
//  RVBaseAppState.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 2/2/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//



import UIKit
class RVBaseAppState {
    enum State: String {
        case LoggedOut          = "LoggedOut"
        case LoggedIn            = "LoggedIn"
        case Main               = "Main"
        case WatchGroupList     = "WatchGroupList"
        case WatchGroupInfo     = "WatchGroupInfo"
        case WatchGroupMessages = "WatchGroupMessages"
        case WatchGroupMembers  = "WatchGroupMembers"
        case MessageListState   = "MessageListState"
        case ShowProfile        = "ShowProfile"
        case UserList           = "UserList"
        
        var segmentLabel: String {
            switch(self) {
            case .Main:
                return "Main"
            case .WatchGroupInfo:
                return "Info"
            case .WatchGroupMembers:
                return "Members"
            case .WatchGroupMessages:
                return "Messages"
            default:
                return "Invalid"
            }
        }
    }
    var topInTopAreaHeight: CGFloat = 0.0
    var controllerOuterSegmentedViewHeight: CGFloat = 0.0
    var bottomInTopAreaHeight: CGFloat = 0.0
    
    var instanceType: String { get { return String(describing: type(of: self)) } }
    var state: State = .Main
    var datasources = [RVBaseDataSource]()
    var lastState: RVBaseAppState? = nil
    static let scopeIndexLabel = "scopeIndex"
    static let textLabel = "text"
    var stack = [RVBaseModel]()
    typealias queryFunction = (_ params: [String: AnyObject]) -> (RVQuery)
    typealias QueryElement = [RVBaseDataSource.DatasourceType : queryFunction]
    var queryFunctions = QueryElement()
    
    var showSearchBar: Bool = true
    var tableViewInteractive: Bool = true
    var navigationBarTitle: String = "Title Goes Here" 
    var navigationBarColor: UIColor { get { return RVCoreInfo.sharedInstance.navigationBarColor }}
    var scopes = [[String: RVKeys]]()
    var segmentViewFields: [RVMainViewControllerState.State] = []
    var manager: RVDSManager = RVDSManager(scrollView: nil)
    var dontUseManager: Bool = false
    var showTopView = true
    var installSearchController = true
    var installRefreshControl: Bool = true
    var userProfile: RVUserProfile? { get { return RVCoreInfo.sharedInstance.userProfile }}
    var domain: RVDomain? { get { return RVCoreInfo.sharedInstance.domain }}
    init(stack: [RVBaseModel]? = nil) {
      //  if let scrollView = scrollView { self.manager = RVDSManager(scrollView: scrollView) }
      //  else { self.manager = RVDSManager(scrollView: UIScrollView()) }
        if let stack = stack { self.stack = stack }
        configure()
    }
    func findDatasource(type: RVBaseDataSource.DatasourceType) -> RVBaseDataSource? {
        for datasource in datasources { if datasource.datasourceType == type { return datasource } }
        return nil
    }
    func configure() {}
    func initialize(scrollView: UIScrollView? = nil, callback: @escaping (_ error: RVError?) -> Void) {
        self.manager = RVDSManager(scrollView: scrollView)
        loadMain(callback: callback)
    }
    
    func loadMain(callback: @escaping (_ error: RVError?) -> Void) {
        // self.clearAndCreateWatchGroups()
        for datasource in datasources { manager.addSection(section: datasource)}
        if let mainDatasource = self.findDatasource(type: RVBaseDataSource.DatasourceType.main) {
            if let queryFunction = self.queryFunctions[RVBaseDataSource.DatasourceType.main] {
                let query = queryFunction([String: AnyObject]())
                self.manager.stopAndResetDatasource(datasource: mainDatasource, callback: { (error) in
                    if let error = error {
                        error.append(message: "In \(self.instanceType).loadMain, got error stoping main database")
                        error.printError()
                        callback(error)
                    } else {
                        self.manager.startDatasource(datasource: mainDatasource, query: query, callback: { (error) in
                            if let error = error {
                                error.append(message: "In \(self.instanceType).loadMain, got error starting main database")
                                error.printError()
                                callback(error)
                            } else {
                                callback(nil)
                                // print("In \(self.instanceType).loadMain, completed start")
                            }
                        })
                        return
                    }
                })
                return
            } else {
                print("In \(self.instanceType).loadMain, no queryFunction")
                callback(nil)
            }
        } else {
            print("In \(self.instanceType).loadMain, no mainDatasource")
            callback(nil)
        }
    }
    func unwind(callback: @escaping()-> Void) { manager.removeAllSections { callback() } }
}
