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
        case LoggedOut  = "LoggedOut"
        case LoggedIn   = "LoggedIn"
        case ShowProfile = "ShowProfile"
        case MenuState = "MenuState"
        case Main = "Main"
        case WatchGroupList = "WatchGroupList"
        case WatchGroupInfo = "WatchGroupInfo"
        case WatchGroupMessages = "WatchGroupMessages"
        case WatchGroupMembers = "WatchGroupMembers"

        
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
    var doNotInclude: Bool = false
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
    var navigationBarTitle: String {
        get { return "Title Goes Here" }
    }
    var scopes = [[String: RVKeys]]()
    var segmentViewFields: [RVMainViewControllerState.State] = []
    var manager: RVDSManager
    var dontUseManager: Bool = false
    var showTopView = true
    var installSearchController = true
    var installRefreshControl: Bool = true
    var userProfile: RVUserProfile? { get { return RVCoreInfo.sharedInstance.userProfile }}
    var domain: RVDomain? { get { return RVCoreInfo.sharedInstance.domain }}
    init(scrollView: UIScrollView? = nil, stack: [RVBaseModel]? = nil) {
        if let scrollView = scrollView { self.manager = RVDSManager(scrollView: scrollView) }
        else { self.manager = RVDSManager(scrollView: scrollView) }
        if let stack = stack { self.stack = stack }
        configure()
        if scrollView == nil { print("In \(instanceType).init, no ScrollView provided")}
    }
    func findDatasource(type: RVBaseDataSource.DatasourceType) -> RVBaseDataSource? {
        for datasource in datasources { if datasource.datasourceType == type { return datasource } }
        return nil
    }
    func configure() {
       // print("In RVBaseAppState.configure")
    }
    func initialize() {}
    func unwind(callback: @escaping()-> Void) { manager.removeAllSections { callback() } }
}