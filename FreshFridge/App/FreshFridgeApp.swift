//
//  FreshFridgeApp.swift
//  FreshFridge
//
//  Created on 2025-01-27.
//

import SwiftUI
import SwiftData

@main
struct FreshFridgeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: FoodItem.self)
    }
}
