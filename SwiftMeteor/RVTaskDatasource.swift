//
//  RVTaskDatasource.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/6/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
import SwiftDDP

class RVTaskDatasource: RVBaseDataSource {
    
    override func bulkQuery(query: RVQuery, callback: @escaping (_ models: [RVBaseModel]?, _ error: RVError?) -> Void) {
        RVTask.bulkQuery(query: query, callback: callback)
    }
 
    
    override func basicQuery() -> RVQuery {
        let query = RVQuery()
        query.limit = 70
        //        query.sortOrder = .descending
        //        query.sortTerm = .createdAt
        query.addSort(field: .createdAt, order: .descending)
        query.addAnd(term: .createdAt, value: EJSON.convertToEJSONDate(Date()) as AnyObject, comparison: .lte)
      //  query.addOr(queryItem: RVQueryItem(term: .owner, value: "Goober" as AnyObject, comparison: .eq))
      //  query.addOr(queryItem: RVQueryItem(term: .private, value: true as AnyObject, comparison: .ne))
        query.addProjection(projectionItem: RVProjectionItem(field: .text, include: .include))
        query.addProjection(projectionItem: RVProjectionItem(field: .createdAt))
        query.addProjection(projectionItem: RVProjectionItem(field: .updatedAt))
        query.addProjection(projectionItem: RVProjectionItem(field: .regularDescription))
        query.addProjection(projectionItem: RVProjectionItem(field: .comment))
        query.addProjection(field: .handle)
        query.addProjection(field: .title)
    
        return query
    }
    
}
