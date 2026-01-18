//
//  AddItemViewModel.swift
//  FreshFridge
//
//  Created on 2025-01-27.
//

import Foundation
import SwiftData

@Observable
class AddItemViewModel {
    var name: String = ""
    var brand: String = ""
    var category: String = ""
    var expirationDate: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    var quantity: Int = 1
    var storageLocation: StorageLocation = .fridge
    var photoData: Data? = nil
    
    func reset() {
        name = ""
        brand = ""
        category = ""
        expirationDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        quantity = 1
        storageLocation = .fridge
        photoData = nil
    }
    
    func applyTemplate(_ templateName: String) {
        name = templateName
        if let defaultDays = Constants.defaultShelfLife[templateName] {
            expirationDate = Calendar.current.date(byAdding: .day, value: defaultDays, to: Date()) ?? Date()
        }
        
        // Set default location based on category
        if Constants.produceTemplates.contains(templateName) {
            storageLocation = .fridge
        }
    }
    
    func createFoodItem() -> FoodItem {
        return FoodItem(
            name: name,
            brand: brand.isEmpty ? nil : brand,
            category: category.isEmpty ? nil : category,
            expirationDate: expirationDate,
            quantity: quantity,
            storageLocation: storageLocation,
            photoData: photoData
        )
    }
}
