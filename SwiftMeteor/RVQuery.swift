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

enum RVSortOrder: String {
    case ascending  = "ascending"
    case descending = "descending"
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
    func duplicate() -> RVQueryItem {
        let item = RVQueryItem()
        item.term = self.term
        item.value = self.value
        item.comparison = self.comparison
        return item
    }
}

class RVQuery {
    var instanceType: String { get { return String(describing: type(of: self)) } }
    func duplicate() -> RVQuery {
        let query = RVQuery()
        query.comment = self.comment
//        query.sortOrder = self.sortOrder
 //       query.sortTerm = self.sortTerm
        for andTerm in self.ands {
            query.ands.append(andTerm.duplicate())
        }
        for orTerm in self.ors {
            query.ors.append(orTerm.duplicate())
        }
        for projection in projections {
            query.projections.append(projection.duplicate())
        }
        for sortTerm in sortTerms {
            query.addSort(sortTerm: sortTerm.duplicate())
        }
        if let textSearch = self.textSearch {
            query.textSearch = textSearch.duplicate()
        } else {
            query.textSearch = nil
        }
        if let fixed = self.fixedTerm {
            query.fixedTerm = fixed.duplicate()
        }
        query.limit = self.limit
        return query
    }
    enum Projection: String {
        case sort = "sort"
        case fields = "fields"
        case limit = "limit"
        case textSearch = "$text"
    }
    static let commentField = "$comment"
    static let limitField = "$limit"
    static let textField = "$text"
    var comment: String?    = nil
    var sortTerms = [RVSortTerm]()
    var fixedTerm: RVQueryItem? = nil
   // var sortOrder: RVSortOrder  = .descending
   // var sortTerm: RVKeys        = .createdAt
    var ands    = [RVQueryItem]()
    var ors     = [RVQueryItem]()
    var projections = [RVProjectionItem]()
    var limit   = 100
    private var textSearch: RVTextTerm? = nil
    init() {
    }
    func findAndTerm(term: RVKeys) -> RVQueryItem? {
        for item in ands {
            if item.term == term {
                return item
            }
        }
        return nil
    }
    func findOrTerm(term: RVKeys) -> RVQueryItem? {
        for item in ors {
            if item.term == term {
                return item
            }
        }
        return nil
    }
    func setTextSearch(value: String, caseSensitive: Bool = false, diacriticSensitive: Bool = false) {
        let search = RVTextTerm(value: value, caseSensitive: caseSensitive, diacriticSensitive: diacriticSensitive)
        self.textSearch = search
    }
    func findProjectionTerm(field: RVKeys) -> RVProjectionItem? {
        for item in projections {
            if item.field == field {
                return item
            }
        }
        return nil
    }
    func findSortTerm(field: RVKeys) -> RVSortTerm? {
        for term in sortTerms {
            if term.field == field { return term }
        }
        return nil
    }
    func removeSortTerm(field: RVKeys) -> RVSortTerm? {
        for index in 0..<sortTerms.count {
            let term = sortTerms[index]
            if term.field == field {
                sortTerms.remove(at: index)
                return term
            }
        }
        return nil
    }
    func removeAllSortTerms() {
        self.sortTerms = [RVSortTerm]()
    }
    func addAnd(term: RVKeys, value: AnyObject, comparison: RVComparison) {
        let queryItem = RVQueryItem(term: term, value: value, comparison: comparison)
        self.addAnd(queryItem: queryItem)
    }
    private func addAnd(queryItem: RVQueryItem) {
        if let existing = findAndTerm(term: queryItem.term) {
            existing.comparison = queryItem.comparison
            existing.value = queryItem.value
        } else {
            self.ands.append(queryItem)
        }
    }
    func addOr(term: RVKeys, value: AnyObject, comparison: RVComparison) {
        let queryItem = RVQueryItem(term: term, value: value, comparison: comparison)
        self.addOr(queryItem: queryItem)
    }
    private func addOr(queryItem: RVQueryItem) {
        if let existing = findOrTerm(term: queryItem.term) {
            existing.comparison = queryItem.comparison
            existing.value = queryItem.value
        }
        self.ors.append(queryItem)
    }
    func addProjection(projectionItem:RVProjectionItem) {
        if let projection = findProjectionTerm(field: projectionItem.field) {
            projection.include = projectionItem.include
        } else {
            self.projections.append(projectionItem)
        }
    }
    func addProjection(field: RVKeys) {
        let projection = RVProjectionItem(field: field)
        self.addProjection(projectionItem: projection)
    }
    func addSort(sortTerm: RVSortTerm) {
        self.addSort(field: sortTerm.field, order: sortTerm.order)
    }

    func addSort(field: RVKeys, order: RVSortOrder) {
        if let term = findSortTerm(field: field) {
            term.order = order
        } else {
            sortTerms.append(RVSortTerm(field: field, order: order))
        }
    }

    func query() -> ([String : AnyObject], [String : AnyObject]) {
        var projections = [String: AnyObject]()
 //       projections[Projection.sort.rawValue] = [sortTerm.rawValue : sortOrder.rawValue] as AnyObject
        var sorts = [AnyObject]()
        if let _ = self.textSearch {
            let search = ["score" : ["$meta" : "textScore"]]
            projections[Projection.sort.rawValue] = search as AnyObject
        } else {
            for sortTerm in sortTerms {
                sorts.append(sortTerm.term() as AnyObject)
            }
            if sorts.count > 0 {
                projections[Projection.sort.rawValue] = sorts as AnyObject?
            }
        }

       // projections[Projection.sort.rawValue] = [["createdAt", "descending"]] as AnyObject // Neil plug
        projections[Projection.limit.rawValue] = self.limit as AnyObject
        
        
        if let _ = self.textSearch {
           // projections[Projection.textSearch.rawValue] = textSearch.term() as AnyObject
           // projections["score"] = ["$meta": "textScore"] as AnyObject
        }
        
        
        var fields = [String : AnyObject]()
        for projection in self.projections {
            let (field, include) = projection.project()
            fields[field] = include as AnyObject
        }
        if let _ = self.textSearch {
            let search = ["$meta": "textScore"]
            fields["score"] = search as AnyObject
        }
        if fields.count > 0 {
            projections[Projection.fields.rawValue] = fields as AnyObject
        }
        var filters = [String : AnyObject]()
        var andQuery = [AnyObject]()
        for and in ands {
            andQuery.append(and.query() as AnyObject )
        }
        if let fixed = self.fixedTerm {
            andQuery.append(fixed.query() as AnyObject )
        }
        if let textSearch = self.textSearch {
             var terms = [String: AnyObject]()
            terms[Projection.textSearch.rawValue] = textSearch.term() as AnyObject
            andQuery.append(terms as AnyObject)
        }
        if andQuery.count > 0 { filters[RVLogic.and.rawValue] = andQuery as AnyObject }
        var orQuery = [AnyObject]()
        for or in ors {
            orQuery.append(or.query() as AnyObject )
        }
        if orQuery.count > 0 { filters[RVLogic.or.rawValue] = orQuery as AnyObject }
        return (filters, projections)
    }
    func updateQuery(front: Bool) -> RVQuery {
        for sortTerm in sortTerms {
            if !updateSort(front: front, field: sortTerm.field){
                print("In \(self.instanceType).updateQuery, no and term matching sort for field: \(sortTerm.field.rawValue)")
            }
            if front {
                switch(sortTerm.order) {
                case .ascending:
                    sortTerm.order = .descending
                case .descending:
                    sortTerm.order = .ascending
                }
            }
        }
        if self.sortTerms.count == 0 {
            print("In \(self.instanceType).updateQuery, no sort Terms :-(")
        }
        return self
    }
    func updateSort(front: Bool, field: RVKeys) -> Bool {
        if let andTerm = findAndTerm(term: field) {
            if !front {
                switch(andTerm.comparison) {
                case .lt:
                    andTerm.comparison = .lte
                case .lte:
                    andTerm.comparison = .lt
                case .gt:
                    andTerm.comparison = .gte
                case .gte:
                    andTerm.comparison = .gt
                default:
                    print("In \(self.instanceType).updateSort, inappropriate comparison of [\(andTerm.comparison.rawValue)] for field: \(field.rawValue)")
                }
            } else {
                switch(andTerm.comparison) {
                case .lt:
                    andTerm.comparison = .gte
                case .lte:
                    andTerm.comparison = .gt
                case .gt:
                    andTerm.comparison = .lte
                case .gte:
                    andTerm.comparison = .lt
                default:
                    print("In \(self.instanceType).updateSort, inappropriate comparison of [\(andTerm.comparison.rawValue)] for field: \(field.rawValue)")
                }
            }
            return true
        } else {
            return false
        }
    }
}


class RVProjectionItem {
    var field: RVKeys
    var include: Include
    init(field: RVKeys, include: RVProjectionItem.Include = .include) {
        self.field = field
        self.include = include
    }
    enum Include: Int {
        case include = 1
        case exclude = 0
    }
    func project() -> (String, Int) {
        return (self.field.rawValue, self.include.rawValue)
    }
    func duplicate() -> RVProjectionItem {
        let item = RVProjectionItem(field: self.field , include: self.include)
        return item
    }
}
class RVTextTerm {
    var value: String
    var caseSensitive: Bool = false
    var diacriticSensitive: Bool = false
    init(value: String, caseSensitive: Bool = false, diacriticSensitive: Bool = false) {
        self.value = value
        self.caseSensitive = caseSensitive
        self.diacriticSensitive = diacriticSensitive
    }
    func term() -> [String : AnyObject] {
        var term = [String: AnyObject]()
        term["$search"] = self.value as AnyObject
  //      term["$caseSensitive"] = self.caseSensitive as AnyObject
  //      term["$diacriticSensitive"] = self.diacriticSensitive as AnyObject
        return term
    }
    func duplicate() -> RVTextTerm {
        let term = RVTextTerm(value: self.value, caseSensitive: self.caseSensitive, diacriticSensitive: self.diacriticSensitive)
        return term
    }
}
class RVSortTerm {
    var field: RVKeys
    var order: RVSortOrder
    init(field: RVKeys = .createdAt, order: RVSortOrder = .descending) {
        self.field = field
        self.order = order
    }
    func term() -> AnyObject {
        let result = [self.field.rawValue, self.order.rawValue]

        return result as AnyObject
    }
    func duplicate() -> RVSortTerm {
        return RVSortTerm(field: self.field, order: self.order)
    }
}
