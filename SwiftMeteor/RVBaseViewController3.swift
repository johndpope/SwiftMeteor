//
//  RVBaseViewController3.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 2/5/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
class RVBaseViewController3: UIViewController {

    @IBOutlet weak var outerTopAreaView: UIView!
    @IBOutlet weak var topViewInTopArea: UIView!
    @IBOutlet weak var controllerOuterSegementedControlView: UIView!
    @IBOutlet weak var controllerSegmentedControl: UISegmentedControl!
    @IBOutlet weak var bottomViewInTopArea: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var topViewInTopAreaHeightConstraint: NSLayoutConstraint!
    var originalTopViewInTopAreaHeightConstant: CGFloat = 0.0
    @IBOutlet weak var controllerOuterSegmentControlViewHeightConstraint: NSLayoutConstraint!
    var originalControllerOuterSegmentControlViewHeightConstant: CGFloat = 0.0
    @IBOutlet weak var bottomViewInTopAreaHeightConstraint: NSLayoutConstraint!
    var originalBottomViewInTopAreaHeightConstrant: CGFloat = 0.0
    var tableViewInsetAdditionalHeight: CGFloat = 0.0
    var topAreaHeight: CGFloat {
        let top = heightConstant(constraint: topViewInTopAreaHeightConstraint)
        let middle = heightConstant(constraint: controllerOuterSegmentControlViewHeightConstraint)
        let bottom = heightConstant(constraint: bottomViewInTopAreaHeightConstraint)
        return top + middle + bottom
    }
    @IBAction func leftBarButtonTouched(_ sender: UIBarButtonItem) { handleLeftBarButton(barButton: sender) }
    @IBAction func rightBarButtonTouched(_ sender: UIBarButtonItem) { handleRightBarButton(barButton: sender)}
    var dsScrollView: UIScrollView? {
        if let tableView = self.tableView { return tableView}
        if let collectionView = self.collectionView { return collectionView }
        return nil
    }
    var instanceType: String { get { return String(describing: type(of: self)) } }
    var coreInfo: RVCoreInfo { get { return RVCoreInfo.sharedInstance }}
    var appState: RVBaseAppState { get {return coreInfo.appState} set {coreInfo.appState = newValue}}
    var deck: RVViewDeck { get { return RVViewDeck.sharedInstance }}
    func userProfileAndDomainId() -> (RVUserProfile, String)? { return coreInfo.userAndDomain() }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        setupTopArea()
        updateTableViewInsetHeight()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
}
extension RVBaseViewController3 {
    func updateTableViewInsetHeight() {
        if let tableView = self.tableView {
            let height = topAreaHeight - tableViewInsetAdditionalHeight
            let inset = tableView.contentInset
            tableView.contentInset = UIEdgeInsets(top: inset.top + height, left: inset.left, bottom: inset.bottom, right: inset.right)
            tableViewInsetAdditionalHeight = height
        }
    }
    func handleLeftBarButton(barButton: UIBarButtonItem) {
        if !coreInfo.setActiveButtonIfNotActive(nil, barButton) { return }
        deck.toggleSide(side: .left)
        let _ = coreInfo.clearActiveButton(nil, barButton)
    }
    func handleRightBarButton(barButton: UIBarButtonItem) {
        if !coreInfo.setActiveButtonIfNotActive(nil, barButton) { return }
        print("In \(instanceType).handleRightBarButton RVBaseViewController3 base method. Need to override")
        let _ = coreInfo.clearActiveButton(nil, barButton)
    }
    func setupTopArea() {
        setHeightConstant(constraint: topViewInTopAreaHeightConstraint, constant: appState.topInTopAreaHeight)
        if let control = controllerSegmentedControl { control.isHidden = (appState.controllerOuterSegmentedViewHeight == 0) ? true : false }
        if let view = controllerOuterSegementedControlView { view.isHidden = (appState.controllerOuterSegmentedViewHeight == 0) ? true : false }
        setHeightConstant(constraint: controllerOuterSegmentControlViewHeightConstraint, constant: appState.controllerOuterSegmentedViewHeight)
        setHeightConstant(constraint: bottomViewInTopAreaHeightConstraint, constant: appState.bottomInTopAreaHeight)
    }
    func getOriginalHeightConstants() -> Void {
        originalTopViewInTopAreaHeightConstant  = heightConstant(constraint: topViewInTopAreaHeightConstraint)
        originalControllerOuterSegmentControlViewHeightConstant = heightConstant(constraint: controllerOuterSegmentControlViewHeightConstraint)
        originalBottomViewInTopAreaHeightConstrant = heightConstant(constraint: bottomViewInTopAreaHeightConstraint)
    }
    func heightConstant(constraint: NSLayoutConstraint!) -> CGFloat {
        if let constraint = constraint { return constraint.constant }
        return 0
    }
    func setHeightConstant(constraint: NSLayoutConstraint!, constant: CGFloat) {
        if let constraint = constraint { constraint.constant = constant }
    }
    func configureNavBar() {
        if let navController = self.navigationController {
            //navController.navigationBar.barStyle = .black
            // navController.navigationBar.isTranslucent = false
            navController.navigationBar.barTintColor = appState.navigationBarColor
            self.title = appState.navigationBarTitle

            navController.navigationBar.tintColor = UIColor.white
            if let font = UIFont(name: "Avenir", size: 20) { // UIFont(font:"Kelvetica Nobis" size:20.0)
                let shadow = NSShadow()
                shadow.shadowOffset = CGSize(width: 2.0, height: 2.0)
                shadow.shadowColor = UIColor.black
                //
                navController.navigationBar.titleTextAttributes = [ NSFontAttributeName: font, NSShadowAttributeName: shadow,  NSForegroundColorAttributeName: UIColor.white]
            }
            setNeedsStatusBarAppearanceUpdate()

/* Also in advance, you can add these line to hide the text that comes up in back button in action bar when you navigate to another view within the navigation controller.
 
 [[UIBarButtonItem appearance]
 setBackButtonTitlePositionAdjustment:UIOffsetMake(-1000, -1000)
 forBarMetrics:UIBarMetricsDefault];
*/
        }
    }
}
extension RVBaseViewController3: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
extension RVBaseViewController3: UITableViewDelegate {
    
}
