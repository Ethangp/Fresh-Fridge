//
//  FoodItem.swift
//  FreshFridge
//
//  Created on 2025-01-27.
//

import Foundation
import SwiftData

@Model
final class FoodItem: Identifiable {
    var id: UUID
    var name: String
    var brand: String?
    var category: String?
    var expirationDate: Date
    var quantity: Int
    var storageLocationRaw: String
    var dateAdded: Date
    var batchId: UUID
    var photoData: Data?
    
    var storageLocation: StorageLocation {
        get {
            StorageLocation(rawValue: storageLocationRaw) ?? .other
        }
        set {
            storageLocationRaw = newValue.rawValue
        }
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        brand: String? = nil,
        category: String? = nil,
        expirationDate: Date,
        quantity: Int = 1,
        storageLocation: StorageLocation = .fridge,
        dateAdded: Date = Date(),
        batchId: UUID = UUID(),
        photoData: Data? = nil
    ) {
        self.id = id
        self.name = name
        self.brand = brand
        self.category = category
        self.expirationDate = expirationDate
        self.quantity = quantity
        self.storageLocationRaw = storageLocation.rawValue
        self.dateAdded = dateAdded
        self.batchId = batchId
        self.photoData = photoData
    }
    
    var isExpired: Bool {
        Calendar.current.isDateInPast(expirationDate)
    }
    
    var daysUntilExpiration: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0
    }
    
    var urgencyCategory: UrgencyCategory {
        if isExpired {
            return .expired
        }
        
        let days = daysUntilExpiration
        
        if days == 0 {
            return .useToday
        } else if days <= 3 {
            return .next3Days
        } else if days <= 7 {
            return .thisWeek
        } else if days <= 14 {
            return .expiringSoon
        } else {
            return .later
        }
    }
}

enum UrgencyCategory: String, CaseIterable {
    case useToday = "Use Today"
    case next3Days = "Next 3 Days"
    case thisWeek = "This Week"
    case expiringSoon = "Expiring Soon"
    case later = "Later"
    case expired = "Expired"
    
    var sortOrder: Int {
        switch self {
        case .useToday: return 0
        case .next3Days: return 1
        case .thisWeek: return 2
        case .expiringSoon: return 3
        case .later: return 4
        case .expired: return 5
        }
    }
}

extension Calendar {
    func isDateInPast(_ date: Date) -> Bool {
        return date < startOfDay(for: Date())
    }
}
