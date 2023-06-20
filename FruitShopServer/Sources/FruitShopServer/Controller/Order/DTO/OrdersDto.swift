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

struct OrdersDto: Content, WithExample {
    var orders: [OrderDto]
    var page: PageMetadataDto

    static func from(page: Page<Order>) throws -> OrdersDto {
        return OrdersDto(
            orders: try page.items.map {
                try OrderDto.from(order: $0, entries: $0.entries)
            },
            page: PageMetadataDto.from(pageMetadata: page.metadata)
        )
    }

    static var example: OrdersDto {
        OrdersDto(orders: [OrderDto.example, OrderDto.example, OrderDto.example], page: PageMetadataDto.example)
    }
}
