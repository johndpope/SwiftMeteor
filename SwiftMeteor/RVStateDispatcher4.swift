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
    fileprivate let queue = RVOperationQueue()
    static var shared: RVStateDispatcher4 = {
        return RVStateDispatcher4()
    }()
    func changeState(newState: RVBaseAppState4) {
        queue.addOperation(RVChangeStateOperation(newState: newState))
    }
}

class RVChangeStateOperation: RVAsyncOperation {
    private var newState: RVBaseAppState4
    private var deck: RVViewDeck4 { get { return RVViewDeck4.shared }}
    
    init(newState: RVBaseAppState4) {
        self.newState = newState
        super.init(title: "Change State to \(newState.appState.rawValue)")
    }
    override func main() {
        DispatchQueue.main.async {
             self.deck.changeState(newState: self.newState) {  self.completeOperation() }
        }
    }
}
