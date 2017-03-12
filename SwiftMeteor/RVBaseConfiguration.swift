//
//  RVBaseConfiguration.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/11/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
class RVBaseConfiguration {
    var instanceType: String { get { return String(describing: type(of: self)) } }
    var configurationName: String = "RVBaseConfiguration"
    let manager = RVDSManager2()
    var subscriptionId: String? = nil
    var topDatasource: RVBaseDataSource? = nil
    var mainDatasource: RVBaseDataSource? = nil
    var filterDatasource: RVBaseDataSource? = nil
    var datasources = [RVBaseDataSource]()
    typealias queryFunction = (_ params: [String: AnyObject]) -> (RVQuery)
    typealias QueryElement = [RVBaseDataSource.DatasourceType : queryFunction]
    var queryFunctions = QueryElement()
    var installSearchController: Bool   = true
    var installRefreshControl: Bool     = true
    var loggedInUserProfile:    RVUserProfile?  { get { return RVCoreInfo2.shared.loggedInUserProfile }}
    var domain:                 RVDomain?       { get { return RVCoreInfo2.shared.domain }}
    var domainId:               String?         { get { return RVCoreInfo2.shared.domainId }}
    

}

extension RVBaseConfiguration {
    func install(callback: @escaping() -> Void) {
        self.unwind {
            if let datasource = self.topDatasource      { self.addSection(section: datasource) }
            if let datasource = self.mainDatasource     { self.addSection(section: datasource) }
            if let datasource = self.filterDatasource   { self.addSection(section: datasource) }
        }
    }
    func addSection(section: RVBaseDataSource) {
        self.manager.addSection(section: section)
        self.datasources.append(section)
    }
    func unwind(callback: @escaping() -> Void ) {
        manager.removeAllSections {
            self.datasources = [RVBaseDataSource]()
            callback()
        }
    }
    func findDatasource(type: RVBaseDataSource.DatasourceType) -> RVBaseDataSource? {
        for datasource in datasources { if datasource.datasourceType == type { return datasource } }
        return nil
    }
}
