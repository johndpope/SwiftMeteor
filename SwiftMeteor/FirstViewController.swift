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

class FirstViewController: UIViewController {
    @IBAction func leftBarButton(button: UIBarButtonItem) {
        RVViewDeck.sharedInstance.toggleSide(side: RVViewDeck.Side.left)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
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
    func subscribeToTasks() {
        _ = TaskCollection2(name: "tasks")
        let query = RVQuery()
        query.limit = 50
        query.sortOrder = .descending
  //      query.addAnd(queryItem: RVQueryItem(term: .createdAt, value: EJSON.convertToEJSONDate(Date()) as AnyObject, comparison: .lte))
        query.addOr(queryItem: RVQueryItem(term: .owner, value: "Goober" as AnyObject, comparison: .eq))
        query.addOr(queryItem: RVQueryItem(term: .private, value: true as AnyObject, comparison: .ne))
        let (filters, projections) = query.query()
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
            print(fields)
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


