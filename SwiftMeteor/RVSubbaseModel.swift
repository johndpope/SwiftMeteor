//
//  RVSubbaseModel.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/26/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
import SwiftDDP

class RVSubbaseModel: RVMeteorDocument {
    required init(id: String, fields: NSDictionary?) {
        super.init(id: id, fields: fields )
    }
    
    class var baseQuery: (RVQuery, RVError?) {
        // let query = RVQuery()
        // query.addAnd(term: .deleted, value: false as AnyObject, comparison: .eq)
        // return query
        
        
        get {
            let query = RVQuery()
            var error: RVError? = nil
            //query.addAnd(term: .modelType, value: RVModelType.transaction.rawValue as AnyObject, comparison: .eq)
            query.addAnd(term: .deleted, value: false as AnyObject, comparison: .eq)
            //query.addAnd(term: .deleted, value: false as AnyObject, comparison: .eq)
            //query.limit = 10
            if let loggedInUserId = RVTransaction.loggedInUserId {
                query.addAnd(term: .targetUserProfileId, value: loggedInUserId as AnyObject, comparison: .eq)
            } else {
                error = RVError(message: "In \(self.classForCoder).basicQuery, no loggedInUserId")
            }
            if let domainId = RVTransaction.appDomainId {
                query.addAnd(term: .domainId, value: domainId as AnyObject, comparison: .eq)
            } else {
                error = RVError(message: "In \(self.classForCoder).basicQuery, no domainId")
            }
            return (query, error)
        }
        
        
    }
    
    class func meteorMethod(request: RVCrud) -> String {
        return "\(RVMeteorMethod.Prefix.lowercased())\(collectionType().rawValue.lowercased())\(RVMeteorMethod.Separator)\(request.rawValue.lowercased())"
    }
    class func collectionType() -> RVModelType { return RVModelType.baseModel }
    class func modelFromFields(fields: [String: AnyObject]) -> RVBaseModel { return RVBaseModel(fields: fields) }
    class func bulkQuery(query: RVQuery, callback: @escaping(_ items: [RVBaseModel], _ error: RVError?)-> Void) {
        if let appDomainId = RVBaseModel.appDomainId {
            
            query.addAnd(term: .domainId, value: appDomainId as AnyObject, comparison: .eq)
        }
        
        let (filters, projection) = query.query()
        //print("In RVBaseModel.bulkQuery")
        Meteor.call(meteorMethod(request: .list), params: [filters as AnyObject, projection as AnyObject]) { (result: Any?, error : DDPError?) in
            //        Meteor.call(bulkQueryMethod.rawValue, params: [filters as AnyObject, projection as AnyObject]) { (result: Any?, error : DDPError?) in
            // print("In RVBaseModel.bulkQuery has response \(error), \(result)")
            DispatchQueue.main.async {
                if let error = error {
                    let rvError = RVError(message: "In RVBaseModel.bulkQuery, got Meteor Error", sourceError: error)
                    callback([RVBaseModel]() , rvError)
                    return
                } else if let items = result as? [[String: AnyObject]] {
                    var models = [RVBaseModel]()
                    for fields in items {
                        models.append(modelFromFields(fields: fields))
                    }
                    callback(models, nil)
                    return
                } else if let results = result {
                    print("In RVBaseModel.bulkQuery, no error, but results are: \n\(results)")
                    callback([RVBaseModel](), nil)
                } else {
                    print("In RVBaseModel.bulkQuery, no error but no results")
                    callback([RVBaseModel](), nil)
                }
            }
        }
    }
}
