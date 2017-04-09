//
//  RVDSManager5.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/9/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
class RVDSManager5<S: NSObject>: RVBaseDatasource4<RVBaseDatasource4<RVBaseModel>> {
    init(scrollView: UIScrollView?, maxSize: Int = 300) {
        super.init(manager: nil, datasourceType: .section, maxSize: maxSize)
    }
}
