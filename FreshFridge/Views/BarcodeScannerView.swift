//
//  BarcodeScannerView.swift
//  FreshFridge
//
//  Created on 2025-01-27.
//

import SwiftUI
import AVFoundation
import SwiftData
import UIKit

struct BarcodeScannerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel = BarcodeScannerViewModel()
    @State private var showingAddItem = false
    @State private var addItemViewModel = AddItemViewModel()
    @State private var cameraPermissionStatus: AVAuthorizationStatus = .notDetermined
    
    var body: some View {
        NavigationStack {
            ZStack {
                if cameraPermissionStatus == .authorized {
                    CameraPreview(scannerViewModel: viewModel)
                        .ignoresSafeArea()
                    
                    VStack {
                        Spacer()
                        
                        // Scanning overlay
                        VStack(spacing: 16) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .scaleEffect(1.5)
                                Text("Looking up product...")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                            } else if let error = viewModel.errorMessage {
                                VStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle")
                                        .font(.title)
                                        .foregroundColor(.yellow)
                                    Text(error)
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                    Button("Enter Manually") {
                                        showingAddItem = true
                                    }
                                    .buttonStyle(.borderedProminent)
                                }
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(12)
                            } else {
                                Text("Position barcode within the frame")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.black.opacity(0.7))
                                    .cornerRadius(8)
                            }
                            
                            // Scanning frame overlay
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white, lineWidth: 2)
                                .frame(width: 250, height: 150)
                                .padding(.bottom, 20)
                        }
                        .padding(.bottom, 50)
                    }
                } else {
                    // Permission request view
                    VStack(spacing: 20) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("Camera Access Required")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("We need camera access to scan barcodes")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Grant Permission") {
                            requestCameraPermission()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
            }
            .navigationTitle("Scan Barcode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Manual Entry") {
                        showingAddItem = true
                    }
                }
            }
            .onAppear {
                checkCameraPermission()
            }
            .onChange(of: viewModel.productInfo) { oldValue, newValue in
                if let product = newValue {
                    // Populate add item view with product info
                    addItemViewModel.name = product.name
                    addItemViewModel.brand = product.brand ?? ""
                    addItemViewModel.category = product.category ?? ""
                    HapticFeedback.success()
                    showingAddItem = true
                }
            }
            .onChange(of: viewModel.errorMessage) { oldValue, newValue in
                if newValue != nil {
                    HapticFeedback.warning()
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddItemViewWithScanner(
                    viewModel: addItemViewModel,
                    onSave: { item in
                        modelContext.insert(item)
                        NotificationService.shared.scheduleNotification(for: item)
                        try? modelContext.save()
                        HapticFeedback.success()
                        dismiss()
                    }
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
    }
    
    private func checkCameraPermission() {
        cameraPermissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
    }
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                checkCameraPermission()
            }
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    let scannerViewModel: BarcodeScannerViewModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            return view
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return view
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return view
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417, .upce, .code128]
        } else {
            return view
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        context.coordinator.captureSession = captureSession
        
        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.startRunning()
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = uiView.layer.bounds
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(scannerViewModel: scannerViewModel)
    }
    
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        let scannerViewModel: BarcodeScannerViewModel
        var captureSession: AVCaptureSession?
        var lastScannedCode: String?
        var lastScanTime: Date = Date()
        
        init(scannerViewModel: BarcodeScannerViewModel) {
            self.scannerViewModel = scannerViewModel
        }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            // Throttle scans to once per second
            guard Date().timeIntervalSince(lastScanTime) > 1.0 else { return }
            
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                      let stringValue = readableObject.stringValue,
                      stringValue != lastScannedCode else {
                    return
                }
                
                lastScannedCode = stringValue
                lastScanTime = Date()
                
                // Stop scanning temporarily
                captureSession?.stopRunning()
                
                // Look up product
                Task {
                    await scannerViewModel.scanBarcode(stringValue)
                }
            }
        }
    }
}

struct AddItemViewWithScanner: View {
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: AddItemViewModel
    let onSave: (FoodItem) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Item Details") {
                    TextField("Item Name", text: $viewModel.name)
                        .autocapitalization(.words)
                    
                    if !viewModel.brand.isEmpty {
                        TextField("Brand", text: $viewModel.brand)
                            .autocapitalization(.words)
                    }
                    
                    if !viewModel.category.isEmpty {
                        TextField("Category", text: $viewModel.category)
                            .autocapitalization(.words)
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
                        let item = viewModel.createFoodItem()
                        onSave(item)
                        dismiss()
                    }
                    .disabled(viewModel.name.isEmpty)
                }
            }
        }
    }
}

#Preview {
    BarcodeScannerView()
        .modelContainer(for: FoodItem.self, inMemory: true)
}
