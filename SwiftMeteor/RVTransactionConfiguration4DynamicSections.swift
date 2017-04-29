//
//  RVTransactionConfiguration4DynamicSections.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/11/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit

class RVTransactionConfiguration4DynamicSections<T: RVSubbaseModel>: RVTransactionConfiguration4<T> {
    required init(scrollView: UIScrollView?) {
        super.init(scrollView: scrollView)
        self.manager = RVDSManager5Transaction<T>(scrollView: scrollView, maxSize: 80, managerType: .main, dynamicSections: true, useZeroCell: true)
        self.manager.subscription = RVTransactionSubscription8(front: true, showResponse: false)
    }
}
