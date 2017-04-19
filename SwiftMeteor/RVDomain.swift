//
//  RVDomain.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/20/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
import SwiftDDP
enum RVDomainName: String {
    case Rendevu = "Rendevu"
    case PortolaValley = "PortolaValley"
    case unknown = "unknown"
}
class RVDomain: RVBaseModel {
    override class func collectionType() -> RVModelType { return RVModelType.domain }
    override class var insertMethod: RVMeteorMethods { get { return RVMeteorMethods.domainCreate} }
    override class var updateMethod: RVMeteorMethods { get { return RVMeteorMethods.domainUpdate } }
    override class var deleteMethod: RVMeteorMethods { get { return RVMeteorMethods.domainDelete } }
    override class var findMethod: RVMeteorMethods { get { return RVMeteorMethods.domainFindById}}
    override class var findOneMethod: RVMeteorMethods { get { return RVMeteorMethods.domainFindOne}}
    override class var bulkQueryMethod: RVMeteorMethods { get { return RVMeteorMethods.domainBulkQuery } }

    var domainName: RVDomainName {
        get {
            if let rawValue = getString(key: .domainName) {
                if let domainName = RVDomainName(rawValue: rawValue) { return domainName }
            }
            return .unknown
        }
        set { updateString(key: .domainName, value: newValue.rawValue, setDirties: true) }
    }
    
    func findOrCreate(callback: @escaping(_ domain: RVDomain?, _ error: RVError?) -> Void) {
        let fields = self.dirties
        self.dirties = [String:AnyObject]()
        Meteor.call(RVMeteorMethods.domainCreate.rawValue, params: [fields]) { (result, error) in
            DispatchQueue.main.async {
                if let error = error {
                    let rvError = RVError(message: "In \(self.instanceType).findOrCreate, got DDP error", sourceError: error , lineNumber: #line, fileName: "")
                    callback(nil, rvError)
                    return
                } else if let fields = result as? [String: AnyObject] {
                    callback(RVDomain(fields: fields), nil)
                    return
                } else {
                    print("In \(self.instanceType).findOrCreate, no error but no result")
                    callback(nil, nil)
                }
            }
        }
    }
    /*
    class func findOne(query: RVQuery, callback: @escaping(_ domain: RVDomain?, _ error: RVError?) -> Void) {
        let (filters, projection) = query.query()
        Meteor.call(RVMeteorMethods.domainFindOne.rawValue, params: [filters as AnyObject, projection as AnyObject]) { (result: Any?, error : DDPError?) in
            if let error = error {
                let rvError = RVError(message: "In RVDomain.findOne, got error", sourceError: error, lineNumber: #line, fileName: "")
                callback(nil, rvError)
                return
            } else if let fields = result as? [String: AnyObject] {
                callback(RVDomain(fields: fields), nil)
                return 
            } else {
                print("In RVDomain.findOne, no error but no result")
                callback(nil, nil)
            }
        }
    }
 */
    override func additionalToString() -> String {
        return "DomainName = \(self.domainName.rawValue)"
    }

    /*
    class func baseQuery() -> RVQuery{
        let query = RVQuery()
        query.addAnd(term: .modelType, value: RVModelType.domain.rawValue as AnyObject , comparison: .eq)
        return query
    }
 */
}
