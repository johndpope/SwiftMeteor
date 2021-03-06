//
//  RVBaseTopViewDatasource.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/18/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
class RVBaseTopViewDatasource: RVBaseDatasource2 {
    var FakeAnEntry: Bool = true
    override func basicQuery() -> RVQuery {
        let query = RVQuery()
        query.addSort(field: .createdAt, order: .ascending)
        query.limit = 70
        return query
    }
    override func bulkQuery(query: RVQuery, callback: @escaping (_ models: [RVBaseModel]?, _ error: RVError?) -> Void) {
        if self.array.count == 0 && FakeAnEntry {
            callback([RVBaseModel()], nil)
        } else {
            callback([RVBaseModel](), nil)
        }

    }

}
