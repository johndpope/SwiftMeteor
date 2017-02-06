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
        if let tableView = self.tableView { return tableView }
        if let collectionView = self.collectionView { return collectionView }
        return nil
    }
    var instanceType: String { get { return String(describing: type(of: self)) } }
    var coreInfo: RVCoreInfo { get { return RVCoreInfo.sharedInstance }}
    var appState: RVBaseAppState { get {return coreInfo.appState} set {coreInfo.appState = newValue}}
    var deck: RVViewDeck { get { return RVViewDeck.sharedInstance }}
    func userProfileAndDomainId() -> (RVUserProfile, String)? { return coreInfo.userAndDomain() }
    override func viewDidLoad() {
        print("In \(self.classForCoder).viewDidLoad")
        super.viewDidLoad()
        configureNavBar()
        setupTopArea()
        updateTableViewInsetHeight()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appState.initialize(scrollView: self.dsScrollView) { (error) in
            if let error = error {
                error.append(message: "In \(self.classForCoder).viewDidAppear, got initialize error")
                error.printError()
            }
        }
    }
    
}
extension RVBaseViewController3 {
    func unloadAllDatasources(callback: @escaping(_ error: RVError?)-> Void ) {
        unloadAllDatasourcesInner(count: 0, callback: { (error) in}, completion: callback)
    }
    func unloadAllDatasourcesInner(count: Int, callback: @escaping(_ error: RVError?)-> Void, completion: @escaping ( _ error: RVError?) -> Void ) {
        if count < appState.manager.sections.count {
            let datasource = appState.manager.sections[count]
            appState.manager.stopAndResetDatasource(datasource: datasource, callback: { (error) in
                if let error = error {
                    error.append(message: "In \(self.classForCoder).unloadAllDatasources, got error on count \(count)")
                    if count == 0 { completion(error) }
                    else {callback(error) }
                } else {
                    self.unloadAllDatasourcesInner(count: count + 1, callback: { (error) in
                        if count == 0 {completion(error) }
                        else { callback(nil) }
                    }, completion: completion)
                }
            })
        } else {
            if count == 0 {completion(nil)}
            else {callback(nil) }
        }
    }
    func reload() {
        unloadAllDatasources { (error) in
            if let error = error {
                error.append(message: "In \(self.classForCoder).reload, got error")
                error.printError()
            } else {
                self.appState.initialize(scrollView: self.dsScrollView , callback: { (error) in
                    if let error = error {
                        error.append(message: "In \(self.classForCoder).unloadAllDatasources line \(#line) error")
                        error.printError()
                    }
                })
                /*
                for datasource in self.appState.datasources {
                    if datasource.datasourceType == .main {
                        if let queryFunction = self.appState.queryFunctions[RVBaseDataSource.DatasourceType.main] {
                            let query = queryFunction([String: AnyObject]())
                            self.appState.manager.startDatasource(datasource: datasource, query: query, callback: { (error) in
                                if let error = error {
                                    error.append(message: "In \(self.classForCoder).reload line \(#line), got error")
                                    error.printError()
                                }
                            })
                        }
                    }
                }
 */
            }
        }
    }
    func updateTableViewInsetHeight() {
        if let tableView = self.dsScrollView as? UITableView {
            let height = topAreaHeight - tableViewInsetAdditionalHeight
            let inset = tableView.contentInset
            tableView.contentInset = UIEdgeInsets(top: inset.top + height, left: inset.left, bottom: inset.bottom, right: inset.right)
            tableViewInsetAdditionalHeight = height
        }
    }
    func handleLeftBarButton(barButton: UIBarButtonItem) {
        if !coreInfo.setActiveButtonIfNotActive(nil, barButton) { return }
        appState.unwind {
            self.appState = RVMenuAppState()
            self.deck.toggleSide(side: .left)
            let _ = self.coreInfo.clearActiveButton(nil, barButton)
        }

    }
    func handleRightBarButton(barButton: UIBarButtonItem) {
        if !coreInfo.setActiveButtonIfNotActive(nil, barButton) { return }
        print("In \(instanceType).handleRightBarButton RVBaseViewController3 base method. Need to override")
        let _ = coreInfo.clearActiveButton(nil, barButton)
    }
    func setupTopArea() {
        setHeightConstant(constraint: topViewInTopAreaHeightConstraint, constant: appState.topInTopAreaHeight)
        if let control = controllerSegmentedControl { control.isHidden = (appState.controllerOuterSegmentedViewHeight == 0) ? true : false }
        if let view = controllerOuterSegementedControlView {
            view.isHidden = (appState.controllerOuterSegmentedViewHeight == 0) ? true : false
            view.backgroundColor = appState.navigationBarColor
        }
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
        return appState.manager.numberOfSections()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appState.manager.numberOfItems(section: section)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: RVUserTableViewCell.identifier, for: indexPath) as? RVUserTableViewCell {
            cell.model = appState.manager.item(indexPath: indexPath)
            return cell
        }
        return UITableViewCell()
    }
}
extension RVBaseViewController3: UITableViewDelegate {
    
}
