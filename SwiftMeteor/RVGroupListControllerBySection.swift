//
//  RVGroupListControllerBySection.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/10/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit

class RVGroupListControllerBySection: RVGroupListController4 {
    
    override var instanceConfiguration: RVListControllerConfigurationProtocol { return RVTransactionConfiguration4DynamicSections<RVGroup>(scrollView: dsScrollView) }
    

}
