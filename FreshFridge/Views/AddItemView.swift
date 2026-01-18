//
//  AddItemView.swift
//  FreshFridge
//
//  Created on 2025-01-27.
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel = AddItemViewModel()
    @State private var showingTemplates = false
    @State private var selectedPhoto: PhotosPickerItem? = nil
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Item Details") {
                    TextField("Item Name", text: $viewModel.name)
                        .autocapitalization(.words)
                    
                    TextField("Brand (optional)", text: $viewModel.brand)
                        .autocapitalization(.words)
                    
                    TextField("Category (optional)", text: $viewModel.category)
                        .autocapitalization(.words)
                }
                
                Section("Quick Templates") {
                    Button {
                        showingTemplates = true
                    } label: {
                        HStack {
                            Text("Use Template")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("Expiration & Storage") {
                    DatePicker(
                        "Expiration Date",
                        selection: $viewModel.expirationDate,
                        displayedComponents: .date
                    )
                    
                    Picker("Storage Location", selection: $viewModel.storageLocation) {
                        ForEach(StorageLocation.allCases, id: \.self) { location in
                            HStack {
                                Image(systemName: location.icon)
                                Text(location.displayName)
                            }
                            .tag(location)
                        }
                    }
                    
                    Stepper("Quantity: \(viewModel.quantity)", value: $viewModel.quantity, in: 1...100)
                }
                
                Section("Photo (Optional)") {
                    PhotosPicker(
                        selection: $selectedPhoto,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        HStack {
                            if viewModel.photoData != nil {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "camera")
                            }
                            Text(viewModel.photoData != nil ? "Photo Added" : "Add Photo")
                        }
                    }
                    .onChange(of: selectedPhoto) { oldValue, newValue in
                        Task {
                            if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                viewModel.photoData = data
                                HapticFeedback.light()
                            }
                        }
                    }
                    
                    if let photoData = viewModel.photoData,
                       let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .cornerRadius(8)
                        
                        Button(role: .destructive) {
                            viewModel.photoData = nil
                            selectedPhoto = nil
                        } label: {
                            Text("Remove Photo")
                        }
                    }
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveItem()
                    }
                    .disabled(viewModel.name.isEmpty)
                }
            }
            .sheet(isPresented: $showingTemplates) {
                TemplateSelectionView { template in
                    viewModel.applyTemplate(template)
                    showingTemplates = false
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
    }
    
    private func saveItem() {
        guard !viewModel.name.isEmpty else { return }
        
        let item = viewModel.createFoodItem()
        modelContext.insert(item)
        
        // Schedule notification
        NotificationService.shared.scheduleNotification(for: item)
        
        do {
            try modelContext.save()
            HapticFeedback.success()
            dismiss()
        } catch {
            HapticFeedback.error()
            print("Error saving item: \(error)")
        }
    }
}

struct TemplateSelectionView: View {
    let onSelect: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(Constants.produceTemplates, id: \.self) { template in
                    Button {
                        onSelect(template)
                    } label: {
                        HStack {
                            Text(template)
                            Spacer()
                            if let days = Constants.defaultShelfLife[template] {
                                Text("\(days) days")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Quick Templates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AddItemView()
        .modelContainer(for: FoodItem.self, inMemory: true)
}
