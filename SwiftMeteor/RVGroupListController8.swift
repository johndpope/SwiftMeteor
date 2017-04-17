//
//  RVGroupListController8.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/16/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit

class RVGroupListController8: RVTransactionListController8 {
    
    override var instanceConfiguration: RVBaseConfiguration8 { return RVTransactionDynamicListConfiguration8(scrollView: dsScrollView) }
 
}
