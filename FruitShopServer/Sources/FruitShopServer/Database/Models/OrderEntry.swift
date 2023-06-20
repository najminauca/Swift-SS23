//
//  OrderEntry.swift
//
//
//  Created by Samuel Schepp on 20.03.23.
//

import Foundation
import Fluent

final class OrderEntry: Model {
    static let schema = "OrderEntry"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "order_id")
    var order: Order

    @OptionalParent(key: "product_id")
    var product: Product?

    @Field(key: "amount")
    var amount: Int

    init() { }

    class func from(order: Order, product: Product, createDto: PostOrderEntryDto) throws -> OrderEntry {
        let orderEntry = OrderEntry()
        orderEntry.$order.id = try order.requireID()
        orderEntry.$product.id = try product.requireID()
        orderEntry.amount = createDto.amount
        return orderEntry
    }
}
