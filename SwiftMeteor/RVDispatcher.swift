//
//  RVDispatcher.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/19/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
class RVDispatcher {
    var instanceType: String { get { return String(describing: type(of: self)) } }
    fileprivate let queue = RVOperationQueue()
    static var shared: RVDispatcher = {
        return RVDispatcher()
    }()
    func changeState(newState: RVNewBaseState) {
        
    }
}

class RVChangeStateOperation: RVAsyncOperation {
    private var newState: RVNewBaseState
    private var deck: RVViewDeck { get { return RVViewDeck.sharedInstance }}
    
    init(newState: RVNewBaseState) {
        self.newState = newState
        super.init(title: "Change State to \(newState.appState.rawValue)")
    }
    override func main() {
        deck.changeState(newState: self.newState) {  self.completeOperation() }
    }
}
