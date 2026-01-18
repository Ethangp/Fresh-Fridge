//
//  ItemDetailView.swift
//  FreshFridge
//
//  Created on 2025-01-27.
//

import SwiftUI
import SwiftData
import UIKit

struct ItemDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let item: FoodItem
    @State private var showingDeleteConfirmation = false
    @State private var showingEditExpiration = false
    @State private var showingEditLocation = false
    @State private var editedExpirationDate: Date
    @State private var editedLocation: StorageLocation
    
    init(item: FoodItem) {
        self.item = item
        _editedExpirationDate = State(initialValue: item.expirationDate)
        _editedLocation = State(initialValue: item.storageLocation)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Item Information") {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(item.name)
                            .foregroundColor(.secondary)
                    }
                    
                    if let brand = item.brand {
                        HStack {
                            Text("Brand")
                            Spacer()
                            Text(brand)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let category = item.category {
                        HStack {
                            Text("Category")
                            Spacer()
                            Text(category)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Text("Quantity")
                        Spacer()
                        Text("\(item.quantity)")
                            .foregroundColor(.secondary)
                    }
                }
                
                if let photoData = item.photoData,
                   let uiImage = UIImage(data: photoData) {
                    Section("Photo") {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .cornerRadius(8)
                    }
                }
                
                Section("Storage & Expiration") {
                    HStack {
                        Text("Storage Location")
                        Spacer()
                        HStack {
                            Image(systemName: item.storageLocation.icon)
                            Text(item.storageLocation.displayName)
                        }
                        .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Expiration Date")
                        Spacer()
                        Text(item.expirationDate, style: .date)
                            .foregroundColor(urgencyColor)
                    }
                    
                    HStack {
                        Text("Status")
                        Spacer()
                        Text(item.expirationDate.relativeDateString)
                            .foregroundColor(urgencyColor)
                            .fontWeight(.medium)
                    }
                }
                
                Section("Actions") {
                    Button {
                        consumeItem()
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Consume 1")
                        }
                        .foregroundColor(.green)
                    }
                    
                    Button {
                        showingEditExpiration = true
                    } label: {
                        HStack {
                            Image(systemName: "calendar")
                            Text("Edit Expiration Date")
                        }
                    }
                    
                    Button {
                        showingEditLocation = true
                    } label: {
                        HStack {
                            Image(systemName: "arrow.triangle.swap")
                            Text("Change Location")
                        }
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Item")
                        }
                    }
                }
            }
            .navigationTitle(item.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingEditExpiration) {
                EditExpirationView(
                    expirationDate: $editedExpirationDate,
                    onSave: {
                        item.expirationDate = editedExpirationDate
                        try? modelContext.save()
                        NotificationService.shared.cancelNotification(for: item)
                        NotificationService.shared.scheduleNotification(for: item)
                        HapticFeedback.light()
                        showingEditExpiration = false
                    }
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingEditLocation) {
                EditLocationView(
                    location: $editedLocation,
                    onSave: {
                        item.storageLocation = editedLocation
                        try? modelContext.save()
                        HapticFeedback.light()
                        showingEditLocation = false
                    }
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
            .confirmationDialog(
                "Delete Item",
                isPresented: $showingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    deleteItem()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete \(item.name)?")
            }
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
    
    private func consumeItem() {
        do {
            let service = FIFOService(modelContext: modelContext)
            try service.consumeOne(itemName: item.name)
            HapticFeedback.success()
            
            // Check if item still exists
            let descriptor = FetchDescriptor<FoodItem>(
                predicate: #Predicate { $0.id == item.id }
            )
            
            if try modelContext.fetch(descriptor).isEmpty {
                // Item was deleted (quantity reached 0)
                dismiss()
            } else {
                // Item still exists, refresh view
                try? modelContext.save()
            }
        } catch {
            HapticFeedback.error()
            print("Error consuming item: \(error)")
        }
    }
    
    private func deleteItem() {
        HapticFeedback.medium()
        NotificationService.shared.cancelNotification(for: item)
        modelContext.delete(item)
        try? modelContext.save()
        dismiss()
    }
}

struct EditExpirationView: View {
    @Binding var expirationDate: Date
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                DatePicker(
                    "Expiration Date",
                    selection: $expirationDate,
                    displayedComponents: .date
                )
            }
            .navigationTitle("Edit Expiration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave()
                        dismiss()
                    }
                }
            }
        }
    }
}

struct EditLocationView: View {
    @Binding var location: StorageLocation
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Storage Location", selection: $location) {
                    ForEach(StorageLocation.allCases, id: \.self) { loc in
                        HStack {
                            Image(systemName: loc.icon)
                            Text(loc.displayName)
                        }
                        .tag(loc)
                    }
                }
            }
            .navigationTitle("Change Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave()
                        dismiss()
                    }
                }
            }
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
    
    return ItemDetailView(item: item)
        .modelContainer(container)
}
