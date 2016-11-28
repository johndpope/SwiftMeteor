//
//  FirstViewController.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 11/27/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import UIKit
import SwiftDDP

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        Meteor.client.allowSelfSignedSSL = true // Connect to a server that users a self signed ssl certificate
        Meteor.client.logLevel = .info // Options are: .Verbose, .Debug, .Info, .Warning, .Error, .Severe, .None

        NotificationCenter.default.addObserver(self, selector: #selector(FirstViewController.userDidLogin), name: NSNotification.Name(rawValue: DDP_USER_DID_LOGIN), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FirstViewController.userDidLogout), name: NSNotification.Name(rawValue: DDP_USER_DID_LOGOUT), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FirstViewController.collectionDidChange), name: NSNotification.Name(rawValue: METEOR_COLLECTION_SET_DID_CHANGE), object: nil)
    
        func userDidLogin() {
            print("The user just signed in!")
        }
        
        func userDidLogout() {
            print("The user just signed out!")
        }
        Meteor.connect("wss://rnmpassword-nweintraut.c9users.io/websocket") {
            // do something after the client connects
            print("Returned after connect")
            /*
            Meteor.loginWithUsername("neil.weintraut@gmail.com", password: "password", callback: { (result, error: DDPError?) in
                if let error = error {
                    print(error)
                } else {
                    print("\(result)")
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
                    _ = TaskCollection(name: "tasks")
        let handle = Meteor.subscribe("tasks") {
            // Do something when the todos subscription is ready
            print("Subscribed to Tasks")
            // let tasks = MeteorCollection<Task>(name: "tasks")
            //let task = Task(id: Meteor.client.getId(), fields: [ "text": "Some text", "username": "Elmo"])
            //tasks.insert(task)

            Meteor.call("tasks.insert", params: ["Some text 2"], callback: { (result, error) in
                if let error = error {
                    print("Insert error: \(error)")
                } else if let result = result {
                    print("Insert result: \(result)")
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
    override public func documentWasAdded(_ collection: String, id: String, fields: NSDictionary?) {
        let task = (TaskStruct(id: id, fields: fields))
        print("Appending task: \(task._id) \(task.text) \(task.createdAt) ")
        tasks.append(task)
    }
    override public func documentWasChanged(_ collection: String, id: String, fields: NSDictionary?, cleared: [String]?) {
        if let index = tasks.index(where: {task in return task._id == id}) {
            var task = tasks[index]
            task.update(fields: fields)
            tasks[index] = task
            print("Task was changed: \(task._id) \(task.text)")
        }
        print("Task was changed but not in local array: \(id)")
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


