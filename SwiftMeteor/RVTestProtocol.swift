//
//  RVTestProtocol.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/30/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
protocol RVTestProtocol: class {
    associatedtype SomeType: NSObject
    var someVariable: String { get}
    func someFunction() -> SomeType
}

class RVElmoNSObject: RVTestProtocol {
    typealias SomeType = SomeClass

    var someVariable = "Elmo"
    func someFunction() -> SomeType {
        return SomeClass()
    }
}
class RVElmoBase: RVElmoNSObject {
    typealias SomeType = RVBaseModel
    func someFunction() -> RVBaseModel {
        return RVBaseModel()
    }
}
class SomeClass: NSObject {
    
}
