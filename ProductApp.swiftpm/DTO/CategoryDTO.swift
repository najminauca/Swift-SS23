//
//  ProductDTO.swift
//  ProductApp
//
//  Created by Najmi Antariksa on 20.06.23.
//

import Foundation

struct CategoriesDTO: Codable {
    var page: PageMetadataDTO
    var categories: [CategoryDTO]
}

struct CategoryDTO: Codable, Identifiable {
    var id: String?
    var name: String
    var productsCount: Int64
}
