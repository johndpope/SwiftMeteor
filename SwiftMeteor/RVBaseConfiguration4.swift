//
//  RVBaseConfiguration4.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/4/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit

class RVBaseConfiguration4 {
    var instanceType: String { get { return String(describing: type(of: self)) } }
    var configurationName: String   = "RVBaseConfiguration4"
    var navigationBarTitle: String  = "Replace"
    var showSearch: Bool            = true
    var showTopView:Bool            = true
    var installRefresh: Bool        = false
    var SLKIsInverted: Bool         = false
    var showTextInputBar: Bool      = true
    var mainDatasourceMaxSize: Int  = 300
    var filterDatasourceMaxSize: Int = 300
    var topAreaMaxHeights: [CGFloat] = [0.0, 0.0, 0.0]
    var topAreaMinHeights: [CGFloat] = [0.0, 0.0, 0.0]

    var scopes: [[String : RVKeys]]     = [[RVKeys.title.rawValue: RVKeys.title], [RVKeys.fullName.rawValue: RVKeys.fullName]]
    var manager = RVDSManager4(scrollView: nil)
    
    var topDatasource: RVBaseDatasource4? {
        return nil
    }
    var mainDatasource: RVBaseDatasource4 {
        return RVBaseDatasource4(manager: self.manager, datasourceType: .main , maxSize: self.mainDatasourceMaxSize)
    }
    var filterDatasource: RVBaseDatasource4 {
        return RVBaseDatasource4(manager: self.manager, datasourceType: .filter, maxSize: self.filterDatasourceMaxSize)
    }
    
    init(scrollView: UIScrollView? ) {
        self.configurationName      = "RVBaseConfiguration4"
        self.navigationBarTitle     = "Replace"
        self.showSearch             = true
        self.showTopView            = true
        self.installRefresh         = false
        self.SLKIsInverted          = false
        self.navigationBarTitle     = "Transactions"
        self.showTextInputBar       = true
        self.topAreaMaxHeights       = [0.0, 0.0, 0.0]
        self.topAreaMinHeights       = [0.0, 0.0, 0.0]
        self.mainDatasourceMaxSize  = 300
        self.filterDatasourceMaxSize = 300
        self.scopes = [[RVKeys.title.rawValue: RVKeys.title], [RVKeys.fullName.rawValue: RVKeys.fullName]]
        self.manager = RVDSManager4(scrollView: scrollView)
        // update manager
    }
    func install(callback: @escaping(RVError?) -> Void) {
        var datasources = [RVBaseDatasource4]()
        if let top = self.topDatasource { datasources.append(top) }
        datasources.append(mainDatasource)
        manager.appendSections(datasources: datasources) { (models, error ) in
            if let error = error {
                error.append(message: "In \(self.instanceType).install, got error")
            }
            callback(error)
        }
    }
    func search(callback: @escaping(RVError?) -> Void) {
        
    }
}
