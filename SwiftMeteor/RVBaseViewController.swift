//
//  RVBaseViewController.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 11/27/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import UIKit

class RVBaseViewController: UIViewController {
    var instanceType: String { get { return String(describing: type(of: self)) } }
    let stack = [RVBaseModel]()
    weak var scrollView: UIScrollView?
    var manager: RVDSManager!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let scrollView = self.scrollView {
            self.manager = RVDSManager(scrollView: scrollView)
        } else {
            print("In \(instanceType).viewDidLoad, scrollView not set")
        }
    }
    
    
}
extension RVBaseViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("In \(instanceType).didSelectRowAt, not overridded")
    }
}
extension RVBaseViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return manager.numberOfSections()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("In \(instanceType).cellForRowAt, baseClass RVBaseViewController. Needs to be overridden")
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return manager.numberOfItems(section: section)
    }
}
