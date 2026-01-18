//
//  OpenFoodFactsService.swift
//  FreshFridge
//
//  Created on 2025-01-27.
//

import Foundation

class OpenFoodFactsService {
    private let baseURL = "https://world.openfoodfacts.org/api/v0/product"
    
    func fetchProduct(barcode: String) async throws -> ProductInfo {
        guard let url = URL(string: "\(baseURL)/\(barcode).json") else {
            throw OpenFoodFactsError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw OpenFoodFactsError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        let productResponse = try decoder.decode(OpenFoodFactsResponse.self, from: data)
        
        guard productResponse.status == 1,
              let product = productResponse.product else {
            throw OpenFoodFactsError.productNotFound
        }
        
        return ProductInfo(
            name: product.productName ?? "Unknown Product",
            brand: product.brands?.split(separator: ",").first.map(String.init)?.trimmingCharacters(in: .whitespaces),
            category: product.categoriesTags?.first?.replacingOccurrences(of: "en:", with: "").capitalized
        )
    }
}

enum OpenFoodFactsError: Error {
    case invalidURL
    case invalidResponse
    case productNotFound
    case decodingError
}

struct OpenFoodFactsResponse: Codable {
    let status: Int
    let product: Product?
}

struct Product: Codable {
    let productName: String?
    let brands: String?
    let categoriesTags: [String]?
    
    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case brands
        case categoriesTags = "categories_tags"
    }
}
