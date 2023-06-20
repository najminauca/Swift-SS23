//
//  OrderController.swift
//  
//
//  Created by Samuel Schepp on 21.03.23.
//

import Foundation
import Fluent
import Vapor
import VaporToOpenAPI

class OrderController {
    let app: Application

    init(app: Application) {
        self.app = app
    }

    func register(router: RoutesBuilder) {
        router.group("orders") { group in
            group.post() { request -> OrderDto in
                let createDto = try request.content.decode(PostOrderDto.self)

                let order = Order.createEmpty()
                try await order.save(on: self.app.db)

                var entries: [OrderEntry] = []
                for entry in createDto.entries {
                    guard let product = try await Product.query(on: self.app.db).filter(\Product.$id == entry.productID).first() else {
                        throw Abort(.notFound, reason: "Product \(entry.productID) not found")
                    }
                    let entry = try OrderEntry.from(order: order, product: product, createDto: entry)
                    try await entry.save(on: self.app.db)
                    entries.append(entry)
                }

                let orderDto = try OrderDto.from(order: order, entries: entries)
                return orderDto
            }
            .openAPI(
                tags: ["Orders"],
                summary: "Create an order",
                body: PostOrderDto.self,
                response: OrderDto.self
            )

            group.get() { req -> OrdersDto in
                let orders = try await Order.query(on: self.app.db).with(\.$entries).paginate(for: req)
                let ordersDto = try OrdersDto.from(page: orders)
                return ordersDto
            }
            .openAPI(
                tags: ["Orders"],
                summary: "Get orders",
                query: PageRequestDto.self,
                response: OrdersDto.self
            )

            group.delete(":id") { request -> OrderDto in
                let id = try request.requireID()
                guard let order = try await Order.query(on: self.app.db).filter(\Order.$id == id).with(\.$entries).first() else {
                    throw Abort(.notFound, reason: "Order not found")
                }
                if order.state != .cancelled {
                    throw Abort(.expectationFailed, reason: "Only orders with state \(Order.State.cancelled) can be deleted.")
                }

                try await order.delete(on: self.app.db)
                let orderDto = try OrderDto.from(order: order, entries: order.entries)
                return orderDto
            }
            .openAPI(
                tags: ["Orders"],
                summary: "Delete an order",
                response: OrderDto.self
            )

            group.put(":id", "pay") { request -> OrderDto in
                let id = try request.requireID()
                let payOrderDto = try request.content.decode(PayOrderDto.self)

                guard let order = try await Order.query(on: self.app.db).filter(\Order.$id == id).with(\.$entries).first() else {
                    throw Abort(.notFound, reason: "Order not found")
                }
                if order.state != .paymentPending {
                    throw Abort(.expectationFailed, reason: "Only orders with state \(Order.State.paymentPending) can be paid.")
                }

                order.state = .processing
                order.paypalTransactionId = payOrderDto.paypalTransactionId

                try await order.save(on: self.app.db)
                let orderDto = try OrderDto.from(order: order, entries: order.entries)
                return orderDto
            }
            .openAPI(
                tags: ["Orders"],
                summary: "Pay an order",
                body: PayOrderDto.self,
                response: OrderDto.self
            )

            group.put(":id", "cancel") { request -> OrderDto in
                let id = try request.requireID()

                guard let order = try await Order.query(on: self.app.db).filter(\Order.$id == id).with(\.$entries).first() else {
                    throw Abort(.notFound, reason: "Order not found")
                }

                order.state = .cancelled

                try await order.save(on: self.app.db)
                let orderDto = try OrderDto.from(order: order, entries: order.entries)
                return orderDto
            }
            .openAPI(
                tags: ["Orders"],
                summary: "Cancel an order",
                response: OrderDto.self
            )

            group.put(":id", "complete") { request -> OrderDto in
                let id = try request.requireID()

                guard let order = try await Order.query(on: self.app.db).filter(\Order.$id == id).with(\.$entries).first() else {
                    throw Abort(.notFound, reason: "Order not found")
                }
                if order.state != .processing {
                    throw Abort(.expectationFailed, reason: "Only orders with state \(Order.State.processing) can be completed.")
                }

                order.state = .completed

                try await order.save(on: self.app.db)
                let orderDto = try OrderDto.from(order: order, entries: order.entries)
                return orderDto
            }
            .openAPI(
                tags: ["Orders"],
                summary: "Complete an order",
                response: OrderDto.self
            )
        }
    }
}
