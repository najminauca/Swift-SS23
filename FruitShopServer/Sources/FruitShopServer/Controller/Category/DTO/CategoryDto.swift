//
//  CategoryDto.swift
//  
//
//  Created by Samuel Schepp on 20.03.23.
//

import Foundation
import VaporToOpenAPI
import Fluent
import Vapor

struct CategoryDto: Content, WithExample, Equatable {
    var id: UUID
    var name: String
    var productsCount: Int

    static var example: CategoryDto {
        CategoryDto(id: UUID.example, name: "Berries", productsCount: 2)
    }
}
