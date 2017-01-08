//
//  RVSeed.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/7/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
import LoremIpsum

class RVSeed {
    var instanceType: String { get { return String(describing: type(of: self)) } }
    static let animals = ["Ant", "ant", "Ant bear", "ant bear", "bear", "Bear", "bird", "Bird", "birD", "BirD", "cat", "cat dog shark", "deer", "deer deer deer", "Deer", "deeR", "dolphin","dog", "Fish", "fish", "lion", "raccoon", "shark", "skunk", "tiger", "wolf", "zebra", "Zebra"]
    class func tryIt() {
        var output = ""
        for index in (0..<50) {
            let tweet = LoremIpsum.tweet()
            let tIndex = tweet?.index((tweet?.startIndex)!, offsetBy: 20)
            output = "idex:\(index), name:\(LoremIpsum.name()), tweet: \(LoremIpsum.tweet().substring(to: tIndex!)) date: \(LoremIpsum.date())"
            print(output)
        }
    }
    class func createTask(rootTask: RVTask, count: Int) -> RVTask {
        let task = RVTask()

        if let name = LoremIpsum.name() {
            task.handle = name
            task.handleLowercase = name.lowercased()
        } else {
            print("In RVSeed.createTask, failed to generate a name")
        }
        if let tweet = LoremIpsum.tweet() {
            if let tIndex = tweet.index(tweet.startIndex, offsetBy: 30, limitedBy: tweet.endIndex) {
                let tweet = tweet.substring(to: tIndex)
                task.comment = tweet
                task.lowercaseComment = tweet.lowercased()
            }
        }
        task.title = animals[ count % animals.count ]
        return task
    }
    class func populateTasks(count: Int) {
        if count <= 0 { return }
        if let rootTask = RVCoreInfo.sharedInstance.rootTask {
            let task = createTask(rootTask: rootTask, count: count)
            task.create(callback: { (error) in
                if let error = error {
                    error.printError()
                } else {
                    print("Created task with title: \(task.title!), handle: \(task.handle!), comment: \(task.comment), commentLC: \(task.lowercaseComment)")
                }
            })
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (timer) in
                populateTasks(count: count - 1)
            })
        } else {
            print("In RVSeed.populateTasks, no Root Task")
        }
    }
    class func clear() {
        let query = RVQuery()
        query.limit = 1000
        RVTask.bulkQuery(query: query) { (models, error) in
            if let error = error {
                error.append(message: "In RVSeed.clear, got error")
                error.printError()
            } else if let models = models {
                print("In RVSeed.clear, got [\(models.count)] result")
                for model in models {
                    if let task = model as? RVTask {
                        task.delete(callback: { (error) in
                            if let error = error {
                                print(error)
                            }
                        })
                    } else {
                        print("In RVSeed.clear, model is not a RVTask")
                    }
                }
            } else {
                print("In RVSeed.clear, no error but no models")
            }
        }
    }
    class func createTaskRoot(callback: @escaping(_ root: RVTask?, _ error: RVError?) -> Void) {
        let query = RVQuery()
        query.limit = 1
        query.addAnd(term: .title, value: "Root" as AnyObject, comparison: .eq )
        RVTask.bulkQuery(query: query, callback: { (models, error) in
            if let error = error {
                error.append(message: "Error in RVSeed.createRoot")
                callback(nil, error)
                return
            } else if let models = models  {
                if let model = models.first as? RVTask {
                RVCoreInfo.sharedInstance.rootTask = model
                 //   print("Root Model Found")
                    callback(model, nil)
                } else {
                //    print("No Root Model found")
                    let task = RVTask()
                    task.title = "Root"
                    task.text = "Root text"
                    task.comment = "Root Root"
                    task.owner = "Neil"
                    task.handle = "Neil"
                    task.handleLowercase = "neil"
                    task.regularDescription = "Description of Root"
                    task.create(callback: { (error) in
                        if let error = error {
                            error.append(message: "In RVSeed.createTaskRoot, got error creating")
                            callback(task, error)
                            return
                        } else {
                            RVTask.bulkQuery(query: query, callback: { (models, error) in
                                if let error = error {
                                    callback(nil , error)
                                    return
                                } else if let models = models {
                                    if let task = models.first as? RVTask {
                                        callback(task, nil)
                                        RVCoreInfo.sharedInstance.rootTask = task
                                    } else {
                                        print("In RVSeed.createTaskRoot, createdTask but on retrieve, no error, have models array does not have a RVTask object")
                                        callback(nil, nil)
                                    }
                                } else {
                                    print("In RVSeed.createTaskRoot, createdTask but on retrieve, no error nor a task object")
                                    callback(nil, nil)
                                }
                            })
                        }
                    })
                }
            } else {
                print("In \(String(describing: type(of: self))).createRoot no error but no results array")
                callback(nil, nil)
            }
        })

    }
}

