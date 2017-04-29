//
//  RVModelProtocol.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/28/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
protocol RVModelProtocol: class {
    associatedtype T: NSObject
    func retrieve(query: RVQuery, callback: @escaping RVCallback<T>) -> Void
}
