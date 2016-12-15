//
//  RVQuery.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 12/14/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import Foundation

// https://docs.mongodb.com/manual/reference/operator/query/
// https://themeteorchef.com/tutorials/mongodb-queries-and-projections

enum RVSortOrder: Int {
    case ascending  = 1
    case descending = -1
}
enum RVComparison: String {
    case lt = "$lt"
    case lte = "$lte"
    case eq = "$eq"
    case gte = "$gte"
    case gt = "$gt"
    case ne = "$ne"
    case includes = "$in"
    case notIn = "$nin"
}
enum RVExists: String {
    case exists = "$exists"
   // case doesntExist = "$???"
}

enum RVLogic: String {
    case or = "$or"
    case and = "$and"
    case not = "$not"
    case nor = "$nor"
}
enum RVGeoSpatial: String {
    case geoWithin = "$geoWithin"
    case geoIntersects = "$geoIntersects"
    case near = "$near"
    case nearSphere = "$nearSphere"
}
class RVQueryItem {
    var term: RVKeys = RVKeys._id
    var value: AnyObject = "" as AnyObject
    var comparison: RVComparison = .eq
    init(term: RVKeys = RVKeys._id, value: AnyObject = "" as AnyObject,  comparison: RVComparison = .eq) {
        self.term = term
        self.value = value
        self.comparison = comparison
    }
    func query() -> [String: AnyObject] {
        return [term.rawValue : [comparison.rawValue : value ] as AnyObject ]
    }
}
class RVQuery {
    enum commands: String {
        case sort = "sort"
        case fields = "fields"
        case limit = "limit"
    }
    static let commentField = "$comment"
    static let limitField = "$limit"
    var comment: String?    = nil
    var sortOrder: RVSortOrder  = .descending
    var sortTerm: RVKeys        = .createdAt
    var ands    = [RVQueryItem]()
    var ors     = [RVQueryItem]()
    var limit   = 100
    init() {
    }
    func addAnd(queryItem: RVQueryItem) {
        self.ands.append(queryItem)
    }
    func addOr(queryItem: RVQueryItem) {
        self.ors.append(queryItem)
    }
    func query() -> ([String : AnyObject], [String : AnyObject]) {
        var projections = [String: AnyObject]()
        projections[commands.sort.rawValue] = [sortTerm.rawValue : sortOrder.rawValue] as AnyObject
        projections[commands.limit.rawValue] = self.limit as AnyObject
        var filters = [String : AnyObject]()
        var andQuery = [AnyObject]()
        for and in ands {
            andQuery.append(and.query() as AnyObject )
        }
        if andQuery.count > 0 { filters[RVLogic.and.rawValue] = andQuery as AnyObject }
        var orQuery = [AnyObject]()
        for or in ors {
            orQuery.append(or.query() as AnyObject )
        }
        if orQuery.count > 0 { filters[RVLogic.or.rawValue] = orQuery as AnyObject }
        return (filters, projections)
    }
}


class RVProjection {
    enum include: Int {
        case include = 1
        case exclude = 0
    }
    enum commands: String {
        case sort = "sort"
        case fields = "fields"
    }
}
