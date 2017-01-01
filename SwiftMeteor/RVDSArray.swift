//
//  RVDSArray.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 12/31/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import UIKit

class RVDSArray<T> {
    var instanceType: String { get { return String(describing: type(of: self)) } }
    var maximumArrayLength: Int = 100
    var backBuffer = 30
    var frontBuffer = 30
    var array = Array<T>()
    var scrollView: UIScrollView? = nil
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
    func item(location: Int) -> T? {
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
        if self.backOperation.active { self.backOperation.cancelled = true }
        if !self.frontOperation.active {
            self.frontOperation.active = true
            print("In \(self.instanceType).inFrontZone. location = \(location), offset = \(self.offset), array count = \(self.array.count)\n --- Set Front Operation active")
        }
    }
    func inBackZone(location: Int) {
        print("In \(self.instanceType).inBackZone. location = \(location), offset = \(self.offset), array count = \(self.array.count)")
        if self.frontOperation.active { self.frontOperation.cancelled = true }
        if !self.backOperation.active {
            self.backOperation.active = true
            print("In \(self.instanceType).inBackZone. location = \(location), offset = \(self.offset), array count = \(self.array.count)\n --- Set Back Operation active")
        }
    }
    func removeBack() {
        if let manager = self.manager {
            var clone = cloneData()
            let currentCount = clone.count
            let currentOffset = self.offset
            var indexPaths = [IndexPath]()
            let section = manager.section()
            let excess = currentCount - (self.maximumArrayLength + self.backBuffer)
            if excess > 0 {
                for index in ((self.maximumArrayLength + self.backBuffer)..<currentCount).reversed() {
                    clone.remove(at: index)
                    indexPaths.append(IndexPath(row: currentOffset + index, section: section))
                }
                if let tableView = self.scrollView as? UITableView {
                    tableView.beginUpdates()
                    if self.frontOperation.active && (!self.frontOperation.cancelled) {
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
    func insertAtFront(items: [T]) {
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
                        if self.frontOperation.active && (!self.frontOperation.cancelled) {
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
                            let firstVisiblePath = visiblePaths[0]
                            firstVisibleRow = firstVisiblePath.row
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
                                if self.frontOperation.active && (!self.frontOperation.cancelled) {
                                    self.array = clone
                                    self.offset = currentOffset
                                }
                                tableView.endUpdates()
                            }
                            if start < sizedItems.count {
                                clone = cloneData()
                                var indexPaths = [IndexPath]()
                                currentOffset = self.offset
                                let section = manager.section()
                                if currentOffset == 0 {
                                    for index in (start..<sizedItems.count) {
                                        clone.insert(sizedItems[index], at: 0)
                                        indexPaths.append(IndexPath(row: index-start, section: section))
                                    }
                                    tableView.beginUpdates()
                                    if self.frontOperation.active && (!self.frontOperation.cancelled) {
                                        self.array = clone
                                        tableView.insertRows(at: indexPaths, with: animation)
                                        tableView.endUpdates()
                                    }
                                } else {
                                    print("In \(self.instanceType).insertAtFront, offset is \(self.offset), when should be zero")
                                }
                            }
                            removeBack()
                        }
                    }
                } else if let _ = self.scrollView as? UICollectionView {
                    
                } else {
                    
                }
            }
        }
        self.frontOperation = RVDSOperation()
    }
    func appendAtBack(items: [T]) {
        if let manager = self.manager {
            var sizedItems = maxItems(items: items) // Limits the number of new items to the maximum array size
            if sizedItems.count > 0 {
                /* have array with at least one item and less than or equal to maximumNumberOfItems */
                var clone = cloneData()
                var indexPaths = [IndexPath]()
                let section = manager.section()
                if let tableView = self.scrollView as? UITableView {
                    var start = 0
                    var currentOffset = self.offset
                    let room = self.maximumArrayLength - self.array.count
                    if room > 0 {
                        var end = room
                        // If number of new items less than room, set end to number of new Items, else use all the room
                        if sizedItems.count < end { end = sizedItems.count }
                        for index in (0..<end) {
                            clone.append(sizedItems[index])
                            indexPaths.append(IndexPath(row: (currentOffset + clone.count - 1), section: section))
                            start = start + 1
                        }
                        tableView.beginUpdates()
                        if self.backOperation.active && (!self.backOperation.cancelled) {
                            self.array = clone
                            tableView.insertRows(at: indexPaths, with: animation)
                            clone = cloneData()
                            indexPaths = [IndexPath]()
                        }
                        tableView.endUpdates()
                    }
                    var lastVisibleRow = 0
                    if let visiblePaths = tableView.indexPathsForVisibleRows {
                        let lastVisiblePath = visiblePaths[visiblePaths.count - 1]
                        lastVisibleRow = lastVisiblePath.row
                    }
                    let lastVirtualRow = self.virtualCount
                    if lastVisibleRow > (lastVirtualRow - self.backBuffer) {
                        currentOffset = self.offset
                        if start < sizedItems.count {
                            for index in (start..<sizedItems.count) {
                                clone.append(sizedItems[index])
                                indexPaths.append(IndexPath(row: currentOffset + clone.count - 1, section: section))
                            }
                            var cloneOffset = 0
                            (clone, cloneOffset) = adjustArray(items: clone)
                            tableView.beginUpdates()
                            if self.backOperation.active && (!self.backOperation.cancelled) {
                                self.array = clone
                                self.offset = self.offset + cloneOffset
                                tableView.insertRows(at: indexPaths, with: animation)
                            }
                            tableView.endUpdates()
                        }
                    }

                } else if let _ = self.scrollView as? UICollectionView {
                    
                } else {
                    
                }
            }
        }
        self.backOperation = RVDSOperation()
    }
    func adjustArray(items: [T]) -> ([T], Int) {
        var offset = 0
        if array.count > self.maximumArrayLength + self.backBuffer {
            var clone = [T]()
            for index in ((items.count-(self.maximumArrayLength+self.backBuffer))..<items.count) {
                clone.append(items[index])
                offset = offset + 1
            }
            return (array, offset)
        } else {
            return (array, offset)
        }
    }
    func maxItems(items: [T], front: Bool = true) -> Array<T>{
        var maxItems = Array<T>()
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
    
    func cloneData() -> Array<T> {
        var clone = Array<T>()
        for item in self.array {
            clone.append(item)
        }
        return clone
    }
    func notifyViewOfFrontInsert() {
        
    }
    func notifyViewOfBackAppend() {
        
    }
    func notifyViewOfBackRemove() {
        
    }
}
