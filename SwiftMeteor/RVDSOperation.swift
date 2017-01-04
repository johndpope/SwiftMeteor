//
//  RVDSOperation.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 12/31/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import Foundation
enum OperationName: String {
    case backOperation = "BackOperation"
    case frontOperation = "FrontOperation"
    case expandOperation = "ExpandOperation"
    case collapseOperation = "CollapseOperation"
}
class RVDSOperation {
    var name: OperationName
    var active: Bool = false {
        didSet {
           //print("RVDSOperation \(name), \(identifier) with id: \(identifier), active set to \(active)")
        }
    }
    init(name: OperationName) {
        self.name = name
    }
    var cancelled: Bool = false
    let identifier = NSDate().timeIntervalSince1970
}
class RVDSOperations {
    var backOperation = RVDSOperation(name: .backOperation)
    var frontOperation = RVDSOperation(name: .frontOperation)
    var collapseOperation = RVDSOperation(name: .collapseOperation)
    var expandOperation = RVDSOperation(name: .expandOperation)
    func addOperation(operation: RVDSOperation) {
        switch(operation.name) {
        case .backOperation:
            self.backOperation = operation
        case .frontOperation:
            self.frontOperation = operation
        case .expandOperation:
            self.expandOperation = operation
        case .collapseOperation:
            self.collapseOperation = operation
        }

    }
    func findOperation(operationName: OperationName) -> RVDSOperation {
        switch(operationName) {
        case .backOperation:
            return self.backOperation
        case .frontOperation:
            return self.frontOperation
        case .expandOperation:
            return self.expandOperation
        case .collapseOperation:
            return self.collapseOperation
        }
    }
    func flushOperations() {
        backOperation.cancelled = true
        frontOperation.cancelled = true
        collapseOperation.cancelled = true
        expandOperation.cancelled = true
        backOperation = RVDSOperation(name: .backOperation)
        frontOperation = RVDSOperation(name: .frontOperation)
        collapseOperation = RVDSOperation(name: .collapseOperation)
        expandOperation = RVDSOperation(name: .expandOperation)
    }
    
}
