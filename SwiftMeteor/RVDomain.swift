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
    case PortolaValley = "PortolaValley"
    case unknown = "unknown"
}
class RVDomain: RVBaseModel {
    override class func collectionType() -> RVModelType { return RVModelType.domain }
    override class var insertMethod: RVMeteorMethods { get { return RVMeteorMethods.domainCreate} }
    override class var updateMethod: RVMeteorMethods { get { return RVMeteorMethods.UpdateTask } }
    override class var deleteMethod: RVMeteorMethods { get { return RVMeteorMethods.DeleteTask } }
    override class var findMethod: RVMeteorMethods { get { return RVMeteorMethods.FindTask}}
    override class var bulkQueryMethod: RVMeteorMethods { get { return RVMeteorMethods.BulkTask } }
    override class func createInstance(fields: [String : AnyObject])-> RVBaseModel { return RVDomain(fields: fields) }
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
    override func additionalToString() -> String {
        return "DomainName = \(self.domainName.rawValue)"
    }
    static let baseQuery: RVQuery = {
        let query = RVQuery()
        query.addAnd(term: .modelType, value: RVModelType.domain.rawValue as AnyObject , comparison: .eq)
        return query
    }()
}
