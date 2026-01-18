//
//  HomeViewModel.swift
//  FreshFridge
//
//  Created on 2025-01-27.
//

import Foundation
import SwiftData

@Observable
class HomeViewModel {
    var searchText: String = ""
    var selectedLocation: StorageLocation? = nil
    var showExpired: Bool = false
    var sortAscending: Bool = true
    
    func groupedItems(from items: [FoodItem]) -> [UrgencyCategory: [FoodItem]] {
        var grouped: [UrgencyCategory: [FoodItem]] = [:]
        
        let filtered = filterItems(items)
        let sorted = sortItems(filtered)
        
        for item in sorted {
            let category = item.urgencyCategory
            if category == .expired && !showExpired {
                continue
            }
            
            if grouped[category] == nil {
                grouped[category] = []
            }
            grouped[category]?.append(item)
        }
        
        return grouped
    }
    
    private func filterItems(_ items: [FoodItem]) -> [FoodItem] {
        var filtered = items
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { item in
                item.name.localizedCaseInsensitiveContains(searchText) ||
                (item.brand?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        // Filter by location
        if let location = selectedLocation {
            filtered = filtered.filter { $0.storageLocation == location }
        }
        
        return filtered
    }
    
    private func sortItems(_ items: [FoodItem]) -> [FoodItem] {
        return items.sorted { item1, item2 in
            if sortAscending {
                return item1.expirationDate < item2.expirationDate
            } else {
                return item1.expirationDate > item2.expirationDate
            }
        }
    }
    
    var urgencyOrder: [UrgencyCategory] {
        [
            .useToday,
            .next3Days,
            .thisWeek,
            .expiringSoon,
            .later,
            .expired
        ]
    }
}
