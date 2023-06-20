//
//  MigrationV1.swift
//  
//
//  Created by Samuel Schepp on 20.03.23.
//

import Foundation
import FluentKit

class MigrationV1: AsyncMigration {
    var name: String = "v1"

    func prepare(on database: Database) async throws {
        try await database.schema(Category.schema)
            .id()
            .field("name", .string, .required)
            .create()

        try await database.schema(Vendor.schema)
            .id()
            .field("name", .string, .required)
            .create()

        try await database.schema(Product.schema)
            .id()
            .field("name", .string, .required)
            .field("description", .string, .required)
            .field("price", .double, .required)
            .field("photo", .data)
            .field("category_id", .uuid, .references(Category.schema, "id", onDelete: .setNull))
            .field("vendor_id", .uuid, .references(Vendor.schema, "id", onDelete: .setNull))
            .create()

        try await database.schema(Order.schema)
            .id()
            .field("state", .string, .required)
            .field("paypalTransactionId", .string)
            .create()

        try await database.schema(OrderEntry.schema)
            .id()
            .field("order_id", .uuid, .references(Order.schema, "id", onDelete: .cascade), .required)
            .field("product_id", .uuid, .references(Product.schema, "id", onDelete: .setNull))
            .field("amount", .int, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Category.schema).delete()
        try await database.schema(Vendor.schema).delete()
        try await database.schema(Product.schema).delete()
        try await database.schema(OrderEntry.schema).delete()
        try await database.schema(Order.schema).delete()
    }
}
