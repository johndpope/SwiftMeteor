//
//  RVBaseDatasource2.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/16/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation

class RVBaseDatasource2: RVBaseDataSource {

    override var virtualCount: Int { get { return array.count + offset } }
    override var scrollViewCount: Int {
        get {
            if collapsed { return 0 }
            return virtualCount
        }
    }

}

class RVQueryForFrontOperation<T: NSObject>: RVAsyncOperation<T> {
    private var pcallback: (RVError?) -> Void
    init(title: String, datasource: RVBaseDatasource2, callback: @escaping(RVError?) -> Void ) {
        self.pcallback = callback
        super.init(title: title , callback: {(models: [T], error: RVError?) in }, parent: datasource)
    }
    func createFrontQuery(sourceQuery: RVQuery, datasource: RVBaseDataSource) -> RVQuery {
        let query = sourceQuery.duplicate().updateQuery(front: true)
        if let candidate = datasource.array.first {
            var index = 0
            for sort in query.sortTerms {
                if index == 0 {
                    switch (sort.field) {
                    case .createdAt:
                        if let candidateCreatedAt = candidate.createdAt {
                            if let queryTerm = query.findAndTerm(term: sort.field) {
                                queryTerm.value = RVEJSON.convertToEJSONDate(candidateCreatedAt) as AnyObject
                            }
                        }
                    case .commentLowercase:
                        if let candidateComment = candidate.comment {
                            if let queryTerm = query.findAndTerm(term: sort.field) {
                                queryTerm.value = candidateComment.lowercased() as AnyObject
                            }
                        }
                    case .handleLowercase, .handle:
                        if let handle = candidate.handle {
                            if let queryTerm = query.findAndTerm(term: sort.field) {
                                queryTerm.value = handle.lowercased() as AnyObject
                            }
                        }
                    case .title:
                        if let title = candidate.title {
                            if let queryTerm = query.findAndTerm(term: sort.field) {
                                queryTerm.value = title.lowercased() as AnyObject
                            }
                        }
                    case .fullName:
                        if let fullName = candidate.fullName {
                            if let queryTerm = query.findAndTerm(term: sort.field) {
                                queryTerm.value = fullName.lowercased() as AnyObject
                            }
                        }
                    default:
                        print("in \(self.instanceType).queryForFront, term \(sort.field.rawValue) not implemented")
                    }
                }
                index = index +  1
            }
        }
        return query
        
    }
    override func asyncMain() {
        if self.isCancelled {
            pcallback(nil)
            completeOperation()
            return
        }
        if let datasource = self.parent as? RVBaseDatasource2 {
            if datasource.filterMode {
                pcallback(nil)
                completeOperation()
                return
            } else if var query = datasource.baseQuery {
                if query.inSearchMode {
                    pcallback(nil)
                    completeOperation()
                    return
                } else if datasource.array.count == 0 {
                    pcallback(nil)
                    completeOperation()
                    return
                } else {
                    if let _ = datasource.array.first {
                        query = createFrontQuery(sourceQuery: query, datasource: datasource)
                        if self.isCancelled {
                            pcallback(nil)
                            completeOperation()
                            return
                        }
                        datasource.bulkQuery(query: query, callback: { (models , error) in
                            DispatchQueue.main.async {
                                if self.isCancelled {
                                    self.pcallback(nil)
                                    self.completeOperation()
                                    return
                                } else {
                                    if let error = error {
                                        error.append(message: "In \(self.instanceType).operation, got error")
                                        self.pcallback(error)
                                        self.completeOperation()
                                        return
                                    } else if let _ = models {
                       //                 datasource.insertAtFront(operation: <#T##RVDSOperation#>, items: models)
                                    } else {
                                        print("In \(self.instanceType).operation, no error but no results")
                                        self.pcallback(nil)
                                        self.completeOperation()
                                        return
                                    }
                                }
                            }

                        })
                        return
                    } else {
                        let error = RVError(message: "In \(self.classForCoder).operation, illogical state, no first entry")
                        pcallback(error)
                        completeOperation()
                        return
                    }
                }
            } else {
                print("In \(self.classForCoder).opeation, no datasource")
                pcallback(nil)
                completeOperation()
                return
            }
        } else {
            print("In \(self.classForCoder).opeation, no datasource")
            pcallback(nil)
            completeOperation()
        }
    }
}
