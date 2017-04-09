//
//  RVDummyTopDatasource4.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/7/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
class RVDummyTopDatasource4<T:NSObject>: RVBaseDatasource4<T> {
    override func retrieve(query: RVQuery, callback: @escaping RVCallback<T>) {
        var models = [T]()
        if elements.count < 2 {
            let model = RVInterest()
            model.title = "Dummy Top Datasource4"
            if let model = model as? T {
                models.append(model)
            }
        }
        callback(models, nil)
    }
}
