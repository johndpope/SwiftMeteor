//
//  RVAsyncOperation8.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/22/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
import Foundation
class RVAsyncOperation8<T:NSObject>: RVAsyncOperation<T> {
  //  var instanceType: String = { return String(describing: type(of: self)) }()
 //   private(set) var error: Error? = nil
 //   var title: String = "No Title"
    private var _executing: Bool = false
    private var _finished:  Bool = false
 //   var parent: NSObject? = nil
 //   var callback: RVCallback<T>
 //   let itemsPlug = [T]()
 //   let invoked = Date()
    var emptyCallback: RVEmptyCallback? = nil
    var errorCallback: RVErrorCallback? = nil
    var modelCallback: RVModelCallback? = nil
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
    override func start() {
        isExecuting = true
        DispatchQueue.main.async { self.asyncMain() }
    }
    override func asyncMain() {
        print("In \(self.classForCoder).asyncMain \(title) \(Date()).")
        completeOperation()
    }
    override func main() {
        print("In \(self.classForCoder).main \(title) \(Date()). Show Not Be Here")
        completeOperation()
    }
    override func completeOperation() {
        DispatchQueue.main.async {
            self.isFinished = true
            self.isExecuting = false
        }
    }
}
