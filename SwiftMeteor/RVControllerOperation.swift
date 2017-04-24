//
//  RVControllerOperation.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/21/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit 
class RVControllerOperation<T: NSObject>: RVAsyncOperation8<T> {
    weak var controller: UIViewController? = nil
    var closure = {(asynOp: RVControllerOperation<T>, error: RVError?) in }
    init(title: String = "RVControllerOperation", viewController: UIViewController?, closure: @escaping (RVControllerOperation<T>, RVError?) -> Void) {
        self.controller = viewController
        self.closure = closure
        super.init(title: "RVViewDidLoadOpertion")
    }
    override func asyncMain() {
        if !self.isCancelled {
            DispatchQueue.main.async {
                let error: RVError? = self.timeout ? RVError(message: "In \(self.classForCoder).asyncMain, timed out") : nil
                if let _ = self.controller {
                    self.closure(self, error )
                } else {
                    self.completeOperation()
                }
            }
            return
        } else {
            self.completeOperation()
        }
    }
}
