//
//  RVTransactionDynamicListConfiguration8.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/16/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
class RVTransactionDynamicListConfiguration8: RVTransactionListConfiguration8 {

    override init(scrollView: UIScrollView?) {
        super.init(scrollView: scrollView)
        self.manager = RVDSManager5Transaction(scrollView: scrollView, maxSize: 80, managerType: .main, dynamicSections: true, useZeroCell: true)
        self.manager.subscription = RVTransactionSubscription(front: true, showResponse: false)
    }

}
