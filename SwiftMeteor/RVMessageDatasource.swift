//
//  RVMessageDatasource.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 2/4/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation

class RVMessageDatasource: RVBaseDataSource {
    override func bulkQuery(query: RVQuery, callback: @escaping (_ models: [RVBaseModel]?, _ error: RVError?) -> Void) {
        RVMessage.bulkQuery(query: query, callback: callback)
    }
    override func basicQuery() -> RVQuery {
        let query = RVQuery()
        query.limit = 70
        query.addSort(field: .createdAt, order: .descending)
        query.addAnd(term: .special, value: RVSpecial.root.rawValue as AnyObject, comparison: .ne)
        return query
    }
}
