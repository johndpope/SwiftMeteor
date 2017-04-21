//
//  RVControllerOperation.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/21/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit 
class RVControllerOperation<T: NSObject>: RVAsyncOperation<T> {
    weak var controller: UIViewController? = nil
    var operation = {() in }
    init(viewController: UIViewController?, operation: @escaping () -> Void) {
        self.controller = viewController
        self.operation = operation
        let callback = {(result: [T], error: RVError?) in }
        super.init(title: "RVViewDidLoadOpertion", callback: callback)
    }
    override func asyncMain() {
        if !self.isCancelled {
            DispatchQueue.main.async {
                if let _ = self.controller {
                    self.operation()
                    self.completeOperation()
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
