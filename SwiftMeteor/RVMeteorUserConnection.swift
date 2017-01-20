//
//  RVMeteorUserConnection.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/19/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation

class RVMeteorUserConnection {
    static let sharedConnection: RVMeteorUserConnection = {
        RVMeteorUserConnection()
    }()
    let userDefaults = UserDefaults.standard
    var id: String? {
        get {
            if let id = userDefaults.object(forKey: RVSwiftDDP.DDP_Codes.DDP_ID.rawValue) as? String { return id }
            return nil
        }
    }
    var email: String? {
        get {
            if let string = userDefaults.object(forKey: RVSwiftDDP.DDP_Codes.DDP_EMAIL.rawValue) as? String { return string }
            return nil
        }
    }
    var username: String? {
        get {
            if let string = userDefaults.object(forKey: RVSwiftDDP.DDP_Codes.DDP_USERNAME.rawValue) as? String { return string }
            return nil
        }
    }
    var token: String? {
        get {
            if let string = userDefaults.object(forKey: RVSwiftDDP.DDP_Codes.DDP_TOKEN.rawValue) as? String { return string }
            return nil
        }
    }

    var tokenExpires: Date? {
        get {
            if let date = userDefaults.object(forKey: RVSwiftDDP.DDP_Codes.DDP_TOKEN_EXPIRES.rawValue) as? Date { return date}
            return nil
        }
    }
    
    
    func dateFromTimestamp(_ containedIn: NSDictionary) -> Date? {
        if let date = containedIn["$date"] as? Double {
            let timestamp = TimeInterval(date / 1000)
            return Date(timeIntervalSince1970: timestamp)
        } else {
            return nil
        }
    }
    func toString() -> String {
        var field = "id"
        var output = "RVMeteorUserConnection: {"
        if let string = self.id {
            output = "\(output) \(field)=\(string), "
        } else {
            output = "\(output) < no \(field) >, "
        }
        field = "email"
        if let string = self.email {
            output = "\(output) \(field)=\(string), "
        } else {
            output = "\(output) < no \(field) >, "
        }
        field = "token"
        if let string = self.token {
            output = "\(output) \(field)=\(string), "
        } else {
            output = "\(output) < no \(field) >, "
        }
        field = "tokenExpires"
        if let date = self.tokenExpires {
            output = "\(output) \(field)=\(date), "
        } else {
            output = "\(output) < no \(field) >, "
        }
        output = "\(output) }"
        return output
    }
}
