//
//  ItemRowView.swift
//  FreshFridge
//
//  Created on 2025-01-27.
//

import SwiftUI
import SwiftData

struct ItemRowView: View {
    let item: FoodItem
    let onConsume: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Storage location icon
            Image(systemName: item.storageLocation.icon)
                .foregroundColor(.secondary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                
                HStack(spacing: 8) {
                    if let brand = item.brand {
                        Text(brand)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if item.quantity > 1 {
                        Text("(\(item.quantity))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Text(item.expirationDate.relativeDateString)
                    .font(.caption)
                    .foregroundColor(urgencyColor)
            }
            
            Spacer()
            
            // Urgency indicator
            Circle()
                .fill(urgencyColor)
                .frame(width: 8, height: 8)
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
            
            Button {
                onConsume()
            } label: {
                Label("Consume", systemImage: "checkmark")
            }
            .tint(.green)
        }
    }
    
    private var urgencyColor: Color {
        switch item.urgencyCategory {
        case .useToday, .expired:
            return .red
        case .next3Days:
            return .orange
        case .thisWeek:
            return .yellow
        case .expiringSoon:
            return .blue
        case .later:
            return .green
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: FoodItem.self, configurations: config)
    
    let item = FoodItem(
        name: "Spinach",
        expirationDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date(),
        quantity: 1,
        storageLocation: .fridge
    )
    
    return ItemRowView(item: item, onConsume: {}, onDelete: {})
        .modelContainer(container)
}
