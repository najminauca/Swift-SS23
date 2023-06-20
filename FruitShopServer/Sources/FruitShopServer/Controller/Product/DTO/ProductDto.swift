//
//  ProductDto.swift
//  
//
//  Created by Samuel Schepp on 20.03.23.
//

import Foundation
import Vapor
import VaporToOpenAPI

struct ProductDto: Content, WithExample, Equatable {
    var id: UUID
    var name: String
    var description: String
    var price: Decimal
    var categoryId: UUID?
    var vendorId: UUID?

    static func from(product: Product) throws -> ProductDto {
        return ProductDto(
            id: try product.requireID(),
            name: product.name,
            description: product.description,
            price: product.price,
            categoryId: product.$category.id,
            vendorId: product.$vendor.id
        )
    }

    static var example: ProductDto {
        ProductDto(id: UUID.example, name: "Apple", description: "Apples are very yummy.", price: 0.99, categoryId: UUID.example, vendorId: UUID.example)
    }
}
