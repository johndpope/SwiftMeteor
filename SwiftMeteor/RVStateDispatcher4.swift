//
//  RVStateDispatcher4.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/19/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
class RVStateDispatcher4 {
    var instanceType: String { get { return String(describing: type(of: self)) } }
    fileprivate let queue = RVOperationQueue(title: "RVStateDispatcher4")
    static var shared: RVStateDispatcher4 = {
        return RVStateDispatcher4()
    }()
    func changeState(newState: RVBaseAppState4) {
        queue.addOperation(RVChangeStateOperation<RVBaseModel>(newState: newState))
    }
    func changeIntraState(currentState: RVBaseAppState4, newIntraState: RVAppState4) {
        queue.addOperation(RVIntraStateChangeOperation<RVBaseModel>(currentState: currentState, newIntraState: newIntraState))
    }
}

class RVChangeStateOperation<T: NSObject>: RVAsyncOperation<T> {
    private var newState: RVBaseAppState4
    private var deck: RVViewDeck4 { get { return RVViewDeck4.shared }}
    
    init(newState: RVBaseAppState4) {
        self.newState = newState
        super.init(title: "Change State to \(newState.appState.rawValue)", callback: {(models: [T], error: RVError?) in })
    }
    override func asyncMain() {
        DispatchQueue.main.async {
             self.deck.changeState(newState: self.newState) {  self.completeOperation() }
        }
    }
}
class RVIntraStateChangeOperation<T: NSObject>: RVAsyncOperation<T> {
    private var currentState: RVBaseAppState4
    private var newIntraState: RVAppState4
    private var deck: RVViewDeck4 { get { return RVViewDeck4.shared }}
    
    init(currentState: RVBaseAppState4, newIntraState: RVAppState4 ) {
        self.currentState = currentState
        self.newIntraState = newIntraState
        super.init(title: "Intrastate Change from \(currentState.appState.rawValue) to \(newIntraState.rawValue)", callback: {(models: [T], error: RVError?) in })
    }
    override func main() {
        DispatchQueue.main.async {
            self.deck.changeIntraState(currentState: self.currentState, newIntraState: self.newIntraState, callback: {
                self.completeOperation()
            })
        }
    }
}
