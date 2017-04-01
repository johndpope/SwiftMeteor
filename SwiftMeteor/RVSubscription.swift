//
//  RVSubscription.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/31/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
protocol RVSubscription: class {
    var active: Bool { get }
    var showResponse: Bool { get }
    var front: Bool { get set }
    var identifier: TimeInterval { get }
    weak var scrollView: UIScrollView? { get }
    var reference: RVBaseModel? { get set }
    func subscribe(datasource: RVBaseDatasource4, query: RVQuery, reference: RVBaseModel?, scrollView: UIScrollView?, front: Bool) -> Void
    func unsubscribe(callback: @escaping ()-> Void) -> Void
}
