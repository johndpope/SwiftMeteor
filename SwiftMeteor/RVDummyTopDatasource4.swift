//
//  RVDummyTopDatasource4.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/7/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
class RVDummyTopDatasource4: RVBaseDatasource4 {
    override func retrieve(query: RVQuery, callback: @escaping RVCallback) {
        var models = [RVBaseModel]()
        if items.count < 2 {
            let model = RVInterest()
            model.title = "Dummy Top Datasource4"
            models.append(model)
        }
        callback(models, nil)
    }
}
