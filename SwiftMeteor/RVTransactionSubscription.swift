//
//  RVTransactionSubscription.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 4/1/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//


import UIKit
class RVTransactionSubscription: RVBaseCollection, RVSubscription {
    fileprivate var _active: Bool = false
    var active: Bool { get { return _active } }
    var showResponse: Bool = false
    var front: Bool = false
    var identifier: TimeInterval = Date().timeIntervalSince1970
    weak var scrollView: UIScrollView? = nil
    var reference: RVBaseModel? = nil
    fileprivate var datasourceListeners = [RVBaseDatasource4]()
    init() {
        super.init(collection: .transaction)
    }
    func subscribe(datasource: RVBaseDatasource4, query: RVQuery, reference: RVBaseModel?, scrollView: UIScrollView? = nil, front: Bool = true) -> Void {
        if self.active {
            print("In \(self.classForCoder).subscribe, subscription was already active")
        }
        self._active = true
        self.query = query
        self.reference = reference
        self.scrollView = scrollView
        self.front = front
        self.datasourceListeners.append(datasource)
        let _ = self.subscribe()
    }
    func unsubscribe(callback: @escaping ()-> Void) -> Void {
        if let id = self.subscriptionID {
            self.unsubscribe(id: id, callback: callback)
        }
    }
    override func populate(id: String, fields: NSDictionary) -> RVBaseModel {
        let transaction = RVTransaction(id: id , fields: fields)
        // print("In \(self.instanceType).populate, have transaction \(transaction.createdAt!) TopParentId: \(transaction.topParentId)")
        return transaction
    }
    override public func documentWasAdded(_ collection: String, id: String, fields: NSDictionary?) {
        print("\(self.classForCoder).documentWasAdded for collection: \(collection), id: \(id)")
        if let fields = fields {
            let document = populate(id: id, fields: fields)
            for datasource in datasourceListeners {
                datasource.receiveSubscriptionResponse(sourceSubscription: self, incomingModels: [document], responseType: .added)
            }
            RVTransactionBroadcast.shared.documentWasAdded(document: document)
            var copy = self.elements.map { $0 }
            copy.append(document)
            self.elements = copy
            //  print("In \(#file) #\(#line).documentWasAdded id: \(id)")
            self.publish(eventType: .added, model: document, id: id)
        } else {
            print("In \(#file) #\(#line).documentWasAdded fields is nil")
        }
    }
}
