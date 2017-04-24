//
//  RVTransactionBroadcast.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/19/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
import SeaseAssist
class RVTransactionBroadcast {
    var count = 0
    var instanceType: String { get { return String(describing: type(of: self)) } }
    let queue = RVOperationQueue(title: "RVTransactionBroadcast")
    static var shared: RVTransactionBroadcast = {
        return RVTransactionBroadcast()
    }()
    func documentWasAdded(document: RVBaseModel) {
        queue.addOperation(RVDocumentWasAddedOperation<RVBaseModel>(model: document))
        count = count + 1
        if count > 3 { count = 0}
    }
}
class RVDocumentWasAddedOperation<T: NSObject>: RVAsyncOperation<T> {

    var model: T
    init(model: T) {
        self.model = model
        var title = "Document Was Added: "
        var id = "unknown"
        var createdAt = "no createdAt"
        if let model = model as? RVBaseModel {
            title = title + model.modelType.rawValue
            id = model.localId != nil ? model.localId! : "No Id"
            createdAt = model.createdAt != nil ? model.createdAt!.description : "No createdAt"
        }
        super.init(title: "\(title), id: \(id), createdAt: \(createdAt)", callback: {(models: [T], error: RVError?) in })
    }
    override func asyncMain() {
        if self.isCancelled {
            self.completeOperation()
            return
        }
        DispatchQueue.main.async {
            if self.isCancelled {
                self.completeOperation()
                return
            }
            if let controller = UIViewController.top() {
                self.choose(index: RVTransactionBroadcast.shared.count, controller: controller)
            }
        }
    }
    func choose(index: Int, controller: UIViewController) {
        var title = "No BaseModel"
        var messageTitle = "Not Base Model"
        var createdAt = "Not base model"
        if let model = self.model as? RVBaseModel {
            title = "\(model.modelType.rawValue)"
            messageTitle = model.title == nil ? "No Title" : "\(model.title!)"
            createdAt = model.createdAt == nil ? "No created At" : "\(model.createdAt!)"
        }
        
        let message = "\(messageTitle), \(createdAt)"
        let actions = ["OK", "Jump", "Other"]
        if index == 0 {
            UIAlertController.showAlert(withTitle: title , andMessage: message, from: controller)
            completeOperation()
        } else if index == 1 {
            UIAlertController.showDialog(withTitle: title, andMessage: message, from: controller, andActions: actions, completionHandler: { (index) in
                if index <  actions.count {
                    print("Action: \(actions[index])")
                }
                self.completeOperation()
            })
        } else if index == 2 {
            UIAlertController.showTextEntryDialog(withTitle: title, andMessage: message, andPlaceHolder: "Enter something", from: controller, completionHandler: { (response) in
                print("Response is: \(response ?? " no response")")
                self.completeOperation()
            })
        } else if index == 3 {
            UIAlertController.showTextEntryDialog(withTitle: title, andMessage: message, andPlaceHolder: "Enter something", configuration: { (textField) in
                if let _ = textField {
                    print("Have textField")
                }
            }, from: controller, completionHandler: { (response) in
                print("Response is: \(response ?? " no response")")
                self.completeOperation()
            })
        }
    }
}
