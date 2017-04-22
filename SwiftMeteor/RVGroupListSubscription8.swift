//
//  RVGroupListSubscription8.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/17/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
class RVGroupListSubscription8: RVBaseCollectionSubscription8 {
    init(front: Bool = true, showResponse: Bool = false) {
        super.init(modelType: .Group, isFront: front, showResponse: showResponse) { (id, fields) -> RVBaseModel in
            return RVGroup(id: id , fields: fields)
        }
    }

}
