//
//  File.swift
//  
//
//  Created by Samuel Schepp on 20.03.23.
//

import Foundation
import Vapor
import VaporToOpenAPI
import Fluent

struct ProductsDto: Content, WithExample {
    var products: [ProductDto]
    var page: PageMetadataDto

    static func from(page: Page<Product>) throws -> ProductsDto {
        return ProductsDto(
            products: try page.items.map(ProductDto.from),
            page: PageMetadataDto.from(pageMetadata: page.metadata)
        )
    }

    static var example: ProductsDto {
        ProductsDto(products: [ProductDto.example, ProductDto.example], page: PageMetadataDto.example)
    }
}
