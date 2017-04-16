//
//  RVStatePath.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/15/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
enum RVTop: String {
    case main = "main"
}
class RVStatePath8 {
    var instanceType: String { get { return String(describing: type(of: self)) } }
    let separator: String = "/"
    var top:        RVTop       = .main
    var modelType:  RVModelType = .transaction
    var crud:       RVCrud      = .list
    var parameters: [RVKeys: AnyObject] = [RVKeys: AnyObject]()
    var model:      RVBaseModel? = nil
    var path: String {
        return "\(top.rawValue)\(self.separator)\(modelType.rawValue)\(self.separator)\(crud.rawValue)"
    }
    init(top: RVTop = .main, modelType: RVModelType, crud: RVCrud, parameters: [RVKeys: AnyObject] = [RVKeys: AnyObject](), model: RVBaseModel? = nil) {
        self.top = top
        self.modelType = modelType
        self.crud = crud
        self.parameters = parameters
        self.model = model
    }
    var state: RVBaseAppState8 {
        var instanceType: String { get { return String(describing: type(of: self)) } }
        let defaultState = RVBaseAppState8(appState: RVAppState4.defaultState)
        var state = RVBaseAppState8(appState: RVAppState4.defaultState)
        switch(top) {
        case .main:
            switch (modelType) {
            case .transaction:
                switch(crud) {
                case .create:
                    state = defaultState // PLUG
                case .read:
                    state = defaultState // PLUG
                case .update:
                    state = defaultState // PLUG
                case .delete:
                    state = defaultState // PLUG
                case .deleteAll:
                    state = defaultState // PLUG
                case .list:
                    state = defaultState // PLUG
                case .unknown:
                    print("In \(self.instanceType).state, crud = unknown")
                    state = defaultState // PLUG
                }
            default:
                state = defaultState
            }
        }
        return state
    }
}
