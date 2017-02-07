//
//  RVUserDatasource.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 2/5/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation

class RVUserDatasource: RVBaseDataSource {
    override func bulkQuery(query: RVQuery, callback: @escaping (_ models: [RVBaseModel]?, _ error: RVError?) -> Void) {
        RVUserProfile.bulkQuery(query: query, callback: callback)
    }
    override func basicQuery() -> RVQuery {
        let query = RVQuery()
        query.limit = 70
        return query
    }
}
