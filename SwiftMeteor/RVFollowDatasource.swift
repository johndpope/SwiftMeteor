//
//  RVFollowDatasource.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 2/4/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
class RVFollowDatasource: RVBaseDataSource {
    override func bulkQuery(query: RVQuery, callback: @escaping (_ models: [RVBaseModel]?, _ error: RVError?) -> Void) {
        RVFollow.bulkQuery(query: query, callback: callback)
    }
    override func basicQuery() -> RVQuery {
        let query = RVQuery()
        query.limit = 70
        return query
    }
}
