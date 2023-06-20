//
//  Order.swift
//
//
//  Created by Samuel Schepp on 20.03.23.
//

import Foundation
import Fluent

final class Order: Model {
    static let schema = "Order"

    @ID(key: .id)
    var id: UUID?

    @Children(for: \.$order)
    var entries: [OrderEntry]

    @Enum(key: "state")
    var state: State

    @OptionalField(key: "paypalTransactionId")
    var paypalTransactionId: String?

    init() { }

    class func createEmpty() -> Order {
        let order = Order()
        order.state = .paymentPending
        return order
    }

    enum State: String, Codable {
        case paymentPending, processing, completed, cancelled
    }
}
