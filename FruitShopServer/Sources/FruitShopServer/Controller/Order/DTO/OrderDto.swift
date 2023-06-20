//
//  OrderDto.swift
//  
//
//  Created by Samuel Schepp on 21.03.23.
//

import Foundation
import VaporToOpenAPI
import Fluent
import Vapor

struct OrderDto: Content, WithExample, Equatable {
    var id: UUID
    var entries: [OrderEntryDto]
    var state: StateDto

    static var example: OrderDto {
        OrderDto(id: UUID.example, entries: [OrderEntryDto.example, OrderEntryDto.example, OrderEntryDto.example], state: StateDto.example)
    }

    static func from(order: Order, entries: [OrderEntry]) throws -> OrderDto {
        return OrderDto(
            id: try order.requireID(),
            entries: try entries.map { entry in
                OrderEntryDto(id: try entry.requireID(), productID: entry.$product.id, amount: entry.amount)
            },
            state: StateDto.from(state: order.state)
        )
    }

    enum StateDto: String, Codable, WithExample, CaseIterable {
        case paymentPending, processing, completed, cancelled

        static func from(state: Order.State) -> StateDto {
            switch state {
            case .processing: return .processing
            case .paymentPending: return .paymentPending
            case .completed: return .completed
            case .cancelled: return .cancelled
            }
        }

        static var example: OrderDto.StateDto = .processing
    }
}
