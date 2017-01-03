//
//  RVBaseDataSource.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 12/31/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import UIKit
import SwiftDDP

class RVBaseDataSource {
    var instanceType: String { get { return String(describing: type(of: self)) } }
    var maximumArrayLength: Int = 130
    var backBuffer = 30
    var frontBuffer = 20
    var frontTimer: Bool = false
    var frontTime: TimeInterval = Date().timeIntervalSince1970
    var backTime: TimeInterval = Date().timeIntervalSince1970
    let minimumInterval: TimeInterval = 0.5
    var backTimer: Bool = false
    var array = [RVBaseModel]()
    var baseQuery: RVQuery? = nil
    let identifier = NSDate().timeIntervalSince1970
    weak var scrollView: UIScrollView? = nil
    let backOperationName = "BackOperation"
    let frontOperationName = "FrontOperation"
    var backOperation: RVDSOperation
    var frontOperation: RVDSOperation {
        didSet {
         //  print("Front Operation replaced \(frontOperation.identifier)")
        }
    }
    var delay: TimeInterval = 0.001
    weak var manager: RVDSManager? = nil
    var animation: UITableViewRowAnimation = UITableViewRowAnimation.automatic
    private var offset: Int = 0
    init() {
        self.backOperation = RVDSOperation(name: backOperationName)
        self.frontOperation = RVDSOperation(name: frontOperationName)
    }
    var virtualCount: Int {
        get {
            return array.count + offset
        }
    }
    var scrollViewCount: Int {
        get {
            return virtualCount
        }
    }
    /*
    init(scrollView: UIScrollView?, manager: RVDSManager) {
        self.scrollView = scrollView
        self.manager = manager
    }
 */
/*
    func reStart(query: RVQuery) {
        self.reset {
            if self.array.count == 0 {
                let operation = self.backOperation
                if let query = self.baseQuery {
                    if !operation.active {
                        operation.active = true
                        RVTask.bulkQuery(query: query) { (models: [RVBaseModel]?, error: RVError?) in
                            if let error = error {
                                print("In \(self.instanceType).subscribeToTasks, got error")
                                error.printError()
                            } else if let models = models {
                                var index = 0
                                for _ in models {
                                  //  print("\(index): \(model.text!)")
                                    index = index + 1
                                }
                                if self.backOperation.identifier == operation.identifier {
                                    self.appendAtBack(operation: operation, items: models)
                                }
                            } else {
                                print("In \(self.instanceType).subscribeToTasks, no error but no results")
                            }
                        }
                    }
                }
            } else {
                
            }
        }
    }
 */
    func replaceFrontOperation(operation: RVDSOperation) {
        if self.frontOperation.identifier == operation.identifier {
            self.frontOperation = RVDSOperation(name: frontOperationName)

        }
    }
    func queryForFront(operation: RVDSOperation, callback: @escaping(_ error: RVError?) -> Void) {
       // return
        if let query2 = self.baseQuery {
            //let operation = self.frontOperation
            if self.array.count == 0 {
                // Neil do nothing for now
                operation.cancelled = true
                replaceFrontOperation(operation: operation)
                callback(nil)
            } else {
                let query = query2.duplicate().updateQuery(front: true)
                if let first = self.array.first {
                    switch(query.sortTerm) {
                    case .createdAt:
                        if let firstCreatedAt = first.createdAt {
                            if let queryTerm = query.findAndTerm(term: .createdAt) {
                                queryTerm.value = EJSON.convertToEJSONDate(firstCreatedAt) as AnyObject
                              //  if queryTerm.comparison == .lte {queryTerm.comparison = .gt}
                              //  else if queryTerm.comparison == .gte {queryTerm.comparison = .lt}
                            } else {
                                 print("In \(self.instanceType).queryForFront no queryTerm for createdAt")
                            }
                        }
                     //   if query.sortOrder == .ascending { query.sortOrder = .descending}
                     //   else { query.sortOrder = .ascending }
                    default:
                        print("In \(self.instanceType).queryForBack, have unserviced sortTerm: \(query.sortTerm.rawValue)")
                    }
                               //   print("In \(self.instanceType).queryForFront() about to do bulkQuery")
                    RVTask.bulkQuery(query: query , callback: { (models, error) in
                        if let error = error {
                            print("In \(self.instanceType).queryForFront, got error")
                            error.printError()
                            operation.cancelled = true
                            self.replaceFrontOperation(operation: operation)
                            error.append(message: "In \(self.instanceType).queryForFront, got error")
                            callback(error)
                        } else if let models = models {
                            var index = 0
                            for _ in models {
                              //  print("\(index): \(model.text!), \(model.createdAt)")
                                index = index + 1
                            }
                            if self.frontOperation.identifier == operation.identifier {
                                self.insertAtFront(operation: operation, items: models)
                            }
                            callback(nil)
                        } else {
                            print("In \(self.instanceType).queryForFront, no error but no results")
                            operation.cancelled = true
                            self.replaceFrontOperation(operation: operation)
                            callback(nil)
                        }
                    })
 
                } else {

                    operation.cancelled = true
                    replaceFrontOperation(operation: operation)
                    let rvError = RVError(message: "In \(self.instanceType).queryForFront, no first entry in array")
                    callback(rvError)
                }
            }
        } else {
            print("In \(self.instanceType).queryForFront, no query. Invalid state")
            operation.cancelled = true
            replaceFrontOperation(operation: operation)
            let rvError = RVError(message: "In \(self.instanceType).queryForFront, no query. Invalid state")
            callback(rvError)
        }
    }
    func queryForBack(callback: @escaping(_ error: RVError?) -> Void) {
        if let query = self.baseQuery {
            let operation = self.backOperation

                if self.array.count == 0 {
                    queryForBackHelper(query: query, operation: operation, callback: callback)
                } else {
                    let query = query.duplicate().updateQuery(front: false)
                    if let last = self.array.last {
                     //   print("In \(self.instanceType).queryForBack have last... \(last.text!)")
                        switch(query.sortTerm) {
                        case .createdAt:
                            if let lastCreatedAt = last.createdAt {
                                if let queryTerm = query.findAndTerm(term: .createdAt) {
                                    queryTerm.value = EJSON.convertToEJSONDate(lastCreatedAt) as AnyObject
                                   // if queryTerm.comparison == .lte { queryTerm.comparison = .lt}
                                   // else if queryTerm.comparison == .gte { queryTerm.comparison = .gt}
                                } else {
                                    print("In \(self.instanceType).queryForBack no queryTerm for createdAt")
                                }
                            }
                        default:
                            print("In \(self.instanceType).queryForBack, have unserviced sortTerm: \(query.sortTerm.rawValue)")
                        }
                        queryForBackHelper(query: query, operation: operation, callback: callback)
                        return
                    } else {
                        let rvError = RVError(message: "In \(self.instanceType).queryForBack, last item")
                        operation.cancelled = true
                        self.replaceBackOperation(operation: operation)
                        callback(rvError)
                        return
                    }
                }

        } else {
            let rvError = RVError(message: "In \(self.instanceType).queryForBack, no baseQuery")
            callback(rvError)
        }
    }
    func queryForBackHelper(query: RVQuery, operation: RVDSOperation, callback: @escaping(_ error: RVError?)-> Void) {
       // print("In \(self.instanceType).queryForBackHelper() about to do bulkQuery")
        RVTask.bulkQuery(query: query) { (models: [RVBaseModel]?, error: RVError?) in
            if let error = error {
                print("In \(self.instanceType).subscribeToTasks, got error")
                error.printError()
                error.append(message: "In \(self.instanceType).subscribeToTasks, got error")
                operation.cancelled = true
                self.replaceBackOperation(operation: operation)
                callback(error)
            } else if let models = models {
                var index = 0
                for _ in models {
                  //  print("\(index): \(model.text!), \(model.createdAt)")
                    index = index + 1
                }
                if self.backOperation.identifier == operation.identifier {
                    self.appendAtBack(operation: operation, items: models)
                }
                callback(nil)
            } else {
                print("In \(self.instanceType).subscribeToTasks, no error but no results")
                operation.cancelled = true
                self.replaceBackOperation(operation: operation)
            }
        }
    }
    func item(location: Int) -> RVBaseModel? {
      //  print("In \(self.instanceType).item, with location: \(location)")
        if location >= 0 {
            let mappedIndex = location - self.offset
            if mappedIndex >= 0 {
                if mappedIndex < self.array.count {
                    if location > (self.virtualCount - self.backBuffer) {
                        inBackZone(location: location)
                    } else if location < (self.frontBuffer + self.offset) {
                        inFrontZone(location: location)
                    }
                    return self.array[mappedIndex]
                } else {
                    print("In \(self.instanceType).item, got mapped Index greater than array count. location = \(location), offset = \(self.offset), array count: \(self.array.count)")
                }
            } else {
                print("In \(self.instanceType).item got negative mapped Index. location = \(location), offset = \(self.offset), array count: \(self.array.count)")
                inFrontZone(location: location)
            }
        } else {
            print("In \(self.instanceType).item. Location is less than zero. location = \(location), offset = \(self.offset), array count: \(self.array.count)")
        }
        return nil
    }
    func inFrontZone(location: Int) {
      //  print("In \(self.instanceType).inFrontZone. location = \(location), offset = \(self.offset), array count = \(self.array.count)")
        if (Date().timeIntervalSince1970 - self.frontTime) < minimumInterval { return }
        if frontTimer { return }
        frontTimer = true
        if self.backOperation.active {
            self.backOperation.cancelled = true
            self.backOperation = RVDSOperation(name: backOperationName)
        }
        let operation = self.frontOperation
        if !operation.active {
           // print("In \(self.instanceType).inFrontZone, passed active. location = \(location), offset = \(self.offset), array count = \(self.array.count)")
            operation.active = true
            self.frontTime = Date().timeIntervalSince1970
            Timer.scheduledTimer(withTimeInterval: delay, repeats: false, block: { (timer: Timer) in
                //print("In \(self.instanceType).inFrontZone, returned from timer ------------------- ")
                if self.frontOperation.identifier == operation.identifier {
                    if let tableView = self.scrollView as? UITableView {
                        var firstVisibleRow = 0
                        if let visiblePaths = tableView.indexPathsForVisibleRows {
                            if visiblePaths.count > 0 {
                                let firstVisiblePath = visiblePaths[0]
                                firstVisibleRow = firstVisiblePath.row
                            }
                        }
                        if firstVisibleRow < (self.offset + self.frontBuffer) {
                            if operation.identifier == self.frontOperation.identifier {
                              //  print("In \(self.instanceType).inFrontZone, doing query")
                                self.queryForFront(operation: operation, callback: { (error ) in
                                    if let error = error {
                                        error.printError()
                                    } else {
                                        //print("In \(self.instanceType).inFrontZone")
                                    }
                                })
                       //         print("In \(self.instanceType).inFrontZone. TRIGGER location = \(location), offset = \(self.offset), array count = \(self.array.count) --- Set Front Operation active")
                            } else {
                                operation.cancelled = true
                                //self.replaceFrontOperation(operation: operation)
                            }
                        } else {
                            operation.cancelled = true
                            self.replaceFrontOperation(operation: operation)
                        }
                    }

                } else {
                    print("In \(self.instanceType).inFrontZone, returned from timer, different frontOperation")
                    operation.cancelled = true
                }
                self.frontTimer = false
            })
        } else {
            frontTimer = false
        }
    }
    func loadFront() {
        if (Date().timeIntervalSince1970 - self.frontTime) < minimumInterval { return }
        if frontTimer { return }
        frontTimer = true
        if self.backOperation.active {
            self.backOperation.cancelled = true
            self.backOperation = RVDSOperation(name: backOperationName)
        }
        let operation = self.frontOperation
        if !operation.active {
            // print("In \(self.instanceType).inFrontZone, passed active. location = \(location), offset = \(self.offset), array count = \(self.array.count)")
            operation.active = true
            self.frontTime = Date().timeIntervalSince1970
            Timer.scheduledTimer(withTimeInterval: delay, repeats: false, block: { (timer: Timer) in
                if let tableView = self.scrollView as? UITableView {
                        if operation.identifier == self.frontOperation.identifier {
                        //    print("In \(self.instanceType).loadFront(), matched identifier")
                            self.queryForFront(operation: operation, callback: { (error ) in
                                if let error = error {
                                    error.printError()
                                } else {
                                    //print("In \(self.instanceType).inFrontZone")
                                }
                            })
                            //   print("In \(self.instanceType).inFrontZone. TRIGGER location = \(location), offset = \(self.offset), array count = \(self.array.count) --- Set Front Operation active")
                        }

                }
                self.frontTimer = false
            })
        } else {
            frontTimer = false
        }
    }
    func inBackZone(location: Int) {
       // print("In \(self.instanceType).inBackZone. location = \(location), offset = \(self.offset), array count = \(self.array.count)")
        if Date().timeIntervalSince1970 - self.backTime < minimumInterval { return }
        if backTimer { return }
        backTimer = true
        if self.frontOperation.active {
            print("In \(self.instanceType).inBackZone, cancelling Front Operation ----------------------------- ")
            self.frontOperation.cancelled = true
            self.frontOperation = RVDSOperation(name: frontOperationName)
        }
     //   print("So far")
        let operation = self.backOperation
        if !operation.active {
            operation.active = true
            self.backTime = Date().timeIntervalSince1970
            Timer.scheduledTimer(withTimeInterval: delay, repeats: false, block: { (timer: Timer) in
                if let tableView = self.scrollView as? UITableView {
                    var lastVisibleRow = 0
                    if let visiblePaths = tableView.indexPathsForVisibleRows {
                        if visiblePaths.count > 0 {
                            let lastVisiblePath = visiblePaths[visiblePaths.count - 1]
                            lastVisibleRow = lastVisiblePath.row
                        }
                    }
                //    print("In \(self.instanceType).inBackZone, lastVisibleRow is \(lastVisibleRow), \(self.scrollViewCount) \(self.backBuffer)")
                    if lastVisibleRow > self.scrollViewCount - self.backBuffer {
                        if operation.identifier == self.backOperation.identifier {
                            //print("About to call queryForBack. LastVisibleRow is: \(lastVisibleRow) arraycount is: \(self.array.count)")
                            self.queryForBack(callback: { (error) in
                                if let error = error {
                                    error.printError()
                                }
                            })
                        }
                    }
                }
                self.backTimer = false
            })
           // print("In \(self.instanceType).inBackZone. location = \(location), offset = \(self.offset), array count = \(self.array.count)\n --- Set Back Operation active")
        } else {
         //   print("Back operation active")
            backTimer = false
        }
    }
    func removeBack(operation: RVDSOperation) {
        if let manager = self.manager {
            var clone = cloneData()
            let currentCount = clone.count
            let currentOffset = self.offset
            var indexPaths = [IndexPath]()
            let section = manager.section(datasource: self)
            let excess = currentCount - (self.maximumArrayLength + self.backBuffer)
            if excess > 0 {
                for index in ((self.maximumArrayLength + self.backBuffer)..<currentCount).reversed() {
                    clone.remove(at: index)
                    indexPaths.append(IndexPath(row: currentOffset + index, section: section))
                }
                if let tableView = self.scrollView as? UITableView {
                    tableView.beginUpdates()
                    if (operation.identifier == self.frontOperation.identifier) && (!operation.cancelled) {
                        tableView.deleteRows(at: indexPaths, with: animation)
                        self.array = clone
                    }
                    tableView.endUpdates()
                } else if let _ = self.scrollView as? UICollectionView {
                    
                } else {
                    
                }
            }
        }
    }
    func insertAtFront(operation: RVDSOperation, items: [RVBaseModel]) {
       // let operation = self.frontOperation
     //   print("In \(self.instanceType).insertAtFront with: \(items.count) items")
        if let manager = self.manager {
            var sizedItems = maxItems(items: items) // Limits the number of new items to the maximum array size
            if sizedItems.count > 0 {
                DispatchQueue.main.async {
                    var clone = self.cloneData()
                    //var currentCount = clone.count
                    let room = clone.count - self.maximumArrayLength
                    var currentOffset = self.offset
                    var start = 0
                    if let tableView = self.scrollView as? UITableView {
                        if (self.offset > 0) && (room > 0) {
                            // Have room in array to reduce the offset without affecting TableView
                            var end = room
                            if room > sizedItems.count { end = sizedItems.count }
                            if end > currentOffset { end = currentOffset }
                            for index in (0..<end) {
                                clone.insert(sizedItems[index], at: 0)
                                currentOffset = currentOffset - 1
                                start = start + 1
                            }
                            tableView.beginUpdates()
                            if (operation.identifier == self.frontOperation.identifier) && (!operation.cancelled) {
                                self.array = clone
                                self.offset = currentOffset
                            }
                            tableView.endUpdates()
                        }
                        // May or may not have offset; may or maynot have room
                        // start variable contains the first index into sizedItems array
                        if start < sizedItems.count {
                            // See if near the front
                            var firstVisibleRow = 0
                            if let visiblePaths = tableView.indexPathsForVisibleRows {
                                if visiblePaths.count > 0 {
                                    let firstVisiblePath = visiblePaths[0]
                                    firstVisibleRow = firstVisiblePath.row
                                }
                            }
                            if firstVisibleRow < (self.frontBuffer + self.offset) {
                                // at front of TableView, new items to add at front number more than 0 and less than maxArrayLength
                                clone = self.cloneData()
                                currentOffset = self.offset
                                // first deal with offset
                                if currentOffset > 0 {
                                    let newItemsCount = sizedItems.count
                                    let numberOfNewItems = newItemsCount - start
                                    let end = currentOffset > numberOfNewItems ? newItemsCount : start + currentOffset
                                    let begin = start
                                    if begin > end { print("In \(self.instanceType).insertAtFront, begin \(begin) is greater than end \(end)") }
                                    for index in (begin..<end) {
                                        clone.insert(sizedItems[index], at: 0)
                                        currentOffset = currentOffset - 1
                                        start = start + 1
                                    }
                                    tableView.beginUpdates()
                                    if (operation.identifier == self.frontOperation.identifier) && (!operation.cancelled) {
                                        self.array = clone
                                        self.offset = currentOffset
                                    }
                                    tableView.endUpdates()
                                }
                                if start < sizedItems.count {
                                    clone = self.cloneData()
                                    var indexPaths = [IndexPath]()
                                    currentOffset = self.offset
                                    let section = manager.section(datasource: self)
                                    if currentOffset == 0 {
                                        for index in (start..<sizedItems.count) {
                                            clone.insert(sizedItems[index], at: 0)
                                            indexPaths.append(IndexPath(row: index-start, section: section))
                                        }
                                        tableView.beginUpdates()
                                        if (operation.identifier == self.frontOperation.identifier) && (!operation.cancelled) {
                                            self.array = clone
                                            tableView.insertRows(at: indexPaths, with: self.animation)

                                        }
                                        tableView.endUpdates()
                                    } else {
                                        print("In \(self.instanceType).insertAtFront, offset is \(self.offset), when should be zero")
                                    }
                                }
                                self.removeBack(operation: operation)
                            }
                        }
                        operation.cancelled = true
                        self.replaceFrontOperation(operation: operation)
                    } else if let _ = self.scrollView as? UICollectionView {
                        operation.cancelled = true
                        self.replaceFrontOperation(operation: operation)
                    } else {
                        operation.cancelled = true
                        self.replaceFrontOperation(operation: operation)
                    }
                } // Dispatch
            } else {
                operation.cancelled = true
                self.replaceFrontOperation(operation: operation)
            }
        } else {
            print("In \(self.instanceType).insertAtFront, no manager")
            operation.cancelled = true
            self.replaceFrontOperation(operation: operation)
        }

    }
    func appendAtBack(operation: RVDSOperation, items: [RVBaseModel]) {
      //  let operation = self.backOperation
        if let manager = self.manager {
            var sizedItems = maxItems(items: items) // Limits the number of new items to the maximum array size
            if sizedItems.count > 0 {
                DispatchQueue.main.async {
                 //   print("In \(self.instanceType).appendAtBack, have \(sizedItems.count) items")
                    /* have array with at least one item and less than or equal to maximumNumberOfItems */
                    var clone = self.cloneData()
                    var indexPaths = [IndexPath]()
                    let section = manager.section(datasource: self)
                    if let tableView = self.scrollView as? UITableView {
                        var start = 0
                        var currentOffset = self.offset
                        let room = self.maximumArrayLength - self.array.count
                        var atBack = true
                        if room > 0 {
                            var end = room
                            // If number of new items less than room, set end to number of new Items, else use all the room
                            if sizedItems.count < end { end = sizedItems.count }
                          //  print("In \(self.instanceType).appendAtBack, adding \(end) items in first add to fill array")
                            for index in (0..<end) {
                                clone.append(sizedItems[index])
                       //         print("In \(self.instanceType).appendAtBack, adding section: \(section), row: \(currentOffset + clone.count - 1)")
                                indexPaths.append(IndexPath(row: (currentOffset + clone.count - 1), section: section))
                                start = start + 1
                            }
                            var lastVisibleRow = 0
                            if let visiblePaths = tableView.indexPathsForVisibleRows {
                                if visiblePaths.count > 0 {
                                    let lastVisiblePath = visiblePaths[visiblePaths.count - 1]
                                    lastVisibleRow = lastVisiblePath.row
                                }
                            }
                            if lastVisibleRow < (self.virtualCount - self.backBuffer) { atBack = false }
                            tableView.beginUpdates()
                            if (operation.identifier == self.backOperation.identifier) && (!operation.cancelled) {
                               // print("In \(self.instanceType).appendAtBack, doing insertOperation with cloneCount = \(clone.count), indexPaths count = \(indexPaths.count)")
                                self.array = clone
                                tableView.insertRows(at: indexPaths, with: self.animation)
                            }
                          //  print("In \(self.instanceType).appendAtBack, after insertOperation just before endUpdates()")
                            tableView.endUpdates()
                          //  print("In \(self.instanceType).appendAtBack, after insertOperation")
                        } else {
                            var lastVisibleRow = 0
                            if let visiblePaths = tableView.indexPathsForVisibleRows {
                                if visiblePaths.count > 0 {
                                    let lastVisiblePath = visiblePaths[visiblePaths.count - 1]
                                    lastVisibleRow = lastVisiblePath.row
                                }
                            }
                            if lastVisibleRow < (self.virtualCount - self.backBuffer) { atBack = false }
                        }
                        

               //         print("In \(self.instanceType).appendAtBack, array Count is: \(self.array.count), start is: \(start)")
                        clone = self.cloneData()
                        indexPaths = [IndexPath]()
              //          let lastVirtualRow = self.virtualCount
                        if atBack {
                            currentOffset = self.offset
                            if start < sizedItems.count {
                                for index in (start..<sizedItems.count) {
                                    clone.append(sizedItems[index])
                                  //  print("In \(self.instanceType).appendAtBack, adding section: \(section), row: \(currentOffset + clone.count - 1)")
                                    indexPaths.append(IndexPath(row: currentOffset + clone.count - 1, section: section))
                                }
                             //   print("In \(self.instanceType).appendAtBack, clone size is: \(clone.count)")
                                var cloneOffset = 0
                                var clone2: [RVBaseModel]
                                (clone2, cloneOffset) = self.adjustArray(items: clone)
                                tableView.beginUpdates()
                                if (operation.identifier == self.backOperation.identifier) && (!operation.cancelled) {
                                    self.array = clone2
                                  //  print("In \(self.instanceType).appendAtBack array count is \(self.array.count), currentOffset = \(currentOffset), cloneOffset = \(cloneOffset)")
                                    self.offset = currentOffset + cloneOffset
                                    tableView.insertRows(at: indexPaths, with: self.animation)
                                }
                                tableView.endUpdates()
                              //  print("In \(self.instanceType).appendAtBack, after second insertOperation arrayCount = \(self.array.count), offset = \(self.offset)")
                            }
                        }
                      //  print("In \(self.instanceType).appendAtBack, array Count is: \(self.array.count)")
                        self.replaceBackOperation(operation: operation)
                    } else if let _ = self.scrollView as? UICollectionView {
                        self.replaceBackOperation(operation: operation)
                    } else {
                        self.replaceBackOperation(operation: operation)
                    }
                }
                
            } else {
                            replaceBackOperation(operation: operation)
            }
        } else {
            replaceBackOperation(operation: operation)
        }
    }
    func replaceBackOperation(operation: RVDSOperation) {
        if self.backOperation.identifier == operation.identifier {
            self.backOperation = RVDSOperation(name: backOperationName)
        }
    }
    func adjustArray(items: [RVBaseModel]) -> ([RVBaseModel], Int) {
        var offset = 0
        //return (items, offset) // Neil Plug
        if items.count > self.maximumArrayLength + self.backBuffer {
            var clone = [RVBaseModel]()
            offset = items.count - (self.maximumArrayLength + self.backBuffer)
            for index in (offset..<items.count) {
                clone.append(items[index])
            }
            return (clone, offset)
        } else {
            return (items, offset)
        }
    }
    func maxItems(items: [RVBaseModel], front: Bool = true) -> Array<RVBaseModel> {
        var maxItems = [RVBaseModel]()
        if items.count == 0 { return maxItems }
        if items.count <= self.maximumArrayLength {
            maxItems = items
        } else {
            /* More items in array than maximum length */
            var start   = 0
            var end     = self.maximumArrayLength
            if !front {
                end     = items.count
                start   = end - self.maximumArrayLength
            }
            for index in (start..<end) {
                maxItems.append(items[index])
            }
        }
        return maxItems
    }
    
    func cloneData() -> Array<RVBaseModel> {
        var clone = Array<RVBaseModel>()
        for item in self.array {
            clone.append(item)
        }
        return clone
    }
    func flushOperations() {
        self.frontOperation.cancelled = true
        self.backOperation.cancelled = true
        self.frontOperation = RVDSOperation(name: frontOperationName)
        self.backOperation = RVDSOperation(name: backOperationName)
    }
    func reset(callback: @escaping () -> Void) {
        if let manager = self.manager {
            if let tableView = self.scrollView as? UITableView {
                self.flushOperations()
                // Give a break to allow pending operations to terminate
                DispatchQueue.main.async {
                    tableView.beginUpdates()
                    self.array = [RVBaseModel]()
                    self.offset = 0
                    let indexSet = IndexSet(integer: manager.section(datasource: self))
                    tableView.reloadSections(indexSet, with: self.animation)
                    tableView.endUpdates()
                    callback()
                }
            } else if let _ = self.scrollView as? UICollectionView {
                
            } else {
                self.flushOperations()
                DispatchQueue.main.async {
                    self.array = [RVBaseModel]()
                    self.offset = 0
                    callback()
                }

            }
        }
    }
    func start(query: RVQuery, callback: @escaping (_ error: RVError?)-> Void) {
        reset {
            self.baseQuery = query
            self.inBackZone(location: 0)
        }
    }
    func stop(callback: @escaping(_ error: RVError?) -> Void) {
        flushOperations()
        callback(nil)
    }
    func testQuery() {
        let operation = self.backOperation
        if let query = self.baseQuery {
            if !operation.active {
                operation.active = true
                // print("In \(self.instanceType).testQuery() about to do bulkQuery")
                RVTask.bulkQuery(query: query) { (models: [RVBaseModel]?, error: RVError?) in
                    if let error = error {
                        print("In \(self.instanceType).subscribeToTasks, got error")
                        error.printError()
                    } else if let models = models {
                        var index = 0
                        for _ in models {
                            //   print("\(index): \(model.text!)")
                            index = index + 1
                        }
                        if self.backOperation.identifier == operation.identifier {
                            self.appendAtBack(operation: operation, items: models)
                        }
                    } else {
                        print("In \(self.instanceType).subscribeToTasks, no error but no results")
                    }
                }
            }
        }
    }
}
