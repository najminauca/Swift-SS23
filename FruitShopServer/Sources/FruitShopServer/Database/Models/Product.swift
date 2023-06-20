//
//  Product.swift
//  
//
//  Created by Samuel Schepp on 20.03.23.
//

import Foundation
import Fluent

final class Product: Model {
    static let schema = "Product"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "description")
    var description: String

    @Field(key: "price")
    var price: Decimal

    @Field(key: "photo")
    var photo: Data?

    @OptionalParent(key: "category_id")
    var category: Category?

    @OptionalParent(key: "vendor_id")
    var vendor: Vendor?

    init() { }

    class func from(createDto: CreateProductDto) -> Product {
        let product = Product()
        product.fill(with: createDto)
        return product
    }

    func fill(with dto: CreateProductDto) {
        self.name = dto.name
        self.description = dto.description
        self.price = dto.price
        self.$category.id = dto.categoryId
        self.$vendor.id = dto.vendorId
    }
}
