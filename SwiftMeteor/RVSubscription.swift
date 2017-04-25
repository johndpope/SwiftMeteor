//
//  RVSubscription.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/31/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
protocol RVSubscription: class {
    var notificationName: Notification.Name { get }
    var unsubscribeNotificationName: Notification.Name { get }
    var active: Bool { get }
    var collection: RVModelType { get }
    var showResponse: Bool { get }
    var isFront: Bool { get }
    var identifier: TimeInterval { get }
    var reference: RVBaseModel? { get set }
    var ignore: Bool { get }
    func subscribe(query: RVQuery, reference: RVBaseModel?, callback: @escaping() -> Void) -> Void
    func unsubscribe(callback: @escaping ()-> Void) -> Void
    func unsubscribe() -> Void
//    func unsubscribe() -> Void
}
