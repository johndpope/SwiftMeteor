
//
//  RVMessage.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/20/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
class RVMessage: RVBaseModel {
    enum Priority: Int {
        case regular = 0
        case urgent = 5
        case importantButNotUrgent = 3
        
        var description: String  {
            switch(self) {
            case .regular:
                return "Regular"
            case .importantButNotUrgent:
                return "Important"
            case .urgent:
                return "Urgent"
            }
        }
    }
    enum MessageReport: String {
        case routine = "Routine"
        case SuspiciousPerson = "Suspicious Person"
        case SuspiciousVehicle = "Supspicious Vehicle"
        case unknown = "Unknown"
    }
    override class func collectionType() -> RVModelType { return RVModelType.message }
    override class var insertMethod: RVMeteorMethods { get { return RVMeteorMethods.messageCreate } }
    override class var updateMethod: RVMeteorMethods { get { return RVMeteorMethods.messageUpdate } }
    override class var deleteMethod: RVMeteorMethods { get { return RVMeteorMethods.messageDelete } }
    override class var findMethod: RVMeteorMethods { get { return RVMeteorMethods.messageFindById}}
    override class var bulkQueryMethod: RVMeteorMethods { get { return RVMeteorMethods.messageBulkQuery } }
    override class func createInstance(fields: [String : AnyObject])-> RVBaseModel { return RVMessage(fields: fields) }
    override class func modelFromFields(fields: [String: AnyObject]) -> RVBaseModel { return RVMessage(fields: fields) }

    override func initializeProperties() {
        super.initializeProperties()
        self.topic = false
        self.priority = .regular
        self.messageReport = .routine
    }
    var followedId: String? {
        get { return getString(key: RVKeys.followedId) }
        set { updateString(key: RVKeys.followedId, value: newValue, setDirties: true)}
    }
    var followedModelType: RVModelType {
        get {
            if let rawValue = getString(key: .followedModelType) {
                if let type = RVModelType(rawValue: rawValue) { return type}
            }
            return RVModelType.unknown
        }
        set {
            updateString(key: .followedModelType, value: newValue.rawValue, setDirties: true)
            self.collection = newValue
        }
    }
    var priority: RVMessage.Priority {
        get {
            if let rawValue = getNSNumber(key: .priority) {
                if let priority = Priority(rawValue: rawValue.intValue) { return priority}
            }
            return .regular
        }
        set { updateNumber(key: .priority, value: NSNumber(value: newValue.rawValue), setDirties: true) }
    }
    var topic: Bool {
        get {
            if let topic = getBool(key: .topic) { return topic }
            return false
        }
        set { updateBool(key: .topic, value: newValue, setDirties: true) }
    }
    var messageReport: RVMessage.MessageReport {
        get {
            if let rawValue = getString(key: .messageReport) {
                if let report = MessageReport(rawValue: rawValue) { return report }
            }
            return .unknown
        }
        set { updateString(key: .messageReport, value: newValue.rawValue, setDirties: true) }
    }
}
