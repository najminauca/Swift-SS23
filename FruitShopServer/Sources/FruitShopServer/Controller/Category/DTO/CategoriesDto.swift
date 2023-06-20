//
//  CategoriesDto.swift
//  
//
//  Created by Samuel Schepp on 20.03.23.
//

import Foundation
import VaporToOpenAPI
import Fluent
import Vapor

struct CategoriesDto: Content, WithExample {
    var categories: [CategoryDto]
    var page: PageMetadataDto

    static var example: CategoriesDto {
        CategoriesDto(categories: [CategoryDto.example, CategoryDto.example, CategoryDto.example], page: PageMetadataDto.example)
    }
}
