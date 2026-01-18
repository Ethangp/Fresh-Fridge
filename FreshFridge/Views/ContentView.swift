//
//  ContentView.swift
//  FreshFridge
//
//  Created on 2025-01-27.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        HomeView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: FoodItem.self, inMemory: true)
}
