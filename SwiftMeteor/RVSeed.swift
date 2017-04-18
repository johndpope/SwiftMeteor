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
        } else {
            print("In RVSeed.createTask, failed to generate a name")
        }
        if let root = RVCoreInfo.sharedInstance.rootTask {
            task.parentId = root.localId
            task.parentModelType = root.modelType
        } else {
            print("In RVSeed.createTask, no rootTask found")
        }
        if let tweet = LoremIpsum.tweet() {
            if let tIndex = tweet.index(tweet.startIndex, offsetBy: 30, limitedBy: tweet.endIndex) {
                let tweet = tweet.substring(to: tIndex)
                task.comment = tweet
            }
        }
        task.title = animals[ count % animals.count ]
        return task
    }
    class func populateTasks(count: Int) {
        if count <= 0 { return }
        if let rootTask = RVCoreInfo.sharedInstance.rootTask {
            let task = createTask(rootTask: rootTask, count: count)
            task.create(callback: { (result, error) in
                if let error = error {
                    error.printError()
                } else {
                    print("Created task with parent: \(task.parentId ?? " no parentId"), title: \(task.title!), handle: \(task.handle!), comment: \(task.comment ?? " no comment")")
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
            } else  {
                print("In RVSeed.clear, got [\(models.count)] result")
                for model in models {
                    if let task = model as? RVTask {
                        task.delete(callback: { (count, error) in
                            if let error = error {
                                print(error)
                            }
                        })
                    } else {
                        print("In RVSeed.clear, model is not a RVTask")
                    }
                }
            }
        }
    }
    class func createRootTask(callback: @escaping(_ root: RVTask?, _ error: RVError?) -> Void) {
        let query = RVQuery()
        query.limit = 1
        query.addAnd(term: RVKeys.special, value: RVSpecial.root.rawValue as AnyObject, comparison: .eq)
        RVTask.bulkQuery(query: query) { (models, error) in
            DispatchQueue.main.async {
                if let error = error {
                    error.append(message: "In RVSeed.createTaskRoot got error searching for Root special")
                    error.printError()
                    callback(nil , error)
                    return
                } else if let tasks = models as? [RVTask] {
                    if let root = tasks.first {
                        RVCoreInfo.sharedInstance.rootTask = root
                        // print("In RVSeed.createRootTask, found root with id: \(root._id) \(root.special.rawValue)")
                        callback(root, nil)
                        return
                    }
                }
                print("In RVSeed.createRootTask, no root task found; now creating one")
                let task = RVTask()
                task.special = RVSpecial.root
                task.title = "Root"
                task.text = "Root text"
                task.comment = "Root Root"
                task.owner = "Neil"
                task.handle = "Neil"
                task.regularDescription = "Description of Root"
                task.create(callback: { (result, error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            error.append(message: "In RVSeed.createTaskRoot got error creating root")
                            callback(nil , error)
                        } else {
                            RVCoreInfo.sharedInstance.rootTask = task
                            callback(task, nil)
                        }
                    }

                })
            }

        }
    }
    class func createTaskRoot(callback: @escaping(_ root: RVTask?, _ error: RVError?) -> Void) {
        print("in RVSeed.createTaskRoot")
        let query = RVQuery()
        query.limit = 1
        query.addAnd(term: .title, value: "Root" as AnyObject, comparison: .eq )
        RVTask.bulkQuery(query: query, callback: { (models, error) in
            if let error = error {
                error.append(message: "Error in RVSeed.createRoot")
                callback(nil, error)
                return
            } else  {
                if let model = models.first as? RVTask {
                RVCoreInfo.sharedInstance.rootTask = model
                    print("Root Model Found")
                    callback(model, nil)
                } else {
                    print("No Root Model found")
                    let task = RVTask()
                    task.title = "Root"
                    task.text = "Root text"
                    task.comment = "Root Root"
                    task.owner = "Neil"
                    task.handle = "Neil"
                    task.regularDescription = "Description of Root"
                    task.special = RVSpecial.root
                    task.create(callback: { (result, error) in
                        if let error = error {
                            error.append(message: "In RVSeed.createTaskRoot, got error creating")
                            callback(task, error)
                            return
                        } else {
                            RVTask.bulkQuery(query: query, callback: { (models, error) in
                                if let error = error {
                                    callback(nil , error)
                                    return
                                } else  {
                                    if let task = models.first as? RVTask {
                                        callback(task, nil)
                                        print("IN RVSeed.createTaskRoot. Needs fixing")
                                        RVCoreInfo.sharedInstance.rootTask = task
                                    } else {
                                        print("In RVSeed.createTaskRoot, createdTask but on retrieve, no error, have models array does not have a RVTask object")
                                        callback(nil, nil)
                                    }
                                }
                            })
                        }
                    })
                }
            }
        })

    }
}

