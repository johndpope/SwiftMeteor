//
//  RVPayload.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/2/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
enum RVEventType {
    case added
    case changed
    case removed
}
class RVPayload {
    class var payloadInfoKey: String { return  "PayloadInfoKey" }
    var subscription: RVSubscription
    var eventType: RVEventType
    var models: [RVBaseModel]
    var operation: RVAsyncOperation
    init(subscription: RVSubscription, eventType: RVEventType, models: [RVBaseModel], operation: RVAsyncOperation) {
        self.subscription = subscription
        self.eventType = eventType
        self.models = models
        self.operation = operation
    }
    func toString() -> String {
        var modelTitle = "None"
        var localId = "None"
        var created = "None"
        var country = "None"
        var everywhere = false
        if let model = models.first {
            if let title = model.title { modelTitle = title}
            if let id = model.localId { localId = id }
            if let createdAt = model.createdAt { created = createdAt.description }
            country = model.searchCountry.rawValue
            everywhere = model.everywhere
        }
        return "Payload: \(self.eventType) modelCount: \(models.count), title: \(modelTitle) \(localId) \(created) \(country) \(everywhere)"
    }
}
