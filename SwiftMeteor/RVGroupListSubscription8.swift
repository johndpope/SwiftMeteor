//
//  RVGroupListSubscription8.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/17/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
class RVGroupListSubscription8: RVBaseCollectionSubscription {
    override var notificationName: Notification.Name { return Notification.Name("GroupSubscription") }
    init(front: Bool = true, showResponse: Bool = false) {
     //   super.init(modelType: .Group, isFront: front, showResponse: showResponse)
        super.init(collection: .Group)
    }
    override func populate(id: String, fields: NSDictionary) -> RVBaseModel {
        let group = RVGroup(id: id , fields: fields)
        print("In \(self.instanceType).populate, have transaction \(group.createdAt!) TopParentId: \(String(describing: group.topParentId))")
        return group
    }
}
