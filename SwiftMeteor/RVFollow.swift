//
//  RVFollowed.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/20/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation

class RVFollow: RVBaseModel {
    override class func collectionType() -> RVModelType { return RVModelType.follow }
    override class var insertMethod: RVMeteorMethods { get { return RVMeteorMethods.followCreate } }
    override class var updateMethod: RVMeteorMethods { get { return RVMeteorMethods.followUpdate } }
    override class var deleteMethod: RVMeteorMethods { get { return RVMeteorMethods.followDelete } }
    override class var findMethod: RVMeteorMethods { get { return RVMeteorMethods.followFindById}}
    override class var bulkQueryMethod: RVMeteorMethods { get { return RVMeteorMethods.followBulkQuery } }
    override class func createInstance(fields: [String : AnyObject])-> RVBaseModel { return RVFollow(fields: fields) }
    override class func modelFromFields(fields: [String: AnyObject]) -> RVBaseModel { return RVFollow(fields: fields) }
    
    var followedId: String? {
        get { return getString(key: .followedId) }
        set { updateString(key: .followedId, value: newValue, setDirties: true) }
    }
    var followedModelType: RVModelType {
        get {
            if let rawValue = getString(key: .followedModelType) {
                if let type = RVModelType(rawValue: rawValue) { return type }
            }
            return RVModelType.unknown
        }
        set { updateString(key: .followedModelType, value: newValue.rawValue, setDirties: true)}
    }
    class func createWithComponents(following: RVBaseModel, callback: @escaping(_ follow: RVFollow?, _ error: RVError?) -> Void ) {
        let follow = RVFollow()
        if let user = follow.loggedInUser {
            if let domain = follow.appDomain {
                follow.setOwner(owner: user)
                follow.fullName = user.fullName
                follow.domainId = domain.localId
                follow.followedId = following.localId
                follow.followedModelType = following.modelType
                follow.title = following.title
                follow.create(callback: { (model, error) in
                    if let error = error {
                        error.append(message: "In \(self.classForCoder()).createdWithComponents, error creating follow")
                        callback(nil, error)
                        return
                    } else if let updatedFollow = model as? RVFollow {
                        callback(updatedFollow, nil)
                        return
                    } else {
                        print("In \(self.classForCoder()).createWithComponents, no error but no result");
                        callback(nil, nil)
                    }
                })
                return
            }
        }
        let error = RVError(message: "In \(self.classForCoder()), a required object was null")
        callback(nil, error)
    }
}
