//
//  FIFOService.swift
//  FreshFridge
//
//  Created on 2025-01-27.
//

import Foundation
import SwiftData

class FIFOService {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    /// Consumes one item, applying FIFO logic (oldest batch first)
    func consumeOne(itemName: String) throws {
        let descriptor = FetchDescriptor<FoodItem>(
            predicate: #Predicate<FoodItem> { item in
                item.name == itemName && item.quantity > 0
            },
            sortBy: [SortDescriptor(\.dateAdded, order: .forward)]
        )
        
        let items = try modelContext.fetch(descriptor)
        
        guard let oldestItem = items.first else {
            throw FIFOError.itemNotFound
        }
        
        if oldestItem.quantity > 1 {
            oldestItem.quantity -= 1
        } else {
            // Quantity reaches 0, mark for deletion
            modelContext.delete(oldestItem)
        }
        
        try modelContext.save()
    }
    
    /// Consumes a specific quantity of an item
    func consume(itemName: String, quantity: Int) throws {
        var remaining = quantity
        
        while remaining > 0 {
            let descriptor = FetchDescriptor<FoodItem>(
                predicate: #Predicate<FoodItem> { item in
                    item.name == itemName && item.quantity > 0
                },
                sortBy: [SortDescriptor(\.dateAdded, order: .forward)]
            )
            
            let items = try modelContext.fetch(descriptor)
            
            guard let oldestItem = items.first else {
                throw FIFOError.itemNotFound
            }
            
            if oldestItem.quantity <= remaining {
                remaining -= oldestItem.quantity
                modelContext.delete(oldestItem)
            } else {
                oldestItem.quantity -= remaining
                remaining = 0
            }
        }
        
        try modelContext.save()
    }
}

enum FIFOError: Error {
    case itemNotFound
    case insufficientQuantity
}
