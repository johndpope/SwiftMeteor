//
//  RVAsyncOperation.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/14/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
class RVAsyncOperation: Operation {
    var instanceType: String { get { return String(describing: type(of: self)) } }
    private(set) var error: Error? = nil
    var title: String = "No Title"
    private var _executing: Bool = false
    private var _finished:  Bool = false
    var parent: NSObject? = nil
    let invoked = Date()
    override var isAsynchronous: Bool { return true }
    
    override var isExecuting: Bool {
        get { return _executing }
        set {
            let key = "isExecuting"
            willChangeValue(forKey: key)
            _executing = newValue
            didChangeValue(forKey: key)
        }
    }
    override var isFinished: Bool {
        get { return _finished }
        set {
            let key = "isFinished"
            willChangeValue(forKey: key)
            _finished = newValue
            didChangeValue(forKey: key)
        }
    }
    init(title: String, parent: NSObject? = nil) {
        self.title = title
        self.parent = parent
        super.init()
    }
    override func start() {
          //print("In \(self.classForCoder).start \(title) \(Date())")
        if isCancelled {
            isFinished = true
            return
        }
        isExecuting = true
        main()

       // operation(completeOperation: completeOperation)
    }
    func completeOperation() {
        isFinished = true
        isExecuting = false
    }
    override func main() {
        print("In \(self.classForCoder).main \(title) \(Date())")
    }
    /*
    func operation(completeOperation: @escaping() -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            print("\(self.title). Invoked: \(self.invoked), Starting: \(Date())")
            completeOperation()
        }
    }
 */
}
class RVOperationQueue: OperationQueue {
    override init() {
        super.init()
        self.maxConcurrentOperationCount = 1
    }
    func test() {
        var error: Error? = nil
        let operation1 = RVAsyncOperation(title: "First")
        operation1.completionBlock = { error = operation1.error }
        self.addOperation(operation1)
        let operation2 = RVAsyncOperation(title: "Second")
        operation2.completionBlock = { error = operation2.error }
        self.addOperation(operation2)
        self.addOperation {
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("No Errors")
            }
        }
    }
}
