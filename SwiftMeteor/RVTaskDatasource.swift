//
//  RVTaskDatasource.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/6/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit


class RVTaskDatasource: RVBaseDataSource {
    
    override func bulkQuery(query: RVQuery, callback: @escaping (_ models: [RVBaseModel]?, _ error: RVError?) -> Void) {
        RVTask.bulkQuery(query: query, callback: callback)
    }
 
    
    override func basicQuery() -> RVQuery {
        let query = RVQuery()
        query.limit = 70
        query.addSort(field: .createdAt, order: .descending)
        query.addAnd(term: .createdAt, value: RVEJSON.convertToEJSONDate(Date()) as AnyObject, comparison: .lte)
        query.addAnd(term: .special, value: RVSpecial.root.rawValue as AnyObject, comparison: .ne)
      //  query.addOr(queryItem: RVQueryItem(term: .owner, value: "Goober" as AnyObject, comparison: .eq))
      //  query.addOr(queryItem: RVQueryItem(term: .private, value: true as AnyObject, comparison: .ne))
        query.addProjection(projectionItem: RVProjectionItem(field: .text, include: .include))
        query.addProjection(projectionItem: RVProjectionItem(field: .createdAt))
        query.addProjection(projectionItem: RVProjectionItem(field: .updatedAt))
        query.addProjection(projectionItem: RVProjectionItem(field: .regularDescription))
        query.addProjection(projectionItem: RVProjectionItem(field: .comment))
        query.addProjection(field: .handle)
        query.addProjection(field: .title)
        query.addProjection(field: .modelType)
        query.addProjection(field: .collection)
        query.addProjection(field: .parentId)
        query.addProjection(field: .parentModelType)
    
        return query
    }
    
}
