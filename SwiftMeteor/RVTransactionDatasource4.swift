//
//  RVTransactionDatasource4.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/26/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
class RVTransactionDatasource4<T: RVSubbaseModel>: RVBaseDatasource4<T> {
    
    
    var basicQuery: (RVQuery, RVError?) {
        let query = RVQuery()
        let error: RVError? = nil
        return (query, error)
    }
}
