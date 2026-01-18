//
//  Constants.swift
//  FreshFridge
//
//  Created on 2025-01-27.
//

import Foundation

struct Constants {
    // Notification timing (days before expiration)
    static let produceNotificationDays = 1...2
    static let fridgeNotificationDays = 2...3
    static let pantryNotificationDays = 14...30
    static let freezerNotificationDays = 30...30
    
    // Max notifications per day
    static let maxNotificationsPerDay = 1
    
    // Default shelf life suggestions (days)
    static let defaultShelfLife: [String: Int] = [
        "Bananas": 5,
        "Spinach": 5,
        "Chicken Breast": 3,
        "Milk": 7,
        "Bread": 7,
        "Eggs": 21,
        "Yogurt": 14,
        "Cheese": 14,
        "Apples": 30,
        "Carrots": 14
    ]
    
    // Common produce templates
    static let produceTemplates = [
        "Bananas", "Spinach", "Lettuce", "Tomatoes", "Carrots",
        "Broccoli", "Apples", "Oranges", "Strawberries", "Blueberries",
        "Chicken Breast", "Ground Beef", "Salmon", "Milk", "Eggs",
        "Yogurt", "Cheese", "Bread", "Butter"
    ]
}
