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
}
