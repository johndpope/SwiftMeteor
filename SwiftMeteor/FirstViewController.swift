//
//  FirstViewController.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 11/27/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import UIKit
import SwiftDDP
import SDWebImage

extension FirstViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("TextDidChange SearchText is: \(searchText)")
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        print("SearchBarCancelBUttonClicked")
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("Search Bar Did End Editing")
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("Search Bar Search Button Clicked")
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        print("Search Text Did Begin Editing")
    }
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        print("Search Bar Bookmark Button Clicked")
    }
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        print("Search Bar Selected Scope Button Index Did Change \(selectedScope)")
    }
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.characters.count == 0 {
            if let char = text.cString(using: String.Encoding.utf8) {
                let isBackSpace = strcmp(char, "\\b")
                if (isBackSpace == -92 ) {
                    print("In searchBar shouldChangeTextIn Range text is a backspace")
                }
            }
        } else {
            print("In searchBar shouldChangeTextIn Range text is: [\(text)], count is \(text.characters.count)")
        }
        return true
    }
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        print("Search Bar Should Begin Editing")
        return true
    }
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        print("Search Bar SHould end editing")
        return true
    }
    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
        print("Search Bar List Button Clicked")
    }
    func configureSearchBar() {
        searchBar.searchBarStyle = UISearchBarStyle.prominent
        searchBar.placeholder = " Search..."
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.scopeButtonTitles = scopeTitles
        searchBar.sizeToFit()
        UISearchBar.appearance().barTintColor = UIColor.candyGreen()
        UISearchBar.appearance().tintColor = UIColor.white
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = UIColor.candyGreen()
        navigationItem.titleView = searchBar
      //  self.tableView.tableHeaderView = searchBar
    }
}
class FirstViewController: UIViewController {
    @IBOutlet weak var searchBarHeightConstraint: NSLayoutConstraint!

    let scopeTitles = ["scope1", "scope2"]
    @IBOutlet weak var tableView: UITableView!
    var instanceType: String { get { return String(describing: type(of: self)) } }
    var manager: RVDSManager!
    var refreshControl = UIRefreshControl()
    var taskDatasource = RVBaseDataSource()
    var searchBar = UISearchBar()
    
    @IBAction func leftBarButton(button: UIBarButtonItem) {
        RVViewDeck.sharedInstance.toggleSide(side: RVViewDeck.Side.left)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(RVFirstViewHeaderCell.self, forHeaderFooterViewReuseIdentifier: RVFirstViewHeaderCell.identifier)
        if let constraint = searchBarHeightConstraint {
            constraint.constant = 0.0
        }
        installRefresh()
        manager = RVDSManager(scrollView: self.tableView)
        manager.addSection(section: taskDatasource)
        Meteor.client.allowSelfSignedSSL = true // Connect to a server that users a self signed ssl certificate
        Meteor.client.logLevel = .info // Options are: .Verbose, .Debug, .Info, .Warning, .Error, .Severe, .None

        NotificationCenter.default.addObserver(self, selector: #selector(FirstViewController.userDidLogin), name: NSNotification.Name(rawValue: DDP_USER_DID_LOGIN), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FirstViewController.userDidLogout), name: NSNotification.Name(rawValue: DDP_USER_DID_LOGOUT), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FirstViewController.collectionDidChange), name: NSNotification.Name(rawValue: METEOR_COLLECTION_SET_DID_CHANGE), object: nil)
        print("Just before connect")
        
        Meteor.connect("wss://rnmpassword-nweintraut.c9users.io/websocket") {
            // do something after the client connects
            print("Returned after connect")
        /*
            Meteor.loginWithUsername("neil.weintraut@gmail.com", password: "password", callback: { (result, error: DDPError?) in
                if let error = error {
                    print(error)
                } else {
                    print("After loginWIthUsernmae \(result)")
                }
            })
          */
        }
 

    }

    func collectionDidChange() {
        print("Collection Did Change")
    }
    func userDidLogin() {
        print("The user just signed in!")
        subscribeToTasks()
    }
    func insertOuter(count: Int) {
        self.insertATask(count: count) { (error) in
        
            if let error = error {
                error.printError()
            } else {
                let count = count + 1
                if count < 300 {
                    Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false, block: { (timer: Timer) in
                        print("Inserted \(count)")
                        self.insertOuter(count: count)
                    })

                } else {
                    print("Ended insert")
                }
            }
        }
    }
    var letters = ["a", "A", "e", "F", "r", "w", "W"]
    func insertATask(count: Int, callback: @escaping(_ error: RVError?) -> Void) {
        let max = 300
        let formatter = DateFormatter()
        formatter.dateFormat = "d, h:mm:ss.SSS a"
        let time = "\(formatter.string(from: Date()))"
        let task = RVTask()
        insertAnImage(parent: task)
        task.text = "\( max - count - 1) \(time)"
        let index = count % 7
        var level: Int = count / 7 - 1
        if level < 0 { level = 0}
        var three = level
        if three > 6 { three = three - 2}
        var d = ""
        for i in (0..<index) {
            d = d + letters[i]
        }
        d = d + "\(three)"

        
        task.regularDescription = "\(d)"
        task.title = "d \(three) \(count)"
        task.comment = task.regularDescription
        task.image = RVImage()
        task.create { (error: RVError?) in
            if let error = error {
                error.printError()
                callback(RVError(message: "In \(self.classForCoder).insertATask got error", sourceError: error))
                return
            } else {
                callback(nil)
                /*
                print("$$$\nIn \(self.instanceType).insertATask \(task._id), no error\n $$$")
                task.regularDescription = "A different description"
                task.text = "A different Text Entry"
                task.title = "A different Title"
                
                task.update(callback: { (error) in
                    if let error = error {
                        error.printError()
                    } else {
                        print("In \(self.instanceType).insertATask, update returned OK")
                        RVTask.retrieveInstance(id: task._id, callback: { (model, error) in
                            if let error = error {
                                error.printError()
                            } else if let model = model as? RVTask {
                                print(model.toString())
                            } else {
                                print("In \(self.instanceType).insertATask, no error but no result for id: \(task._id)")
                            }
                        })
                    }
                })
                 */
 
            }
        }
    }
    func insertAnImage(parent: RVBaseModel?) {
        let imageName = "ranch.jpg"
        let path = "thursday/"
        let filename = "hope"
        if let uiImage = UIImage(named: imageName) {
            RVImage.saveImage(image: uiImage, path: path, filename: filename, filetype: RVFileType.jpeg, parent: parent, params: [RVKeys.title.rawValue: "Caption for image" as AnyObject], callback: { (rvImage, error ) in
                if let error = error {
                    error.printError()
                } else if let rvImage = rvImage {
                    print(rvImage.toString())
                    if let urlString = rvImage.urlString {
                        if let url = URL(string: urlString) {
                            SDWebImageManager.shared().downloadImage(with: url, options: SDWebImageOptions(rawValue: 0), progress: nil, completed: { (image , error , SDImageCacheType, success, url) in
                                if let error = error {
                                    print("In FirstViewController, error uploading \(path) \(error)")
                                } else if let image = image {
                                    print("In FirtViewController, successfully download image \(image.size)")
                                } else {
                                    print("In FirstViewController, no error, no image downloaded")
                                }
                            })
                        } else {
                            print("In FirstViewController.insertAnImage, got RVImage urlString failed to create URL")
                        }
                    } else {
                         print("In FirstViewController.insertAnImage, got RVImage but no urlString")
                    }

                } else {
                    print("In FirstViewController.insertAnImage, no RVImage returned")
                }
            })
        }
    }
    func documentListener(notification: Notification) {
        if let userInfo = notification.userInfo {
            if let _ = userInfo["id"] as? String {
                // print("In \(instanceType).documentListener, id is \(id)")
                if let rawValue = userInfo["eventType"] as? String {
                    if let event = RVBaseCollection.eventType(rawValue: rawValue) {
                        if event == RVBaseCollection.eventType.changed {
                           // print("In \(instanceType).documentListiner, eventType is \(rawValue) \(id)")
                        }
                    }
                }
            }
        }
    }
    func subscribeToTasks() {
        let collection = RVTaskCollection()
        let query = RVQuery()
        query.limit = 70
//        query.sortOrder = .descending
//        query.sortTerm = .createdAt
        query.addSort(field: .createdAt, order: .descending)
        query.addAnd(queryItem: RVQueryItem(term: .createdAt, value: EJSON.convertToEJSONDate(Date()) as AnyObject, comparison: .lte))
        query.addOr(queryItem: RVQueryItem(term: .owner, value: "Goober" as AnyObject, comparison: .eq))
        query.addOr(queryItem: RVQueryItem(term: .private, value: true as AnyObject, comparison: .ne))
        query.addProjection(projectionItem: RVProjectionItem(field: .text, include: .include))
        query.addProjection(projectionItem: RVProjectionItem(field: .createdAt))
        query.addProjection(projectionItem: RVProjectionItem(field: .updatedAt))
        query.addProjection(projectionItem: RVProjectionItem(field: .regularDescription))
        query.addProjection(projectionItem: RVProjectionItem(field: .comment))
        collection.query = query
        let listenerName = "FirstView"
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: listenerName), object: nil, queue: nil, using: documentListener)
        collection.addListener(name: listenerName)
     //   let _ = collection.subscribe()
        manager.startDatasource(datasource: self.taskDatasource, query: query) { (error ) in
            if let error = error {
                print("In \(self.instanceType).subscribeToTasks(), got error starting task datasource")
                error.printError()
            }
        }
        /*
        if manager.sections.count > 0 {
            let ds = manager.sections[0]
            ds.baseQuery = query
            ds.testQuery()
        }
 */

       // insertATask()
        //insertOuter(count: 0)
        
    }
    func subscribeToTasks2() {
        let _ = TaskCollection2(name: "tasks")
        let query = RVQuery()
        query.limit = 50
        query.addSort(field: .createdAt, order: .descending)
  //      query.sortOrder = .descending
  //      query.addAnd(queryItem: RVQueryItem(term: .createdAt, value: EJSON.convertToEJSONDate(Date()) as AnyObject, comparison: .lte))
        query.addOr(queryItem: RVQueryItem(term: .owner, value: "Goober" as AnyObject, comparison: .eq))
        query.addOr(queryItem: RVQueryItem(term: .private, value: true as AnyObject, comparison: .ne))
        query.addProjection(projectionItem: RVProjectionItem(field: .text, include: .include))
        query.addProjection(projectionItem: RVProjectionItem(field: .createdAt))
        let (filters, projections) = query.query()
        print("Just before Tasks.query")
        let _ = Meteor.call("tasks.query", params: [filters as AnyObject, projections as AnyObject]) { (result: Any?, error: DDPError?) in
            if let error = error {
                print("FirstController.subscribeToTasks, error \(error)")
            } else if let result = result {
                print("In FirstViewController.subscribeToTasks, have result")
                print(result)
            } else {
                print("In FirstViewController.subscribeToTasks, no error but no results")
            }
        }
        /*
        let handle = Meteor.subscribe("tasksWQuery", params: [filters as AnyObject, projections as AnyObject ]) {
            // Do something when the todos subscription is ready
            print("Subscribed to Tasks")
            // let tasks = MeteorCollection<Task>(name: "tasks")
            //let task = Task(id: Meteor.client.getId(), fields: [ "text": "Some text", "username": "Elmo"])
            //tasks.insert(task)
/*
            Meteor.call("tasks.insert", params: ["Some text 5"], callback: { (result, error) in
                if let error = error {
                    print("Insert error: \(error)")
                } else if let result = result {
                    print("Insert result: \(result)")
                } else {
                    print("No error but no result on insert")
                }
            })
            */
            
            let task = RVTask()
            task.text = "---------- New Stuff Using Task Object"
            task.image = RVImage()
            let fields = task.rvFields
          //  print(task.toString())
            //let fields = [RVKeys.text.rawValue: "Figuring this out", RVKeys.updatedAt.rawValue:  EJSON.convertToEJSONDate(Date()), RVKeys.modelType.rawValue: RVModelType.task.rawValue ] as [String : Any]
            Meteor.call("tasks.insert2", params: [fields], callback: { (result, error) in
                if let error = error {
                    print("Insert error: \(error)")
                } else if let result = result {
                 //  print("Insert result: \(result)")
                    if let result = result as? [String : AnyObject] {
                        if let _id = result["_id"] {
                            if let _id = _id as? String {
                                Meteor.call("tasks.find", params: [_id], callback: {(result, error) in
                                    if let error = error {
                                        print("In retrieving task with id \(_id), error \(error)")
                                    } else if let result = result as? [String: AnyObject] {
                                 //       print("In retrieving task \(result)")
                                        let task = RVTask(objects: result)
                                        let updateDictionary = ["description": "updated description"]
                                        Meteor.call("tasks.update", params: [task._id, updateDictionary], callback: {(result, error) in
                                            if let error = error {
                                                print("In updated task with id \(_id), got error \(error)")
                                            } else if let result = result {
                                               // print("In updated task got result \(result)")
                                            } else {
                                                print("In updated task no error no result")
                                            }
                                        });
                                        print(task.toString())
                                    } else {
                                        print("In retrieving task with id \(_id), no error but no result");
                                    }
                                })
                            }
                        }
                    

                    }
                } else {
                    print("No error but no result on insert")
                }
            })
 
            
        }
        print("Handle is: \(handle)")
       // Meteor.unsubscribe(withId: handle)
 */
    }
    func userDidLogout() {
        print("The user just signed out!")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
class Task: MeteorDocument {
    var collection: String = "tasks"
    var createdAt: NSDate?
    var owner: String?
    var username: String?
    var text: String?
    var `private`: Bool?
}
//let tasks = MeteorCollection<Task>(name: "tasks")

struct TaskStruct {
    enum keys:String {
        case text = "text"
        case username = "username"
        case `private` = "private"
        case createdAt = "createdAt"
    }
    var _id: String?
    var text: String?
    var username: String?
    var owner: String?
    var `private`: Bool?
    var createdAt: NSDate?
    init(id: String, fields: NSDictionary?) {
        self._id = id
        update(fields: fields)
    }
    mutating func update(fields: NSDictionary?) {
        if let fields = fields {
            if let text = fields[keys.text.rawValue] as? String {
                self.text = text
            }
            if let dictionary = fields[keys.createdAt.rawValue] as? [String: NSNumber] {
                if let interval = dictionary["$date"] {
                     self.createdAt = NSDate(timeIntervalSince1970: interval.doubleValue / 1000.0)
                }
            }
        } else {
            print("-------------- No fields in creating TaskStruct")
        }
    }
}
class TaskCollection: AbstractCollection {
    var tasks = [TaskStruct]()
    var count = 0
    override public func documentWasAdded(_ collection: String, id: String, fields: NSDictionary?) {
        let task = (TaskStruct(id: id, fields: fields))
        
        print("\(count)  Appending task: \(task._id) \(task.text) \(task.createdAt) ")
        count = count + 1
        tasks.append(task)
    }
    override public func documentWasChanged(_ collection: String, id: String, fields: NSDictionary?, cleared: [String]?) {
        if let index = tasks.index(where: {task in return task._id == id}) {
            var task = tasks[index]
            task.update(fields: fields)
            tasks[index] = task
            print("Task was changed: \(task._id) \(task.text)")
        } else {
            print("Task was changed but not in local array: \(id)")
        }
        
    }
    override public func documentWasRemoved(_ collection: String, id: String) {
        if let index = tasks.index(where: {task in return task._id == id}) {
            tasks.remove(at: index)
        }
        print("Task was removed: \(id)")
    }
    public func insert(task: TaskStruct) {
        // save the document to the tasks array
        if let id = task._id {
            if let index = tasks.index(where: {candidate in return candidate._id == id}) {
                tasks[index] = task
            } else {
                tasks.append(task)
            }
        } else {
            tasks.append(task)
        }

        // try to insert the doucment on the server
        //client.insert(self.name, document: []) {}
        
        Meteor.call("tasks.insert", params: [task.text!], callback: { (result, error) in
            if let error = error {
                print("Insert error: \(error)")
            } else if let result = result {
                print("Insert result: \(result)")
            } else {
                print("No error but no result on insert")
            }
        })
        
    }
}
class TaskCollection2: AbstractCollection {
    var tasks = [RVTask]()
    var count = 0
    override public func documentWasAdded(_ collection: String, id: String, fields: NSDictionary?) {
        let task = (RVTask(id: id, fields: fields))
        count = count + 1
        print("\(count)  Appending task: \(task._id) \(task.text) \(task.createdAt) ")
        tasks.append(task)
    }
    override public func documentWasChanged(_ collection: String, id: String, fields: NSDictionary?, cleared: [String]?) {
        if let index = tasks.index(where: {task in return task._id == id}) {
            let task = tasks[index]
            print("========= Fields are: ")
            print(fields as Any)
            print(task.toString())
            task.update(fields, cleared: cleared)
            print(task.toString())
            tasks[index] = task
            print("In TaskCollection2 Task was changed: \(task._id) \(task.text)")
        } else {
            print("Task was changed but not in local array: \(id)")
        }
        
    }
    override public func documentWasRemoved(_ collection: String, id: String) {
        if let index = tasks.index(where: {task in return task._id == id}) {
            tasks.remove(at: index)
        }
        print("Task was removed: \(id)")
    }
    public func insert(task: RVTask) {
        // save the document to the tasks array
        let id = task._id
            if let index = tasks.index(where: {candidate in return candidate._id == id}) {
                tasks[index] = task
            } else {
                tasks.append(task)
            }

        
        // try to insert the doucment on the server
        //client.insert(self.name, document: []) {}
        
        Meteor.call("tasks.insert2", params: [task.text!], callback: { (result, error) in
            if let error = error {
                print("Insert error: \(error)")
            } else if let result = result {
                print("Insert result: \(result)")
            } else {
                print("No error but no result on insert")
            }
        })
        
    }
}
extension FirstViewController {
    func imageTest() {
        let string = "\(RVAWS.baseURL)/elmerfudd.jpg"
        if let url = URL(string: string) {
            print("In FirstViewController URL is \(url.absoluteString)")
            SDWebImageManager.shared().downloadImage(with: url, options: SDWebImageOptions(rawValue: 0), progress: { (some, total) in
                
            }, completed: { (image, error, cache: SDImageCacheType, finished: Bool, url: URL?) in
                if let error = error {
                    print("FirstViewController.viewDidLoad() Error \(error)")
                } else if finished {
                    if let image = image {
                        print("FirstViewController.viewDidLoad() Have image \(image.size)")
                    } else {
                        print("FirstViewController.viewDidLoad() No image")
                    }
                } else {
                    print("FirstViewController.viewDidLoad() Not finished")
                }
            })
        } else {
            print("Failed to create URL for \(string)")
        }
        let imageName = "ranch.jpg"
        let path = "goofy/something.jpg"
        if let image = UIImage(named: imageName) {
            if let data = UIImageJPEGRepresentation(image, 1.0) {
                RVAWS.sharedInstance.upload(data: data, path: path, contentType: "image/jpeg", callback: {(data, response, error) in
                    if let error = error {
                        print("In FirstViewController Got Error uploading image \(error)")
                        return
                    } else if let response = response as? HTTPURLResponse {
                        if response.statusCode == 200 {
                            if let _ = response.url?.absoluteString {
                                print("In FirstViewController Successfully uploaded to path \(path)")
                                if let url = URL(string: "https://swiftmeteor.s3-us-west-1.amazonaws.com/goofy/ranch.jpg") {
                                    SDWebImageManager.shared().downloadImage(with: url, options: SDWebImageOptions(rawValue: 0), progress: nil, completed: { (image , error , SDImageCacheType, success, url) in
                                        if let error = error {
                                            print("In FirstViewController, error uploading \(path) \(error)")
                                        } else if let image = image {
                                            print("In FirtViewController, successfully download image \(image.size)")
                                        } else {
                                            print("In FirstViewController, no error, no image downloaded")
                                        }
                                    })
                                    return
                                }
                            }
                        }
                    }
                    print("In FirstViewController, uploading \(path) no error but no results")
                })
            }
        }
    }
}
extension FirstViewController: RVFirstHeaderContentViewDelegate{
    func expandCollapseButtonTouched(button: UIButton, view: RVFirstHeaderContentView) -> Void {
        print("Header section \(view.section)")
        if view.section >= 0 {
            let datasource =  manager.sections[view.section]
            if !datasource.collapsed { datasource.collapse {
                print("return from collapse")
                }
            } else {
                datasource.expand {
                    print("return from expand")
                }
            }
        }
        print("Expand / Collapse")
    }
}
extension FirstViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }
 
    func loadHeaderFromNib() -> RVFirstHeaderContentView? {
        let bundle = Bundle(for: RVFirstHeaderContentView.self)
        let nib = UINib(nibName: "RVFirstHeaderContentView", bundle: bundle)
        if let view = nib.instantiate(withOwner: self, options: nil)[0] as? RVFirstHeaderContentView {
            return view
        }
        return nil
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: RVFirstViewHeaderCell.identifier) as? RVFirstViewHeaderCell {
            if let content = loadHeaderFromNib() {
                content.frame = headerCell.contentView.bounds
                content.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                headerCell.contentView.addSubview(content)
                content.delegate = self
                content.section = section
                content.configure(section: section, expand: true)
            }
 
            return headerCell
        } else {
            let view = UIView()
            view.backgroundColor = UIColor.blue
            let label = UILabel()
            label.text = "Seciton \(section)"
            label.frame = CGRect(x: 45, y: 5, width: 100, height: 21)
            label.textColor = UIColor.white
            view.addSubview(label)
            return view
        }

    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
      //  print("IN will display header view")
    }

 /*
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Section \(section)"
    }
 */
}
extension FirstViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //    print("In \(self.instanceType).cellForRow...")
        if let cell = tableView.dequeueReusableCell(withIdentifier: "first", for: indexPath) as? RVFirstViewTableCell {
            cell.model = manager.item(indexPath: indexPath)
            return cell
        } else {
            print("In \(self.instanceType).cellForRowAt, did not dequeue first cell type")
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       print("In \(self.classForCoder).numberOfRowsInSection \(section) \(manager.numberOfItems(section: section))")
        return manager.numberOfItems(section: section)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        //print("In \(self.classForCoder).numberOfSections... \(manager.sections.count)")
        let count = manager.sections.count
        if count == 0 {

            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
            messageLabel.text = "No data is currently available. Please pull down to refresh."
            messageLabel.textColor = UIColor.black
            messageLabel.textAlignment = NSTextAlignment.center
            messageLabel.font = UIFont(name: "Palatino-Italic", size: 20)
            messageLabel.sizeToFit()
            self.tableView.backgroundView = messageLabel
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        } else {
            self.tableView.backgroundView = self.refreshControl
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLineEtched
        }
        return count
    }
    func installRefresh() {
        self.refreshControl.backgroundColor = UIColor.purple
        self.refreshControl.tintColor = UIColor.white
        self.refreshControl.addTarget(self , action: #selector(refresh), for: UIControlEvents.valueChanged)
        self.tableView.backgroundView = self.refreshControl
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLineEtched
    }
    func refresh() {
        // self.tableView.reloadData
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        let title = "Last update: \(formatter.string(from: Date()))"
        let attrsDictionary = [NSForegroundColorAttributeName : UIColor.white]
        let attributedTitle = NSAttributedString(string: title, attributes: attrsDictionary)
        self.refreshControl.attributedTitle = attributedTitle
        if manager.sections.count > 0 {
            let datasource = manager.sections[0]
            datasource.loadFront()
        }
        self.refreshControl.endRefreshing()
    }
}

