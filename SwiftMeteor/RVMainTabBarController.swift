//
//  RVMainTabBarController.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/10/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit

class RVMainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        RVCoreInfo2.shared.printCoreInfo()
        let group = RVGroup()
        group.title = "Dummy Group"
        group.create { (group , error) in
            if let error = error {
                error.printError()
            } else if let group = group {
                group.printAllSubgroup()
            } else {
                print("In \(self.classForCoder), no error but no result")
            }
        }
    }
}
