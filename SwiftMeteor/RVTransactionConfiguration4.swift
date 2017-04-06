//
//  RVTransactionConfiguration4.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/5/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
class RVTransactionConfiguration4: RVBaseConfiguration4 {
    override var mainDatasource: RVBaseDatasource4 {
        return RVTransactionDatasource44(manager: self.manager, datasourceType: .main, maxSize: 80)
        
    }
    override var filterDatasource: RVBaseDatasource4 {
        return RVTransactionDatasource44(manager: self.manager, datasourceType: .filter, maxSize: self.mainDatasourceMaxSize)
    }
    override func baseMainQuery() -> (RVQuery, RVError?) {
        return RVTransaction.baseQuery
    }
    override func baseFilterQuery() -> (RVQuery, RVError?) {
        return RVTransaction.baseQuery
    }
}
