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
    override class var insertMethod: RVMeteorMethods { get { return RVMeteorMethods.transactionCreate } }
    override class var updateMethod: RVMeteorMethods { get { return RVMeteorMethods.transactionUpdate } }
    override class var deleteMethod: RVMeteorMethods { get { return RVMeteorMethods.transactionDelete } }
    override class var findMethod: RVMeteorMethods { get { return RVMeteorMethods.transactionFindById}}
    override class var deleteAllMethod: RVMeteorMethods { get { return RVMeteorMethods.transactionDeleteAll}}
    override class var bulkQueryMethod: RVMeteorMethods { get { return RVMeteorMethods.transactionBulkQuery } }
    override class func createInstance(fields: [String : AnyObject])-> RVBaseModel { return RVTransaction(fields: fields) }
    override class func modelFromFields(fields: [String: AnyObject]) -> RVBaseModel { return RVTransaction(fields: fields) }
    override func initializeProperties() {
        super.initializeProperties()
        self.readState = .unread
        self.archived = false
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
