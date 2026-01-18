//
//  UrgencySection.swift
//  FreshFridge
//
//  Created on 2025-01-27.
//

import SwiftUI

struct UrgencySection: View {
    let category: UrgencyCategory
    let items: [FoodItem]
    let onItemTap: (FoodItem) -> Void
    let onConsume: (FoodItem) -> Void
    let onDelete: (FoodItem) -> Void
    
    var body: some View {
        if !items.isEmpty {
            Section {
                ForEach(items) { item in
                    ItemRowView(
                        item: item,
                        onConsume: { onConsume(item) },
                        onDelete: { onDelete(item) }
                    )
                    .onTapGesture {
                        onItemTap(item)
                    }
                }
            } header: {
                Text(category.rawValue)
            }
        }
    }
}

#Preview {
    List {
        UrgencySection(
            category: .next3Days,
            items: [],
            onItemTap: { _ in },
            onConsume: { _ in },
            onDelete: { _ in }
        )
    }
}
