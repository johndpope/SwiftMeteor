//
//  RVTransaction.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 2/21/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//


// DomainID
// ParentID
// OwnerID
// Text
// TransactionType
// Payload
// targetUserId
import Foundation
class RVTransaction: RVBaseModel {
    override class func collectionType() -> RVModelType { return RVModelType.transaction }
    override class var insertMethod: RVMeteorMethods { get { return RVMeteorMethods.TransactionCreate } }
    override class var updateMethod: RVMeteorMethods { get { return RVMeteorMethods.TransactionUpdate } }
    override class var deleteMethod: RVMeteorMethods { get { return RVMeteorMethods.TransactionDelete } }
    override class var findMethod: RVMeteorMethods { get { return RVMeteorMethods.TransactionRead}}
    override class var deleteAllMethod: RVMeteorMethods { get { return RVMeteorMethods.TransactionDeleteAll}}
    override class var bulkQueryMethod: RVMeteorMethods { get { return RVMeteorMethods.TransactionList } }
    override class func createInstance(fields: [String : AnyObject])-> RVBaseModel { return RVTransaction(fields: fields) }
    override class func modelFromFields(fields: [String: AnyObject]) -> RVBaseModel { return RVTransaction(fields: fields) }
    override func initializeProperties() {
        super.initializeProperties()
        self.readState = .unread
        self.archived = false
    }
    class var basicQuery: (RVQuery, RVError?) {
        get {
            let query = RVQuery()
            var error: RVError? = nil
            query.addAnd(term: .modelType, value: RVModelType.transaction.rawValue as AnyObject, comparison: .eq)
            query.addAnd(term: .deleted, value: false as AnyObject, comparison: .eq)
            query.limit = 10
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
    var payload: [String: AnyObject] {
        get {
            if let payload = getDictionary(key: .payload) { return payload }
            return [String: AnyObject]()
        }
        set { updateDictionary(key: .payload, dictionary: newValue) }
    }
    var transactionType: RVTransactionType {
        get {
            if let rawValue = getString(key: .transactionType) {
                if let type = RVTransactionType(rawValue: rawValue) { return type }
            }
            return .unknown
        }
        set { updateString(key: .transactionType, value: newValue.rawValue, setDirties: true) }
    }
    var targetUserProfileId: String? {
        get { return getString(key: .targetUserProfileId) }
        set { updateString(key: .targetUserProfileId, value: newValue, setDirties: true) }
    }
    var entityId: String? {
        get { return getString(key: .entityId) }
        set { updateString(key: .entityId, value: newValue, setDirties: true) }
    }
    var entityModelType: RVModelType {
        get {
            if let rawValue = getString(key: .entityModelType) {
                if let type = RVModelType(rawValue: rawValue) { return type }
            }
            return .unknown
        }
        set { updateString(key: .entityModelType, value: newValue.rawValue, setDirties: true) }
    }
    var entityTitle: String? {
        get { return getString(key: .entityTitle) }
        set { updateString(key: .entityTitle, value: newValue, setDirties: true) }
    }
    var readState: RVReadState {
        get {
            if let rawValue = getString(key: .readState) {
                if let type = RVReadState(rawValue: rawValue) { return type }
            }
            return .unknown
        }
        set { updateString(key: .readState, value: newValue.rawValue, setDirties: true) }
    }

}
