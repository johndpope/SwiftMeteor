//
//  RVBaseNavigationController.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/15/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit

class RVBaseNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
    }
    func setupNavigationController() {
        self.navigationBar.barStyle = UIBarStyle.black
        self.navigationBar.barTintColor = UIColor.candyGreen()
        UISearchBar.appearance().barTintColor = UIColor.candyGreen()
        UISearchBar.appearance().tintColor = UIColor.white
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = UIColor.candyGreen()
    }
}
