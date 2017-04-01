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
    weak var scrollView: UIScrollView? { get }
    var reference: RVBaseModel? { get set }
    func subscribe(query: RVQuery, reference: RVBaseModel?, scrollView: UIScrollView?, front: Bool) -> Void
    func unsubscribe() -> Void
}
