import Foundation
import Vapor
import XCTVapor
@testable import FruitShopServer

func createTestEnvironment() async throws -> (XCTApplicationTester, Application) {
    let app = try Application(.detect())

    let database = try await InMemoryDatabase(app: app)

    try await createDemoVendors(app: app)
    try await createDemoCategories(app: app)
    try await createDemoProducts(app: app)
    try await createDemoOrders(app: app)

    let categoryController = CategoryController(app: app)
    let productController = ProductController(app: app)
    let vendorController = VendorController(app: app)
    let orderController = OrderController(app: app)

    _ = try await Server(
        app: app,
        database: database,
        categoryController: categoryController,
        productController: productController,
        vendorController: vendorController,
        orderController: orderController
    )

    let tester = try app.testable(method: .running(port: 8123))
    return (tester, app)
}

fileprivate func createDemoVendors(app: Application) async throws {
    let vendor = Vendor()
    vendor.id = UUID(uuidString: "C993142B-3525-4DCD-A73E-8B58864BC943")!
    vendor.fill(with: CreateVendorDto(name: "Orchard Delights"))
    try await vendor.save(on: app.db)
}

fileprivate func createDemoCategories(app: Application) async throws {
    let category = Category()
    category.id = UUID(uuidString: "29E2FF92-C35A-48E9-8E77-422FE69EFE42")!
    category.fill(with: CreateCategoryDto(name: "Pome fruit"))
    try await category.save(on: app.db)
}

fileprivate func createDemoProducts(app: Application) async throws {
    let applesImageUrl = Bundle.module.url(forResource: "Example Data/Images/apples.jpg", withExtension: nil)!
    let applesImageData = try Data(contentsOf: applesImageUrl)
    let product1 = Product()
    product1.id = UUID(uuidString: "64AD150F-A5EA-4D12-86EB-DBC322A13BFA")!
    product1.photo = applesImageData
    product1.fill(with: CreateProductDto(name: "Apple", description: "An apple description.", price: 2.99, categoryId: UUID(uuidString: "29E2FF92-C35A-48E9-8E77-422FE69EFE42")!, vendorId: UUID(uuidString: "C993142B-3525-4DCD-A73E-8B58864BC943")!))
    try await product1.save(on: app.db)

    let bananasImageUrl = Bundle.module.url(forResource: "Example Data/Images/bananas.jpg", withExtension: nil)!
    let bananasImageData = try Data(contentsOf: bananasImageUrl)
    let product2 = Product()
    product2.id = UUID(uuidString: "C91B1818-8FCC-4DD9-9E75-0CEC77D93F04")!
    product2.photo = bananasImageData
    product2.fill(with: CreateProductDto(name: "Bananas", description: "A banana description.", price: 1.99, categoryId: nil, vendorId: nil))
    try await product2.save(on: app.db)
}

fileprivate func createDemoOrders(app: Application) async throws {
    let order = Order()
    order.id = UUID(uuidString: "24DCECBA-5E5F-44B2-84D3-2215C74D5A16")!
    order.state = .processing
    try await order.save(on: app.db)

    let entry1 = OrderEntry()
    entry1.id = UUID(uuidString: "E69B9C4A-4EE4-4CC4-B4F4-0AAFB3B3D29B")!
    entry1.$product.id = UUID(uuidString: "64AD150F-A5EA-4D12-86EB-DBC322A13BFA")!
    entry1.amount = 2
    entry1.$order.id = UUID(uuidString: "24DCECBA-5E5F-44B2-84D3-2215C74D5A16")!
    try await entry1.save(on: app.db)

    let entry2 = OrderEntry()
    entry2.id = UUID(uuidString: "E4F4D7A8-46D1-468E-9C70-347086CD8C16")!
    entry2.$product.id = UUID(uuidString: "C91B1818-8FCC-4DD9-9E75-0CEC77D93F04")!
    entry2.amount = 1
    entry2.$order.id = UUID(uuidString: "24DCECBA-5E5F-44B2-84D3-2215C74D5A16")!
    try await entry2.save(on: app.db)
}
