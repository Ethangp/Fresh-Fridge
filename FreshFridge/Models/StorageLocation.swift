//
//  StorageLocation.swift
//  FreshFridge
//
//  Created on 2025-01-27.
//

import Foundation

enum StorageLocation: String, Codable, CaseIterable {
    case pantry = "Pantry"
    case fridge = "Fridge"
    case freezer = "Freezer"
    case other = "Other"
    
    var displayName: String {
        return self.rawValue
    }
    
    var icon: String {
        switch self {
        case .pantry:
            return "cabinet"
        case .fridge:
            return "refrigerator"
        case .freezer:
            return "snowflake"
        case .other:
            return "archivebox"
        }
    }
}
