//
//  RVMainViewControllerState.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/26/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
class RVMainViewControllerState {
    var instanceType: String { get { return String(describing: type(of: self)) } }
    var datasources = [RVBaseDataSource]()
    static let scopeIndexLabel = "scopeIndex"
    static let textLabel = "text"
    var stack = [RVBaseModel]()
    typealias queryFunction = (_ params: [String: AnyObject]) -> (RVQuery)
    typealias QueryElement = [RVBaseDataSource.DatasourceType : queryFunction]
    var queryFunctions = QueryElement()
    var scopes = [[String: RVKeys]]()
    var segmentViewFields =  [[String: RVKeys]]()
    var manager: RVDSManager
    var dontUseManager: Bool = false
    var showTopView = true
    var userProfile: RVUserProfile? { get { return RVCoreInfo.sharedInstance.userProfile }}
    var domain: RVDomain? { get { return RVCoreInfo.sharedInstance.domain }}
    init(scrollView: UIScrollView) {
        self.manager = RVDSManager(scrollView: scrollView)
        configure()
    }
    func findDatasource(type: RVBaseDataSource.DatasourceType) -> RVBaseDataSource? {
        for datasource in datasources {
            if datasource.datasourceType == type { return datasource }
        }
        return nil
    }
    func configure() {}
    func initialize() {}
}
