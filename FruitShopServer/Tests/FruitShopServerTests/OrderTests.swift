import Vapor
import XCTVapor
import XCTest
@testable import FruitShopServer

final class OrderTests: XCTestCase {
    var tester: XCTApplicationTester!
    var app: Application!

    override func setUp() async throws {
        (tester, app) = try await createTestEnvironment()
    }

    override func tearDown() async throws {
        app.shutdown()
    }

    func testGetTestOrders() throws {
        try tester.test(.GET, "/api/orders") { res in
            XCTAssertEqual(res.status, .ok)
            let ordersResponse = try res.content.decode(OrdersDto.self)
            XCTAssertEqual(ordersResponse.page.total, 1)

            guard let order = ordersResponse.orders.first else {
                XCTFail()
                return
            }

            XCTAssertEqual(order, OrderDto(
                id: UUID(uuidString: "24DCECBA-5E5F-44B2-84D3-2215C74D5A16")!,
                entries: [
                    OrderEntryDto(id: UUID(uuidString: "E69B9C4A-4EE4-4CC4-B4F4-0AAFB3B3D29B")!, productID: UUID(uuidString: "64AD150F-A5EA-4D12-86EB-DBC322A13BFA")!, amount: 2),
                    OrderEntryDto(id: UUID(uuidString: "E4F4D7A8-46D1-468E-9C70-347086CD8C16")!, productID: UUID(uuidString: "C91B1818-8FCC-4DD9-9E75-0CEC77D93F04")!, amount: 1)
                ],
                state: .processing
            ))
        }
    }

    func testDeleteOrder() async throws {
        let orderCountPre = try await Order.query(on: app.db).count()

        guard let order = try await Order.find(UUID(uuidString: "24DCECBA-5E5F-44B2-84D3-2215C74D5A16")!, on: app.db) else {
            XCTFail()
            return
        }
        order.state = .cancelled
        try await order.save(on: app.db)

        try await tester.test(.DELETE, "/api/orders/\(order.requireID().uuidString)") { res in
            XCTAssertEqual(res.status, .ok)
            let order = try res.content.decode(OrderDto.self)
            XCTAssertEqual(order.entries.count, 2)

            let orderCountPost = try await Order.query(on: app.db).count()
            XCTAssertEqual(orderCountPre - 1, orderCountPost)
        }
    }

    func testDeleteOrderIllegalState() async throws {
        try tester.test(.DELETE, "/api/orders/24DCECBA-5E5F-44B2-84D3-2215C74D5A16") { res in
            XCTAssertEqual(res.status, .expectationFailed)
        }
    }

    func testCreateOrder() async throws {
        let orderCountPre = try await Order.query(on: app.db).count()

        let createOrderDto = PostOrderDto(entries: [
            PostOrderEntryDto(productID: UUID(uuidString: "64AD150F-A5EA-4D12-86EB-DBC322A13BFA")!, amount: 2),
            PostOrderEntryDto(productID: UUID(uuidString: "C91B1818-8FCC-4DD9-9E75-0CEC77D93F04")!, amount: 1)
        ])

        try await tester.test(.POST, "/api/orders", beforeRequest: { req in
            try req.content.encode(createOrderDto)
        }) { res in
            XCTAssertEqual(res.status, .ok)
            let order = try res.content.decode(OrderDto.self)

            XCTAssertEqual(order, OrderDto(
                id: order.id,
                entries: [
                    OrderEntryDto(id: order.entries[0].id, productID: UUID(uuidString: "64AD150F-A5EA-4D12-86EB-DBC322A13BFA")!, amount: 2),
                    OrderEntryDto(id: order.entries[1].id, productID: UUID(uuidString: "C91B1818-8FCC-4DD9-9E75-0CEC77D93F04")!, amount: 1)
                ],
                state: .paymentPending
            ))


            let orderCountPost = try await Order.query(on: self.app.db).count()
            XCTAssertEqual(orderCountPre + 1, orderCountPost)
        }
    }

    func testPayOrder() async throws {
        guard let orderPre = try await Order.find(UUID(uuidString: "24DCECBA-5E5F-44B2-84D3-2215C74D5A16")!, on: app.db) else {
            XCTFail()
            return
        }
        orderPre.state = .paymentPending
        try await orderPre.save(on: app.db)

        let payOrderDto = PayOrderDto(paypalTransactionId: UUID.example.uuidString)

        try tester.test(.PUT, "/api/orders/24DCECBA-5E5F-44B2-84D3-2215C74D5A16/pay", beforeRequest: { req in
            try req.content.encode(payOrderDto)
        }) { res in
            XCTAssertEqual(res.status, .ok)
            let order = try res.content.decode(OrderDto.self)
            XCTAssertEqual(order.state, .processing)
        }
    }

    func testPayOrderIllegalState() async throws {
        guard let orderPre = try await Order.find(UUID(uuidString: "24DCECBA-5E5F-44B2-84D3-2215C74D5A16")!, on: app.db) else {
            XCTFail()
            return
        }
        orderPre.state = .processing
        try await orderPre.save(on: app.db)

        let payOrderDto = PayOrderDto(paypalTransactionId: UUID.example.uuidString)

        try tester.test(.PUT, "/api/orders/24DCECBA-5E5F-44B2-84D3-2215C74D5A16/pay", beforeRequest: { req in
            try req.content.encode(payOrderDto)
        }) { res in
            XCTAssertEqual(res.status, .expectationFailed)
        }
    }

    func testCompleteOrder() async throws {
        guard let orderPre = try await Order.find(UUID(uuidString: "24DCECBA-5E5F-44B2-84D3-2215C74D5A16")!, on: app.db) else {
            XCTFail()
            return
        }
        orderPre.state = .processing
        try await orderPre.save(on: app.db)

        let payOrderDto = PayOrderDto(paypalTransactionId: UUID.example.uuidString)

        try tester.test(.PUT, "/api/orders/24DCECBA-5E5F-44B2-84D3-2215C74D5A16/complete", beforeRequest: { req in
            try req.content.encode(payOrderDto)
        }) { res in
            XCTAssertEqual(res.status, .ok)
            let order = try res.content.decode(OrderDto.self)
            XCTAssertEqual(order.state, .completed)
        }
    }

    func testCompleteOrderIllegalState() async throws {
        guard let orderPre = try await Order.find(UUID(uuidString: "24DCECBA-5E5F-44B2-84D3-2215C74D5A16")!, on: app.db) else {
            XCTFail()
            return
        }
        orderPre.state = .paymentPending
        try await orderPre.save(on: app.db)

        let payOrderDto = PayOrderDto(paypalTransactionId: UUID.example.uuidString)

        try tester.test(.PUT, "/api/orders/24DCECBA-5E5F-44B2-84D3-2215C74D5A16/complete", beforeRequest: { req in
            try req.content.encode(payOrderDto)
        }) { res in
            XCTAssertEqual(res.status, .expectationFailed)
        }
    }

    func testCancelOrderPaymentPending() async throws {
        guard let orderPre = try await Order.find(UUID(uuidString: "24DCECBA-5E5F-44B2-84D3-2215C74D5A16")!, on: app.db) else {
            XCTFail()
            return
        }
        orderPre.state = .paymentPending
        try await orderPre.save(on: app.db)

        try tester.test(.PUT, "/api/orders/24DCECBA-5E5F-44B2-84D3-2215C74D5A16/cancel") { res in
            XCTAssertEqual(res.status, .ok)
            let order = try res.content.decode(OrderDto.self)
            XCTAssertEqual(order.state, .cancelled)
        }
    }

    func testCancelOrderProcessing() async throws {
        guard let orderPre = try await Order.find(UUID(uuidString: "24DCECBA-5E5F-44B2-84D3-2215C74D5A16")!, on: app.db) else {
            XCTFail()
            return
        }
        orderPre.state = .processing
        try await orderPre.save(on: app.db)

        try tester.test(.PUT, "/api/orders/24DCECBA-5E5F-44B2-84D3-2215C74D5A16/cancel") { res in
            XCTAssertEqual(res.status, .ok)
            let order = try res.content.decode(OrderDto.self)
            XCTAssertEqual(order.state, .cancelled)
        }
    }
}
