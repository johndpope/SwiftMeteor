//
//  RVGroupListSubscription8.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/17/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
class RVGroupListSubscription8: RVBaseCollectionSubscription8 {
    override var notificationName: Notification.Name { return Notification.Name("GroupSubscription") }
    init(front: Bool = true, showResponse: Bool = false) {
        super.init(modelType: .Group, isFront: front, showResponse: showResponse)
     //   super.init(collection: .Group)
    }
    override func populate(id: String, fields: NSDictionary) -> RVBaseModel {
        let group = RVGroup(id: id , fields: fields)
        print("In \(self.instanceType).populate, have Group \(group.createdAt!) parentId: \(String(describing: group.parentId))")
        return group
    }
}
