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
    var maximumArrayLength: Int = 100
    var backBuffer = 20
    var frontBuffer = 20
    var frontTimer: Bool = false
    var backTimer: Bool = false
    var array = [RVBaseModel]()
    var baseQuery: RVQuery? = nil
    let identifier = NSDate().timeIntervalSince1970
    weak var scrollView: UIScrollView? = nil
    var backOperation: RVDSOperation = RVDSOperation()
    var frontOperation: RVDSOperation = RVDSOperation()
    weak var manager: RVDSManager? = nil
    var animation: UITableViewRowAnimation = UITableViewRowAnimation.automatic
    private var offset: Int = 0
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
    init(scrollView: UIScrollView?, manager: RVDSManager) {
        self.scrollView = scrollView
        self.manager = manager
    }
    func testQuery() {
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
                        for model in models {
                            print("\(index): \(model.text!)")
                            index = index + 1
                        }
                        if self.backOperation.identifier == operation.identifier {
                            self.appendAtBack(items: models)
                        }
                    } else {
                        print("In \(self.instanceType).subscribeToTasks, no error but no results")
                    }
                }
            }
        }
    }
    func start() {
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
                                for model in models {
                                    print("\(index): \(model.text!)")
                                    index = index + 1
                                }
                                if self.backOperation.identifier == operation.identifier {
                                    self.appendAtBack(items: models)
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
    func queryForBack(callback: @escaping(_ error: RVError?) -> Void) {
        if let query = self.baseQuery {
            let operation = self.backOperation

                if self.array.count == 0 {
                    queryForBackHelper(query: query, operation: operation, callback: callback)
                } else {
                    let query = query.duplicate()
                    if let last = self.array.last {
                        switch(query.sortTerm) {
                        case .createdAt:
                            if let lastCreatedAt = last.createdAt {
                                if let queryTerm = query.findAndTerm(term: .createdAt) {
                                    queryTerm.value = EJSON.convertToEJSONDate(lastCreatedAt) as AnyObject
                                    if queryTerm.comparison == .lte { queryTerm.comparison = .lt}
                                    else if queryTerm.comparison == .gte { queryTerm.comparison = .gt}
                                }
                            }
                        default:
                            print("In \(self.instanceType).queryForBack, have unserviced sortTerm: \(query.sortTerm.rawValue)")
                        }
                        queryForBackHelper(query: query, operation: operation, callback: callback)
                        return
                    } else {
                        let rvError = RVError(message: "In \(self.instanceType).queryForBack, last item")
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
        RVTask.bulkQuery(query: query) { (models: [RVBaseModel]?, error: RVError?) in
            if let error = error {
                print("In \(self.instanceType).subscribeToTasks, got error")
                error.printError()
            } else if let models = models {
                var index = 0
                for model in models {
                    print("\(index): \(model.text!), \(model.createdAt)")
                    index = index + 1
                }
                if self.backOperation.identifier == operation.identifier {
                    self.appendAtBack(items: models)
                }
            } else {
                print("In \(self.instanceType).subscribeToTasks, no error but no results")
            }
        }
    }
    func item(location: Int) -> RVBaseModel? {
    //    print("In \(self.instanceType).item, with location: \(location)")
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
            }
        } else {
            print("In \(self.instanceType).item. Location is less than zero. location = \(location), offset = \(self.offset), array count: \(self.array.count)")
        }
        return nil
    }
    func inFrontZone(location: Int) {
        print("In \(self.instanceType).inFrontZone. location = \(location), offset = \(self.offset), array count = \(self.array.count)")
        if frontTimer { return }
        frontTimer = true
        if self.backOperation.active {
            self.backOperation.cancelled = true
            self.backOperation = RVDSOperation()
        }
        let operation = self.frontOperation
        if !operation.active {
            operation.active = true
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (timer: Timer) in
                if let tableView = self.scrollView as? UITableView {
                    var firstVisibleRow = 0
                    if let visiblePaths = tableView.indexPathsForVisibleRows {
                        if visiblePaths.count > 0 {
                            let firstVisiblePath = visiblePaths[0]
                            firstVisibleRow = firstVisiblePath.row
                        }
                    }
                    if firstVisibleRow < self.frontBuffer{
                        if operation.identifier == self.frontOperation.identifier {
                            print("In \(self.instanceType).inFrontZone. location = \(location), offset = \(self.offset), array count = \(self.array.count) --- Set Front Operation active")
                        }
                    }
                }
                if operation.identifier == self.frontOperation.identifier {
                    self.frontOperation = RVDSOperation() // NEIL REMOVE THIS IS A PLUG
                }
                self.frontTimer = false
            })
        } else {
            frontTimer = false
        }
    }
    func inBackZone(location: Int) {
       // print("In \(self.instanceType).inBackZone. location = \(location), offset = \(self.offset), array count = \(self.array.count)")
        if backTimer { return }
        backTimer = true
        if self.frontOperation.active {
            self.frontOperation.cancelled = true
            self.frontOperation = RVDSOperation()
        }
     //   print("So far")
        let operation = self.backOperation
        if !operation.active {
            operation.active = true
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (timer: Timer) in
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
                            print("About to call queryForBack. LastVisibleRow is: \(lastVisibleRow) arraycount is: \(self.array.count)")
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
            print("Back operation active")
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
    func insertAtFront(items: [RVBaseModel]) {
        let operation = self.frontOperation
        if let manager = self.manager {
            var sizedItems = maxItems(items: items) // Limits the number of new items to the maximum array size
            if sizedItems.count > 0 {
                var clone = cloneData()
                //var currentCount = clone.count
                let room = clone.count - self.maximumArrayLength
                var currentOffset = self.offset
                var start = 0
                if let tableView = self.scrollView as? UITableView {
                    if (offset > 0) && (room > 0) {
                        // Have room in array to reduce the offset without affecting TableView
                        var end = room
                        if room > clone.count { end = clone.count }
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
                        if firstVisibleRow < self.frontBuffer {
                            // at front of TableView, new items to add at front number more than 0 and less than maxArrayLength
                            clone = cloneData()
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
                                clone = cloneData()
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
                                        tableView.insertRows(at: indexPaths, with: animation)

                                    }
                                    tableView.endUpdates()
                                } else {
                                    print("In \(self.instanceType).insertAtFront, offset is \(self.offset), when should be zero")
                                }
                            }
                            removeBack(operation: operation)
                        }
                    }
                } else if let _ = self.scrollView as? UICollectionView {
                    
                } else {
                    
                }
            }
        }
        if self.frontOperation.identifier == operation.identifier {
            self.frontOperation = RVDSOperation()
        }
    }
    func appendAtBack(items: [RVBaseModel]) {
        let operation = self.backOperation
        if let manager = self.manager {
            var sizedItems = maxItems(items: items) // Limits the number of new items to the maximum array size
            if sizedItems.count > 0 {
                print("In \(self.instanceType).appendAtBack, have \(sizedItems.count) items")
                /* have array with at least one item and less than or equal to maximumNumberOfItems */
                var clone = cloneData()
                var indexPaths = [IndexPath]()
                let section = manager.section(datasource: self)
                if let tableView = self.scrollView as? UITableView {
                    var start = 0
                    var currentOffset = self.offset
                    let room = self.maximumArrayLength - self.array.count
                    if room > 0 {
                        var end = room
                        // If number of new items less than room, set end to number of new Items, else use all the room
                        if sizedItems.count < end { end = sizedItems.count }
                        print("In \(self.instanceType).appendAtBack, adding \(end) items in first add to fill array")
                        for index in (0..<end) {
                            clone.append(sizedItems[index])
                   //         print("In \(self.instanceType).appendAtBack, adding section: \(section), row: \(currentOffset + clone.count - 1)")
                            indexPaths.append(IndexPath(row: (currentOffset + clone.count - 1), section: section))
                            start = start + 1
                        }
                        tableView.beginUpdates()
                        if (operation.identifier == self.backOperation.identifier) && (!operation.cancelled) {
                           // print("In \(self.instanceType).appendAtBack, doing insertOperation with cloneCount = \(clone.count), indexPaths count = \(indexPaths.count)")
                            self.array = clone
                            tableView.insertRows(at: indexPaths, with: animation)
                        }
                      //  print("In \(self.instanceType).appendAtBack, after insertOperation just before endUpdates()")
                        tableView.endUpdates()
                        print("In \(self.instanceType).appendAtBack, after insertOperation")
                    }
                    
                    var lastVisibleRow = 0
                    if let visiblePaths = tableView.indexPathsForVisibleRows {
                        if visiblePaths.count > 0 {
                            let lastVisiblePath = visiblePaths[visiblePaths.count - 1]
                            lastVisibleRow = lastVisiblePath.row
                        }
                    }
           //         print("In \(self.instanceType).appendAtBack, array Count is: \(self.array.count), start is: \(start)")
                    clone = cloneData()
                    indexPaths = [IndexPath]()
          //          let lastVirtualRow = self.virtualCount
          //          if lastVisibleRow > (lastVirtualRow - self.backBuffer) {
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
                            (clone2, cloneOffset) = adjustArray(items: clone)
                            tableView.beginUpdates()
                            if (operation.identifier == self.backOperation.identifier) && (!operation.cancelled) {
                                self.array = clone2
                              //  print("In \(self.instanceType).appendAtBack array count is \(self.array.count), currentOffset = \(currentOffset), cloneOffset = \(cloneOffset)")
                                self.offset = currentOffset + cloneOffset
                                tableView.insertRows(at: indexPaths, with: animation)
                            }
                            tableView.endUpdates()
                          //  print("In \(self.instanceType).appendAtBack, after second insertOperation arrayCount = \(self.array.count), offset = \(self.offset)")
                        }
            //        }
                  //  print("In \(self.instanceType).appendAtBack, array Count is: \(self.array.count)")
 

                } else if let _ = self.scrollView as? UICollectionView {
                    
                } else {
                    
                }
            }
        }
        if self.backOperation.identifier == operation.identifier {
            self.backOperation = RVDSOperation()
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
    func reset(callback: () -> Void) {
        if let manager = self.manager {
            if let tableView = self.scrollView as? UITableView {
                tableView.beginUpdates()
                self.frontOperation.cancelled = true
                self.backOperation.cancelled = true
                self.frontOperation = RVDSOperation()
                self.backOperation = RVDSOperation()
                self.array = [RVBaseModel]()
                self.offset = 0
                let indexSet = IndexSet(integer: manager.section(datasource: self))
                tableView.reloadSections(indexSet, with: animation)
                tableView.endUpdates()
                callback()
            } else if let _ = self.scrollView as? UICollectionView {
                
            } else {
                self.frontOperation.cancelled = true
                self.backOperation.cancelled = true
                self.frontOperation = RVDSOperation()
                self.backOperation = RVDSOperation()
                self.array = [RVBaseModel]()
                self.offset = 0
                callback()
            }
        }

    }
}
