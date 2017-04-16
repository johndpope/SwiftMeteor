//
//  RVStateDispatcher8.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/16/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
import Foundation
class RVStateDispatcher8 {
    var instanceType: String { get { return String(describing: type(of: self)) } }
    var currentState:   RVBaseAppState8 = RVLoggedOutState8()
    var previousState:  RVBaseAppState8 = RVLoggedOutState8()

    fileprivate let queue = RVOperationQueue()
    static var shared: RVStateDispatcher8 = { return RVStateDispatcher8() }()
    func changeState(newState: RVBaseAppState8) {
        queue.addOperation(RVChangeStateOperation8<RVBaseModel>(newState: newState))
    }
}

class RVChangeStateOperation8<T: NSObject>: RVAsyncOperation<T> {
    private var newState: RVBaseAppState8
    private var deck: RVViewDeck8 { get { return RVViewDeck8.shared }}
    
    init(newState: RVBaseAppState8) {
        self.newState = newState
        super.init(title: "Change State to \(newState)", callback: {(models: [T], error: RVError?) in })
    }
    override func asyncMain() {
        DispatchQueue.main.async {
            if self.isCancelled {
                self.completeOperation()
                return
            } else {
                DispatchQueue.main.async {
                    let previousState = RVStateDispatcher8.shared.previousState
                    RVStateDispatcher8.shared.previousState = RVStateDispatcher8.shared.currentState
                    RVStateDispatcher8.shared.currentState = self.newState
                    self.deck.changeState(newState: self.newState, previousState: previousState) {  self.completeOperation() }
                }
            }
        }
    }
}
