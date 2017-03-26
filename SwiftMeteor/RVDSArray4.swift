//
//  RVDSArray4.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/26/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
class RVDSArray4 {
    enum CollapseMode {
        case notCollapsed
        case collapsed
        case collapsedWithZeroEntry
    }
    var array = [AnyObject]()
    var zeroItem: AnyObject? = nil
    var offset: Int = 0
    var collapsed: CollapseMode = .notCollapsed
    var count: Int {
        get {
            if collapsed == .collapsed { return 0 }
            if collapsed == .collapsedWithZeroEntry { return (zeroItem == nil) ? 0 : 1 }
            if array.count > 0 { return offset + array.count + 1}
            else {return (zeroItem == nil) ? 0 : 1 }
        }
    }
    func empty() {
        self.array = [AnyObject]()
        self.zeroItem = nil
        self.offset = 0
    }
    func append(items: [AnyObject]) {
        if items.count == 0 { return }
        var start: Int = 0
        if (zeroItem == nil) {
            zeroItem = items[0]
            start = 1
            if items.count == 1 { return }
        }
        var clone = self.clone()
        for i in start..<items.count { clone.append(items[i]) }
        self.array = clone
    }
    func insertAtFront(items: [AnyObject]) {
        var clone = self.clone()
        let count = items.count
        if offset == 0 {
            for i in 0..<count { clone.insert(items[count-i], at: 0) }
        } else {
            for i in 0..<count {
                clone.insert(items[count-i], at: 0)
                if offset > 0 { offset = offset - 1 }
            }
        }
    }
    func clone() -> [AnyObject] {
        var clone = [AnyObject]()
        if array.count == 0 { return clone }
        for i in 0..<array.count { clone.append(array[i]) }
        return clone
    }
    func item(index: Int) -> AnyObject? {
        if collapsed == .collapsed { return nil }
        if collapsed == .collapsedWithZeroEntry { return zeroItem }
        let physicalIndex = array.count - offset
        if physicalIndex < 0 {
            return nil
        } else if physicalIndex == 0 {
            return zeroItem
        } else if (physicalIndex - 1) >= array.count {
            print("ERROR ....... In RVDSArray.item, physicalIndex greater than arrayCount: \(physicalIndex), for sourceIndex: \(index) and offset: \(offset) and arrayCount: \(array.count)")
            return nil
        } else {
            return array[physicalIndex - 1]
        }
    }

    func removeFromBack(maxArraySize: Int) {
        if maxArraySize < 0 {
            print("In RVDSArray4.removeFrombank, sent negative maxArraySize. \(maxArraySize)")
            return
        } else if (maxArraySize == 0) {
            self.empty()
            return
        } else if (maxArraySize == 1) {
            self.array = [AnyObject]()
        } else if (maxArraySize >= (array.count + 1)) {
            return
        } else {
            var clone = [AnyObject]()
            for i in 0..<(maxArraySize-1) {
                clone.append(self.array[i])
            }
            self.array = clone
        }
    }
}
