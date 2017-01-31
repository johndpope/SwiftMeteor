//
//  RVMessageAuthorViewController.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/30/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
import DropDown


class RVMessageAuthorViewController: UIViewController {
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var priorityButton: UIButton!
    let reportDropDown  = DropDown()
    let priorityDropDown = DropDown()
    let textField = UITextField()
    lazy var dropDowns:[DropDown] = {
        return [self.reportDropDown, self.priorityDropDown]
    }()
    @IBAction func reportButtonTouched(_ sender: UIButton) { reportDropDown.show() }
    
    @IBAction func priorityButtonTouched(_ sender: UIButton) {
        priorityDropDown.show()
    }
    @IBAction func changeDismissalMode(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: dropDowns.forEach { $0.dismissMode = .automatic}
        case 1: dropDowns.forEach { $0.dismissMode = .onTap }
            default:
            break
        }
    }
    @IBAction func changeUI(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: setupDefaultDropDown()
        case 1: customizeDropDown(self)
        default: break;
        }
    }
    
    @IBAction func dropDownSegmentedControl(_ sender: UISegmentedControl) {
        changeUI(sender)
    }
    func setupDropDowns() {
        setupReportDropDown()
        setupPriorityDropDown()
    }
    func setupReportDropDown() {
        reportDropDown.anchorView = reportButton
        reportDropDown.bottomOffset = CGPoint(x: 0, y: reportButton.bounds.height)
        reportDropDown.dataSource = [
            "Regular",
            "Suspicious Person",
            "Suspicious Vehicle"
        ]
        reportDropDown.selectionAction = { [unowned self] (index, item) in
            self.reportButton.setTitle(item, for: .normal)
        }
        reportDropDown.cancelAction = { [unowned self] in
            self.reportDropDown.deselectRow(at: self.reportDropDown.indexForSelectedRow)
            self.reportButton.setTitle("Cancelled", for: .normal)
        }
    }

    func setupPriorityDropDown() {
        priorityDropDown.anchorView = priorityButton
        priorityDropDown.bottomOffset = CGPoint(x: 0, y: reportButton.bounds.height)
        priorityDropDown.dataSource = [
            "Info",
            "Medium",
            "Urgent"
        ]
        priorityDropDown.selectionAction = { [unowned self] (index, item) in
            self.priorityButton.setTitle(item, for: .normal)
        }
        priorityDropDown.cancelAction = { [unowned self] in
            self.priorityDropDown.deselectRow(at: self.priorityDropDown.indexForSelectedRow)
            self.priorityButton.setTitle("Cancelled", for: .normal)
        }
        
    }
    func setupDefaultDropDown() {
        DropDown.setupDefaultAppearance()
        dropDowns.forEach {
            $0.cellNib = UINib(nibName: "DropDownCell", bundle: Bundle(for: DropDownCell.self))
            $0.customCellConfiguration = nil
        }
    }
    func customizeDropDown(_ sender: AnyObject) {
        let appearance = DropDown.appearance()
        appearance.cellHeight = 60
        appearance.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        appearance.selectionBackgroundColor = UIColor(colorLiteralRed: 0.6494, green: 0.8155, blue: 1.0, alpha: 0.2)
        appearance.cornerRadius = 10.0
        appearance.shadowColor = UIColor(white: 0.6, alpha: 1.0)
        appearance.shadowOpacity = 0.9
        appearance.shadowRadius = 25.0
        appearance.animationduration = 0.25
        appearance.textColor = .darkGray
        //appearance.separatorColor = UIColor(white: 0.7, alpha: 0.8)
        //appearance.textFont = UIFont(name: "Georgia", size: 14)
        dropDowns.forEach {
            /*** FOR CUSTOM CELLS **/
            $0.cellNib = UINib(nibName: "MyCell", bundle: nil)
            $0.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
                guard let cell = cell as? MyCell else {return }
                // Setup your custom UI components
                cell.suffixLabel.text = "Suffix \(index)"
            }
            
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        DropDown.startListeningToKeyboard()
        setupDropDowns()
        dropDowns.forEach { $0.dismissMode = .onTap }
        dropDowns.forEach { $0.direction = .any}
        view.addSubview(textField)
    }
}
