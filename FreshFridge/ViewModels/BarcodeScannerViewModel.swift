//
//  BarcodeScannerViewModel.swift
//  FreshFridge
//
//  Created on 2025-01-27.
//

import Foundation
import AVFoundation

@Observable
class BarcodeScannerViewModel {
    var scannedBarcode: String? = nil
    var productInfo: ProductInfo? = nil
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    private let openFoodFactsService = OpenFoodFactsService()
    
    func scanBarcode(_ barcode: String) async {
        scannedBarcode = barcode
        isLoading = true
        errorMessage = nil
        
        do {
            productInfo = try await openFoodFactsService.fetchProduct(barcode: barcode)
        } catch {
            errorMessage = "Could not find product. Please enter manually."
            productInfo = nil
        }
        
        isLoading = false
    }
    
    func reset() {
        scannedBarcode = nil
        productInfo = nil
        isLoading = false
        errorMessage = nil
    }
}

struct ProductInfo {
    let name: String
    let brand: String?
    let category: String?
}
