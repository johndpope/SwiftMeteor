//
//  RVGroup.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/8/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
import SwiftDDP
class RVGroup: RVBaseModel {
    override class func collectionType() -> RVModelType { return RVModelType.Group }
    override class var insertMethod: RVMeteorMethods { get { return RVMeteorMethods.GroupCreate } }
    override class var updateMethod: RVMeteorMethods { get { return RVMeteorMethods.GroupUpdate } }
    override class var deleteMethod: RVMeteorMethods { get { return RVMeteorMethods.GroupDelete } }
    override class var findMethod: RVMeteorMethods { get { return RVMeteorMethods.GroupRead}}
    override class var deleteAllMethod: RVMeteorMethods { get { return RVMeteorMethods.GroupDeleteAll}}
    override class var bulkQueryMethod: RVMeteorMethods { get { return RVMeteorMethods.GroupList } }
    override class func createInstance(fields: [String : AnyObject])-> RVBaseModel { return RVGroup(fields: fields) }
    override class func modelFromFields(fields: [String: AnyObject]) -> RVBaseModel { return RVGroup(fields: fields) }
    fileprivate var allSubgroup: RVBaseModel? = nil
    var allSubgroupId: String? {
        get { return getString(key: .allSubgroupId) }
        set { updateString(key: .allSubgroupId, value: newValue, setDirties: true) }
    }
    var allSubgroupModelType: RVModelType {
        get {
            if let rawValue = getString(key: .allSubgroupModelType) {
                if let type = RVModelType(rawValue: rawValue) { return type }
            }
            return RVModelType.unknown
        }
        set { updateString(key: .allSubgroupModelType, value: newValue.rawValue, setDirties: true) }
    }
    func setAllSubgroup(allSubgroup: RVBaseModel) {
        self.allSubgroupId = allSubgroup.localId
        self.allSubgroupModelType = allSubgroup.modelType
        self.allSubgroup = allSubgroup
    }

}
extension RVGroup {
    func createRootGroup(callback: @escaping(_ root: RVGroup?, _ error: RVError?) -> Void) {
        var dirties = [String: AnyObject]()
        var unsets = [String: AnyObject]()
        getDirtiesAndUnsets(topField: "", dirties: &dirties , unsets: &unsets)
        //let (tdirties, _) = createTransaction(title: "").returnDirtiesAndUnsets()
        if dirties.count <= 0 {print("In \(self.classForCoder).create, dirtiess count is erroneously zero")}
        //print("DIrties = \(dirties)")
        Meteor.call(RVMeteorMethods.GroupRoot.rawValue, params: [dirties]) { (result, error) in
            DispatchQueue.main.async {
                if let error = error {
                    let rvError = RVError(message: "In \(self.classForCoder).createRootGroup ", sourceError: error, lineNumber: #line, fileName: "")
                    callback(nil, rvError)
                    return
                } else if let fields = result as? [String: AnyObject]  {
                    callback(RVGroup(fields: fields), nil)
                } else {
                    callback(nil, nil)
                }
            }
        }
    }
    class func getRootGroup(callback: @escaping(_ root: RVGroup?, _ error: RVError?)-> Void) {
        let group = RVGroup()
        group.special = .root
        group.title = "Root Group"
        group.regularDescription = "Root Group"
        group.setLoggedInUserAsOwner()
        if let domain = RVCoreInfo.sharedInstance.domain { group.domainId = domain.localId }
        group.createRootGroup(callback: callback)
    }
    func retrieveAllSubgroup(callback: @escaping(_ allSubgroup: RVBaseModel?, _ error: RVError?)-> Void) {
        if let allSubgroup = self.allSubgroup {
            callback(allSubgroup, nil)
            return
        } else {
            if let id = self.allSubgroupId {
                let query = RVQuery()
                query.addAnd(term: ._id, value: id as AnyObject, comparison: .eq)
                RVGroup.findOne(query: query, callback: { (allSubgroup, error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            error.append(message: "In \(self.classForCoder).retrieveAllSubgroup, got Meteor error")
                            callback(nil, error)
                            return
                        } else if let allSubgroup = allSubgroup {
                            self.allSubgroup = allSubgroup
                            callback(allSubgroup, nil)
                            return
                        } else {
                            callback(nil, nil)
                            return
                        }
                    }
                    return
                })
                return
            } else {
                callback(nil, nil)
                return
            }
        }
    }
override func create(callback: @escaping (RVBaseModel?, RVError?) -> Void) {
        let allSubgroup = RVGroup()
        allSubgroup.setParent(parent: self)
        allSubgroup.title = self.title
        if let owner = loggedInUser {
            self.setOwner(owner: owner)
            allSubgroup.setOwner(owner: owner)
        }
        else {
            let error = RVError(message: "In \(self.classForCoder).create, no loggedInUser")
            callback(nil, error)
            return
        }
        if let domainId = RVCoreInfo2.shared.domainId {
            self.domainId = domainId
            allSubgroup.domainId = domainId
        } else {
            let error = RVError(message: "In \(self.classForCoder).create, no domainId")
            callback(nil, error)
            return
        }
        self.setAllSubgroup(allSubgroup: allSubgroup)
        super.create { (topGroup, error) in
            if let error = error {
                DispatchQueue.main.async {
                    error.append(message: "In \(self.classForCoder).create, got error from super.create ")
                    callback(nil, error)
                }
                return
            } else if let topGroup = topGroup {
                allSubgroup.innerCreate(callback: { (allSubgroup, error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            error.append(message: "In \(self.classForCoder).create, successfully created topGroup, but error creating allSubgroup")
                            callback(nil, error)
                            return
                        } else if let allSubgroup = allSubgroup {
                            allSubgroup.printAllSubgroup()
                            callback(topGroup, nil)
                            return
                        } else {
                            let error = RVError(message: "In \(self.classForCoder).create, successfully created topGroup, but no error or result creating allSubgroup")
                            callback(topGroup, error)
                        }
                        return
                    }
                })
                return
            } else {
                DispatchQueue.main.async {
                    let error = RVError(message: "In \(self.classForCoder).create no error but no result creating topGroup")
                    callback(nil, error)
                }
                return
            }
        }
    }
    private func innerCreate(callback: @escaping (RVBaseModel?, RVError?) -> Void) {
        super.create(callback: callback)
    }
}
