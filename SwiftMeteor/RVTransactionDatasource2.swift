//
//  RVTransactionDatasource2.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/17/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
class RVTransactionDatasource2: RVBaseDatasource2 {
    override func basicQuery() -> RVQuery {
        let query = RVQuery()
        query.limit = 70
        return query
    }

        override var subscription: RVBaseCollection? { get { return nil } }
    override func bulkQuery(query: RVQuery, callback: @escaping (_ models: [RVBaseModel]?, _ error: RVError?) -> Void) {
        RVTransaction.bulkQuery(query: query, callback: callback)
    }
}
