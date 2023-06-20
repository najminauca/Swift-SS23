import Vapor
import Fluent
import FluentSQLiteDriver

@main
class Main {
    static func main() async {
        do {
            let app = try Application(.detect())
            app.logger.logLevel = .debug

            let database = try await FluentDatabase(app: app)

            let demoDataCreator = DemoDataGenerator(app: app)
            try await demoDataCreator.generateDemoDataIfNeeded()

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

            defer { app.shutdown() }
            try app.run()
        } catch let error {
            print(error)
            exit(1)
        }
    }
}
