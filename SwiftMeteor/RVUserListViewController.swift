//
//  RVUserListViewController.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 2/5/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit

class RVUserListViewController: RVBaseViewController3 {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "SegueFromMemberListToMemberScene", sender: nil)
    }
}
