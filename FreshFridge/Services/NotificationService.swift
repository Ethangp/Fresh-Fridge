//
//  NotificationService.swift
//  FreshFridge
//
//  Created on 2025-01-27.
//

import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    
    private init() {}
    
    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("Failed to request notification authorization: \(error)")
            return false
        }
    }
    
    func scheduleNotification(for item: FoodItem) {
        let daysBefore = notificationDaysBefore(for: item)
        
        guard daysBefore > 0 else {
            // Don't schedule if expiration is today or past
            if item.daysUntilExpiration == 0 {
                scheduleSameDayNotification(for: item)
            }
            return
        }
        
        let notificationDate = Calendar.current.date(byAdding: .day, value: -daysBefore, to: item.expirationDate) ?? item.expirationDate
        
        // Don't schedule if the notification date is in the past
        guard notificationDate > Date() else {
            if item.daysUntilExpiration == 0 {
                scheduleSameDayNotification(for: item)
            }
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = item.name
        content.body = notificationBody(for: item, daysBefore: daysBefore)
        content.sound = .default
        content.userInfo = ["itemId": item.id.uuidString]
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: item.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }
    
    func cancelNotification(for item: FoodItem) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [item.id.uuidString])
    }
    
    private func notificationDaysBefore(for item: FoodItem) -> Int {
        // Determine notification timing based on category and location
        if let category = item.category?.lowercased() {
            if category.contains("produce") || category.contains("fruit") || category.contains("vegetable") {
                return Constants.produceNotificationDays.upperBound
            }
        }
        
        switch item.storageLocation {
        case .fridge:
            return Constants.fridgeNotificationDays.upperBound
        case .pantry:
            return Constants.pantryNotificationDays.lowerBound
        case .freezer:
            return Constants.freezerNotificationDays.lowerBound
        case .other:
            return Constants.fridgeNotificationDays.upperBound
        }
    }
    
    private func notificationBody(for item: FoodItem, daysBefore: Int) -> String {
        if daysBefore == 0 {
            return "expires today"
        } else if daysBefore == 1 {
            return "expires tomorrow"
        } else {
            return "expires in \(daysBefore) days"
        }
    }
    
    private func scheduleSameDayNotification(for item: FoodItem) {
        let content = UNMutableNotificationContent()
        content.title = item.name
        content.body = "expires today"
        content.sound = .default
        content.userInfo = ["itemId": item.id.uuidString]
        
        // Schedule for 9 AM today if not past, otherwise schedule immediately
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        if let notificationDate = Calendar.current.date(from: dateComponents),
           notificationDate > Date() {
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(
                identifier: item.id.uuidString,
                content: content,
                trigger: trigger
            )
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

extension ClosedRange {
    var upperBound: Bound {
        return self.upperBound
    }
}
