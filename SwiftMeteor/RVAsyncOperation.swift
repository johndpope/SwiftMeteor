//
//  RVAsyncOperation.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/14/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
class RVAsyncOperation<T:NSObject>: Operation {
    var instanceType: String = { return String(describing: type(of: self)) }()
    //var instanceType: String { get { return String(describing: type(of: self)) } }
    private(set) var error: Error? = nil
    var title: String = "No Title"
    private var _executing: Bool = false
    private var _finished:  Bool = false
    var parent: NSObject? = nil
    var callback: RVCallback<T>
    let itemsPlug = [T]()
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
    init(title: String, callback: @escaping RVCallback<T>, parent: NSObject? = nil) {
        self.title = title
        self.parent = parent
        self.callback = callback
        super.init()
    }
    override func start() {
          //print("In \(self.classForCoder).start \(title) \(Date())")
        /*
        if isCancelled {
            isFinished = true
            return
        }
 */
        isExecuting = true
        asyncMain()

       // operation(completeOperation: completeOperation)
    }
    func completeOperation(models: [T] = [T](), error: RVError? ) {
        DispatchQueue.main.async {
            self.callback(models, error)
            self.isFinished = true
            self.isExecuting = false
        }
    }
    func completeOperation() {
        DispatchQueue.main.async {
            self.isFinished = true
            self.isExecuting = false
        }
    }
    func asyncMain() {
        print("In \(self.classForCoder).asyncMain \(title) \(Date()).")
        completeOperation()
    }
    override func main() {
        print("In \(self.classForCoder).main \(title) \(Date()). Show Not Be Here")
        completeOperation()
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
        let operation1 = RVAsyncOperation<RVBaseModel>(title: "First", callback: {(models, error) in })
        operation1.completionBlock = { error = operation1.error }
        self.addOperation(operation1)
        let operation2 = RVAsyncOperation(title: "Second", callback: {(models, error) in })
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
    override func addOperation(_ op: Operation) {
        if self.operationCount < 200 {
            super.addOperation(op)
        } else {
            print("In \(self.classForCoder).addOperation. Count exceeds 20, not adding")
        }
    }
}
