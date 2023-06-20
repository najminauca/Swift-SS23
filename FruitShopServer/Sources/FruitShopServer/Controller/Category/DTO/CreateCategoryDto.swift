//
//  CreateCategoryDto.swift
//  
//
//  Created by Samuel Schepp on 20.03.23.
//

import Foundation
import VaporToOpenAPI
import Fluent
import Vapor

struct CreateCategoryDto: Content, WithExample {
    var name: String

    static var example: CreateCategoryDto {
        return CreateCategoryDto(name: "Berries")
    }
}
