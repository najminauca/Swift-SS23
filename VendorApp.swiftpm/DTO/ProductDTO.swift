//
//  ProductDTO.swift
//  ProductApp
//
//  Created by Najmi Antariksa on 20.06.23.
//

import Foundation

struct ProductsDTO: Codable {
    var products: [ProductDTO]
    var page: PageMetadataDTO
}

struct ProductDTO: Codable, Identifiable {
    var vendorId: String
    var id: String
    var categoryId: String
    var description: String
    var name: String
    var price: Decimal
}
