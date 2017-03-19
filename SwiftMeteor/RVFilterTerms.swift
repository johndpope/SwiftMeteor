//
//  RVFilterTerms.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/18/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
class RVFilterTerms {
    enum Keys: String {
        case value = "value"
        case order = "order"
        case sortField = "sortField"
    }
    private var sortField: RVKeys
    private var value: AnyObject
    private var order: RVSortOrder
    init(sortField: RVKeys, value: AnyObject, order: RVSortOrder = .ascending) {
        self.sortField = sortField
        self.value = value
        self.order = order
    }
    var params: [String: AnyObject] {
        get {
            var params = [String: AnyObject]()
            params[Keys.value.rawValue] = self.value as AnyObject
            params[Keys.sortField.rawValue] = self.sortField as AnyObject
            params[Keys.order.rawValue] = self.order as AnyObject
            return params
        }
    }
}
