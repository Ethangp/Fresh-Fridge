//
//  DateExtensions.swift
//  FreshFridge
//
//  Created on 2025-01-27.
//

import Foundation

extension Date {
    func days(from date: Date) -> Int {
        Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    
    func days(fromNow: Bool = true) -> Int {
        if fromNow {
            return Calendar.current.dateComponents([.day], from: Date(), to: self).day ?? 0
        } else {
            return Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
        }
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(self)
    }
    
    var relativeDateString: String {
        if isToday {
            return "Today"
        } else if isTomorrow {
            return "Tomorrow"
        } else {
            let days = days(fromNow: true)
            if days > 0 {
                return "In \(days) days"
            } else if days == 0 {
                return "Today"
            } else {
                return "\(abs(days)) days ago"
            }
        }
    }
}
