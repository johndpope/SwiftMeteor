//
//  RVPrivateChat.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 2/18/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation


class RVPrivateChat: RVInterest {
    override class func collectionType() -> RVModelType { return RVModelType.privateChat }
    override class var insertMethod: RVMeteorMethods { get { return RVMeteorMethods.privateChatCreate } }
    override class var updateMethod: RVMeteorMethods { get { return RVMeteorMethods.privateChatUpdate } }
    override class var deleteMethod: RVMeteorMethods { get { return RVMeteorMethods.privateChatDelete } }
    override class var findMethod: RVMeteorMethods { get { return RVMeteorMethods.privateChatFindById}}
    override class var deleteAllMethod: RVMeteorMethods { get { return RVMeteorMethods.privateChatDeleteAll}}
    override class var bulkQueryMethod: RVMeteorMethods { get { return RVMeteorMethods.privateChatBulkQuery } }

    override class func modelFromFields(fields: [String: AnyObject]) -> RVBaseModel { return RVPrivateChat(fields: fields) }
    var userProfileID0: String? {
        get { return getString(key: RVKeys.userProfileID0) }
        set { updateString(key: RVKeys.userProfileID0, value: newValue, setDirties: true)}
    }
    var userProfileID1: String? {
        get { return getString(key: RVKeys.userProfileID1) }
        set { updateString(key: RVKeys.userProfileID1, value: newValue, setDirties: true)}
    }
    class func specialPrivateChatLookup(otherUser: RVUserProfile, callback: @escaping(_ chat: RVPrivateChat?, _ error: RVError?) -> Void ) {
        if let domain = RVCoreInfo.sharedInstance.domain {
            if let domainId = domain.localId {
                if let otherId = otherUser.localId {
                    if let me = RVCoreInfo.sharedInstance.userProfile {
                        if let myID = me.localId {
                            let query = RVQuery()
                            var ID0 = myID
                            var ID1 = otherId
                            if myID < otherId {
                                ID0 = otherId
                                ID1 = myID
                            }
                            query.addAnd(term: .modelType, value: RVModelType.privateChat.rawValue as AnyObject, comparison: .eq)
                            query.addAnd(term: .collection, value: RVModelType.privateChat.rawValue as AnyObject, comparison: .eq)
                            query.addAnd(term: .userProfileID0, value: ID0 as AnyObject, comparison: .eq)
                            query.addAnd(term: .userProfileID1, value: ID1 as AnyObject, comparison: .eq)
                            query.addAnd(term: .domainId, value: domainId as AnyObject, comparison: .eq)
                            let (filters, projection) = query.query()
                            RVSwiftDDP.sharedInstance.MeteorCall(method: .privateChatSpecialLookup, params: [filters as AnyObject, projection as AnyObject], callback: { (any: Any? , error: RVError?) in
                                DispatchQueue.main.async {
                                    if let error = error {
                                        error.append(message: "In \(self.classForCoder())..specialPrivateChatLookup got error")
                                        callback(nil, error)
                                        return
                                    } else if let fields = any as? [String: AnyObject] {
                                        if let chat = modelFromFields(fields: fields) as? RVPrivateChat {
                                            callback(chat, nil)
                                            return
                                        }
                                    }
                                    let error = RVError(message: "In \(self.classForCoder()).specialPrivateChatLookup, no error but no result")
                                    callback(nil, error)
                                    return
                                }
                            })
                            return
                        }
                    }
                    let error = RVError(message: "In \(self.classForCoder()).specialPrivateChatLookup, no loggedInUser")
                    callback(nil, error)
                    return
                } else {
                    let error = RVError(message: "In \(self.classForCoder()).specialPrivateChatLookup no id for other user \(otherUser.toString())")
                    callback(nil, error)
                    return
                }
            }
        }
        let error = RVError(message: "In \(self.classForCoder()).specialPrivateChatLookup, no domain")
        callback(nil, error)

    }
    override func toString() -> String {
        var output = "-------------------------------RVPrivateChat instance Unique Fields: --------------------------------\n"
        output = addTerm(term: RVKeys.userProfileID0.rawValue , input: output, value: self.userProfileID0)
        output = addTerm(term: RVKeys.userProfileID1.rawValue , input: output, value: self.userProfileID1)
        output = "\(output)\n\(super.toString())"
        return output
    }
}
