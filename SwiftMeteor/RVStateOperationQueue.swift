//
//  RVStateOperationQueue.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/13/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
enum RVStateOperation: String {
    case install = "install"
    case uninstall = "uninstall"
}
protocol RVStateOperationQueueDelegate {
    func innerInstall() -> Void
    func innerUninstall() -> Void
}
class RVStateOperationQueue: NSObject {
    var operations = [RVStateOperation]()
    var delegate: RVStateOperationQueueDelegate? = nil
    var operationActive: Bool = false
    
    func addOperation(operation: RVStateOperation) {
        var clone = [RVStateOperation]()
        for operation in operations { clone.append(operation) }
        clone.append(operation)
        if operationActive {
            operations = clone
            return
        } else {
            runNextOperation(operations: clone)
        }
    }
    func runNextOperation(operations: [RVStateOperation]) {
        if operations.isEmpty { return }
        operationActive = true
        var clone = [RVStateOperation]()
        for operation in operations { clone.append(operation) }
        let newOperation = clone.remove(at: 0)
        self.operations = clone
        if let delegate = delegate {
            switch newOperation {
            case .install:
                delegate.innerInstall()
            case .uninstall:
                delegate.innerUninstall()
            }
        } else {
            print("In \(self.classForCoder).addOperation, no delegate. Erroneous setup")
            operationActive = false
        }
    }
    func operationEnded() {
        operationActive = false
        self.runNextOperation(operations: self.operations)
    }
}
