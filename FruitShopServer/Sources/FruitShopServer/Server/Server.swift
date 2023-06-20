import Foundation
import Vapor
import Fluent
import VaporToOpenAPI

class Server {
    let app: Application
    let database: FluentDatabase

    let categoryController: CategoryController
    let productController: ProductController
    let vendorController: VendorController

    init(app: Application, database: FluentDatabase, categoryController: CategoryController, productController: ProductController, vendorController: VendorController, orderController: OrderController) async throws {
        self.app = app
        self.database = database
        self.categoryController = categoryController
        self.productController = productController
        self.vendorController = vendorController

        let publicPath = Bundle.module.url(forResource: "Public", withExtension: nil)!.path
        let file = FileMiddleware(publicDirectory: publicPath, defaultFile: "index.html")
        app.middleware.use(file)

        app.http.server.configuration.hostname = "127.0.0.1"
        app.http.server.configuration.port = 8080

        app.get("") {
            $0.redirect(to: "/doc/")
        }.excludeFromOpenAPI()

        let orderStates: String = OrderDto.StateDto.allCases.map{$0.rawValue}.joined(separator: ", ")
        app.get("openapi_gen.json") { req in
            req.application.routes.openAPI(
                info: InfoObject(
                    title: "Fruit Shop API",
                    description: "API Definitions. Order states: \(orderStates).",
                    version: "0.1.0"
                )
            )
        }.excludeFromOpenAPI()

        app.group("api") { group in
            categoryController.register(router: group)
            productController.register(router: group)
            vendorController.register(router: group)
            orderController.register(router: group)
        }
    }
}


