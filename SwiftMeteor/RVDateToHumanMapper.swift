//
//  RVDateToHumanMapper.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 2/4/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
class RVDateToHumanMapper {
    static let shared: RVDateToHumanMapper = {
        RVDateToHumanMapper()
    }()
    func withinPastWeek(date: Date, calendar: Calendar, flags: Set<Calendar.Component>) -> String {
        let components = calendar.dateComponents(flags, from: date)
        if let hour = components.hour {
            let hourString = (hour > 12) ? "\(hour - 12)" : "\(hour)"
            if let minutes = components.minute {
                let amPM = hour > 12 ? " am" : " pm"
                // let timeZone = components.timeZone != nil ? components.timeZone!.description ""
                return " at: " + hourString.description + ":" + minutes.description + amPM // + " " + timeZone
            }
        }
        return ""
    }
    func beyondPastWeek(date: Date, calendar: Calendar, flags: Set<Calendar.Component>) -> String {
        let components = calendar.dateComponents(flags, from: date)
        if let month = components.month {
            if let day = components.day {
                return " \(month)-\(day) " + withinPastWeek(date: date, calendar: calendar, flags: flags)
            }
        }
        if let hour = components.hour {
            let hourString = (hour > 12) ? "\(hour - 12)" : "\(hour)"
            if let minutes = components.minute {
                let amPM = hour > 12 ? " am" : " pm"
                return " at: " + hourString.description + ":" + minutes.description + amPM
            }
        }
        return ""
    }
    func timeAgoSinceDate(date:Date, numericDates:Bool) -> String {
        let calendar = NSCalendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second, .timeZone]
        let now = NSDate()
        let earliest = now.earlierDate(date as Date)
        let latest = (earliest == now as Date) ? date : now as Date
        let components = calendar.dateComponents(unitFlags, from: earliest as Date,  to: latest as Date)

        
        if (components.year! >= 2) {
            return "\(components.year!) years ago"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1 year ago"
            } else {
                return "Last year" + beyondPastWeek(date: date, calendar: calendar, flags: unitFlags)
            }
        } else if (components.month! >= 2) {
            return "\(components.month!) months ago" + beyondPastWeek(date: date, calendar: calendar, flags: unitFlags)
        } else if (components.month! >= 1){
            if (numericDates){
                return "1 month ago" + beyondPastWeek(date: date, calendar: calendar, flags: unitFlags)
            } else {
                return "Last month" + beyondPastWeek(date: date, calendar: calendar, flags: unitFlags)
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!) weeks ago" + beyondPastWeek(date: date, calendar: calendar, flags: unitFlags)
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return "1 week ago"
            } else {
                return "Last week" + beyondPastWeek(date: date, calendar: calendar, flags: unitFlags)
            }
        } else if (components.day! >= 2) {
            return "\(components.day!) days ago" + withinPastWeek(date: date, calendar: calendar, flags: unitFlags)
        } else if (components.day! >= 1){
            if (numericDates){
                return "1 day ago"
            } else {
                return "Yesterday" + withinPastWeek(date: date, calendar: calendar, flags: unitFlags)
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour!) hours ago"
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1 hour ago"
            } else {
                return "An hour ago"
            }
        } else if (components.minute! >= 2) {
            return "\(components.minute!) minutes ago"
        } else if (components.minute! >= 1){
            if (numericDates){
                return "1 minute ago"
            } else {
                return "A minute ago"
            }
        } else if (components.second! >= 3) {
            return "\(components.second!) seconds ago"
        } else {
            return "Just now"
        }
        
    }
}
