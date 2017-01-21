//
//  RVDomain.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/20/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
enum RVDomainName: String {
    case PortolaValley = "PortolaValley"
    case unknown = "unknown"
}
class RVDomain: RVBaseModel {
    
    var domainName: RVDomainName {
        get {
            if let rawValue = getString(key: .domainName) {
                if let domainName = RVDomainName(rawValue: rawValue) { return domainName }
            }
            return .unknown
        }
        set { updateString(key: .domainName, value: newValue.rawValue, setDirties: true) }
    }
}
