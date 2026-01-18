//
//  HomeView.swift
//  FreshFridge
//
//  Created on 2025-01-27.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FoodItem.expirationDate, order: .forward) private var items: [FoodItem]
    
    @State private var viewModel = HomeViewModel()
    @State private var showingAddItem = false
    @State private var showingScanner = false
    @State private var selectedItem: FoodItem? = nil
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search and filter bar
                VStack(spacing: 12) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search items...", text: $viewModel.searchText)
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    // Filter chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(
                                title: "All",
                                isSelected: viewModel.selectedLocation == nil,
                                action: { viewModel.selectedLocation = nil }
                            )
                            
                            ForEach(StorageLocation.allCases, id: \.self) { location in
                                FilterChip(
                                    title: location.displayName,
                                    isSelected: viewModel.selectedLocation == location,
                                    action: { viewModel.selectedLocation = location }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                
                // Items list
                let grouped = viewModel.groupedItems(from: items)
                
                if grouped.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "refrigerator")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("No items found")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("Add your first item to get started")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.urgencyOrder, id: \.self) { category in
                            if let categoryItems = grouped[category], !categoryItems.isEmpty {
                                UrgencySection(
                                    category: category,
                                    items: categoryItems,
                                    onItemTap: { item in
                                        selectedItem = item
                                    },
                                    onConsume: { item in
                                        consumeItem(item)
                                    },
                                    onDelete: { item in
                                        deleteItem(item)
                                    }
                                )
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Fresh Fridge")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showingScanner = true
                        } label: {
                            Label("Scan Barcode", systemImage: "barcode.viewfinder")
                        }
                        
                        Button {
                            showingAddItem = true
                        } label: {
                            Label("Add Manually", systemImage: "plus")
                        }
                        
                        Button {
                            viewModel.showExpired.toggle()
                        } label: {
                            Label(
                                viewModel.showExpired ? "Hide Expired" : "Show Expired",
                                systemImage: viewModel.showExpired ? "eye.slash" : "eye"
                            )
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddItemView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingScanner) {
                BarcodeScannerView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(item: $selectedItem) { item in
                ItemDetailView(item: item)
                    .presentationDetents([.large, .medium])
                    .presentationDragIndicator(.visible)
            }
            .onAppear {
                // Request notification permissions
                Task {
                    _ = await NotificationService.shared.requestAuthorization()
                }
            }
        }
    }
    
    private func consumeItem(_ item: FoodItem) {
        do {
            let service = FIFOService(modelContext: modelContext)
            try service.consumeOne(itemName: item.name)
            HapticFeedback.success()
            
            // Cancel notification if item is fully consumed
            if let remainingItems = try? modelContext.fetch(
                FetchDescriptor<FoodItem>(
                    predicate: #Predicate { $0.name == item.name && $0.quantity > 0 }
                )
            ), remainingItems.isEmpty {
                NotificationService.shared.cancelNotification(for: item)
            }
        } catch {
            HapticFeedback.error()
            print("Error consuming item: \(error)")
        }
    }
    
    private func deleteItem(_ item: FoodItem) {
        HapticFeedback.medium()
        NotificationService.shared.cancelNotification(for: item)
        modelContext.delete(item)
        try? modelContext.save()
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: FoodItem.self, inMemory: true)
}
