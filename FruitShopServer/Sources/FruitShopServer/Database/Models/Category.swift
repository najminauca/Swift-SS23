//
//  Category.swift
//  
//
//  Created by Samuel Schepp on 20.03.23.
//

import Foundation
import Fluent

final class Category: Model {
    static let schema = "Category"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    init() { }

    class func from(createDto: CreateCategoryDto) -> Category {
        let category = Category()
        category.fill(with: createDto)
        return category
    }

    func fill(with dto: CreateCategoryDto) {
        self.name = dto.name
    }
}
