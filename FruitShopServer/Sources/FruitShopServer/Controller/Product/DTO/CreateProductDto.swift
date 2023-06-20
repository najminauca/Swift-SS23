//
//  CreateProductDto.swift
//  
//
//  Created by Samuel Schepp on 20.03.23.
//

import Foundation
import Vapor
import VaporToOpenAPI

struct CreateProductDto: Content, WithExample {
    var name: String
    var description: String
    var price: Decimal
    var categoryId: UUID?
    var vendorId: UUID?

    static var example: CreateProductDto {
        CreateProductDto(name: "Apple", description: "Apples are very yummy.", price: 0.99, categoryId: UUID.example, vendorId: UUID.example)
    }
}
