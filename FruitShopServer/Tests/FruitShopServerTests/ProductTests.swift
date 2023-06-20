import Vapor
import XCTVapor
import XCTest
import Fluent
@testable import FruitShopServer

final class ProductTests: XCTestCase {
    var tester: XCTApplicationTester!
    var app: Application!

    override func setUp() async throws {
        (tester, app) = try await createTestEnvironment()
    }

    override func tearDown() async throws {
        app.shutdown()
    }

    func testGetAllProducts() throws {
        try tester.test(.GET, "/api/products") { res in
            XCTAssertEqual(res.status, .ok)
            let products = try res.content.decode(ProductsDto.self)
            XCTAssertEqual(products.products.count, 2)
            XCTAssertEqual(products.page.page, 1)
            XCTAssertEqual(products.page.pageCount, 1)
            XCTAssertEqual(products.page.total, 2)
            XCTAssertEqual(products.page.per, 10)

            guard let productDto = products.products.first else {
                XCTFail()
                return
            }

            XCTAssertEqual(productDto, ProductDto(id: UUID(uuidString: "64AD150F-A5EA-4D12-86EB-DBC322A13BFA")!, name: "Apple", description: "An apple description.", price: 2.99, categoryId: UUID(uuidString: "29E2FF92-C35A-48E9-8E77-422FE69EFE42")!, vendorId: UUID(uuidString: "C993142B-3525-4DCD-A73E-8B58864BC943")!))
        }
    }

    func testGetAllProductsPaginated() async throws {
        try await Product.query(on: app.db).delete()
        for i in 0..<7 {
            let product = Product()
            product.id = UUID(uuidString: "80C3A122-B375-4800-BA49-99521495568\(i)")
            product.fill(with: CreateProductDto(name: "Product \(i)", description: "Description \(i)", price: Decimal(i)))
            try await product.save(on: app.db)
        }

        try tester.test(.GET, "/api/products", beforeRequest: { req in
            try req.query.encode([
                "page": 2,
                "per": 2,
            ])
        }) { res in
            XCTAssertEqual(res.status, .ok)
            let products = try res.content.decode(ProductsDto.self)
            XCTAssertEqual(products.products.count, 2)
            XCTAssertEqual(products.page.page, 2)
            XCTAssertEqual(products.page.pageCount, 4)
            XCTAssertEqual(products.page.total, 7)
            XCTAssertEqual(products.page.per, 2)

            if products.products.count != 2 {
                XCTFail()
                return
            }

            let product1 = products.products[0]
            let product2 = products.products[1]

            XCTAssertEqual(product1, ProductDto(id: UUID(uuidString: "80C3A122-B375-4800-BA49-995214955682")!, name: "Product 2", description: "Description 2", price: 2, categoryId: nil, vendorId: nil))
            XCTAssertEqual(product2, ProductDto(id: UUID(uuidString: "80C3A122-B375-4800-BA49-995214955683")!, name: "Product 3", description: "Description 3", price: 3, categoryId: nil, vendorId: nil))
        }
    }

    func testCreateProduct() async throws {
        let productsCountPre = try await Product.query(on: app.db).count()

        let createDto = CreateProductDto(name: "Other", description: "Some description", price: 0.99)
        try await tester.test(.POST, "/api/products", beforeRequest: { req in
            try req.content.encode(createDto)
        }) { res in
            XCTAssertEqual(res.status, .ok)

            let product = try res.content.decode(ProductDto.self)
            XCTAssertEqual(product, ProductDto(id: product.id, name: "Other", description: "Some description", price: 0.99, categoryId: nil, vendorId: nil))

            let productsCountPost = try await Product.query(on: app.db).count()
            XCTAssertEqual(productsCountPre + 1, productsCountPost)
        }
    }

    func testCreateProductWithCategoryAndVendor() async throws {
        let createDto = CreateProductDto(name: "Other", description: "Some description", price: 0.99, categoryId: UUID(uuidString: "29E2FF92-C35A-48E9-8E77-422FE69EFE42")!, vendorId: UUID(uuidString: "C993142B-3525-4DCD-A73E-8B58864BC943")!)
        try tester.test(.POST, "/api/products", beforeRequest: { req in
            try req.content.encode(createDto)
        }) { res in
            XCTAssertEqual(res.status, .ok)

            let product = try res.content.decode(ProductDto.self)
            XCTAssertEqual(product, ProductDto(id: product.id, name: "Other", description: "Some description", price: 0.99, categoryId: UUID(uuidString: "29E2FF92-C35A-48E9-8E77-422FE69EFE42")!, vendorId: UUID(uuidString: "C993142B-3525-4DCD-A73E-8B58864BC943")!))
        }
    }

    func testCreateProductWithCategoryAndVendorCategoryNotFound() async throws {
        let createDto = CreateProductDto(name: "Other", description: "Some description", price: 0.99, categoryId: UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!)
        try tester.test(.POST, "/api/products", beforeRequest: { req in
            try req.content.encode(createDto)
        }) { res in
            XCTAssertEqual(res.status, .internalServerError)
            XCTAssertEqual(res.content["reason"], "constraint: FOREIGN KEY constraint failed")
        }
    }

    func testCreateProductBadRequest() throws {
        try tester.test(.POST, "/api/products", beforeRequest: { req in
            try req.content.encode(["field": "no value"])
        }) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }

    func testGetProduct() async throws {
        try tester.test(.GET, "/api/products/64AD150F-A5EA-4D12-86EB-DBC322A13BFA") { res in
            XCTAssertEqual(res.status, .ok)
            let productDto = try res.content.decode(ProductDto.self)

            XCTAssertEqual(productDto, ProductDto(id: UUID(uuidString: "64AD150F-A5EA-4D12-86EB-DBC322A13BFA")!, name: "Apple", description: "An apple description.", price: 2.99, categoryId: UUID(uuidString: "29E2FF92-C35A-48E9-8E77-422FE69EFE42")!, vendorId: UUID(uuidString: "C993142B-3525-4DCD-A73E-8B58864BC943")!))
        }
    }

    func testGetProductInvalidId() async throws {
        try tester.test(.GET, "/api/products/invalid_id_format") { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertEqual(res.content["reason"], "Invalid id format")
        }
    }

    func testGetProductProductNotFound() async throws {
        try tester.test(.GET, "/api/products/E621E1F8-C36C-495A-93FC-0C247A3E6E5F") { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertEqual(res.content["reason"], "Product not found")
        }
    }

    func testDeleteProduct() async throws {
        let productsCountPre = try await Product.query(on: app.db).count()

        try await tester.test(.DELETE, "/api/products/64AD150F-A5EA-4D12-86EB-DBC322A13BFA") { res in
            XCTAssertEqual(res.status, .ok)

            let productsCountPost = try await Product.query(on: app.db).count()
            XCTAssertEqual(productsCountPre - 1, productsCountPost)
        }
    }

    func testDeleteProductInvalidId() async throws {
        try tester.test(.DELETE, "/api/products/invalid_id_format") { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertEqual(res.content["reason"], "Invalid id format")
        }
    }

    func testDeleteProductProductNotFound() async throws {
        try tester.test(.DELETE, "/api/products/E621E1F8-C36C-495A-93FC-0C247A3E6E5F") { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertEqual(res.content["reason"], "Product not found")
        }
    }

    func testUpdateProduct() async throws {
        let update = CreateProductDto(name: "Cashew Nuts", description: "Some new description", price: 3.99, categoryId: UUID(uuidString: "29E2FF92-C35A-48E9-8E77-422FE69EFE42")!, vendorId: UUID(uuidString: "C993142B-3525-4DCD-A73E-8B58864BC943")!)
        try tester.test(.PUT, "/api/products/64AD150F-A5EA-4D12-86EB-DBC322A13BFA", beforeRequest: { req in
            try req.content.encode(update)
        }) { res in
            XCTAssertEqual(res.status, .ok)
            let productDto = try res.content.decode(ProductDto.self)

            XCTAssertEqual(productDto, ProductDto(id: UUID(uuidString: "64AD150F-A5EA-4D12-86EB-DBC322A13BFA")!, name: "Cashew Nuts", description: "Some new description", price: 3.99, categoryId: UUID(uuidString: "29E2FF92-C35A-48E9-8E77-422FE69EFE42")!, vendorId: UUID(uuidString: "C993142B-3525-4DCD-A73E-8B58864BC943")!))
        }
    }

    func testUpdateProductRemoveVendor() async throws {
        let update = CreateProductDto(name: "Cashew Nuts", description: "Some new description", price: 3.99, categoryId: UUID(uuidString: "29E2FF92-C35A-48E9-8E77-422FE69EFE42")!, vendorId: nil)
        try tester.test(.PUT, "/api/products/64AD150F-A5EA-4D12-86EB-DBC322A13BFA", beforeRequest: { req in
            try req.content.encode(update)
        }) { res in
            XCTAssertEqual(res.status, .ok)
            let productDto = try res.content.decode(ProductDto.self)

            XCTAssertEqual(productDto, ProductDto(id: UUID(uuidString: "64AD150F-A5EA-4D12-86EB-DBC322A13BFA")!, name: "Cashew Nuts", description: "Some new description", price: 3.99, categoryId: UUID(uuidString: "29E2FF92-C35A-48E9-8E77-422FE69EFE42")!, vendorId: nil))
        }
    }

    func testUpdateProductInvalidId() async throws {
        try tester.test(.PUT, "/api/products/invalid_id_format") { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertEqual(res.content["reason"], "Invalid id format")
        }
    }

    func testUpdateProductProductNotFound() async throws {
        let update = CreateProductDto(name: "Fruits2", description: "Some description", price: 0.99)
        try tester.test(.PUT, "/api/products/E621E1F8-C36C-495A-93FC-0C247A3E6E5F", beforeRequest: { req in
            try req.content.encode(update)
        }) { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertEqual(res.content["reason"], "Product not found")
        }
    }

    func testUpdateProductBadRequest() async throws {
        try tester.test(.PUT, "/api/products/E621E1F8-C36C-495A-93FC-0C247A3E6E5F", beforeRequest: { req in
            try req.content.encode(["invalid_field": "invalid_value"])
        }) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }

    func testGetPhoto() async throws {
        try tester.test(.GET, "/api/products/64AD150F-A5EA-4D12-86EB-DBC322A13BFA/photo") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.headers["content-type"][0], "image/jpg")
            XCTAssertEqual(res.body.readableBytes, 647685)

            let data = Data(buffer: res.body)
            guard let image = CIImage(data: data) else {
                XCTFail()
                return
            }

            XCTAssertEqual(image.extent.width, 1920)
            XCTAssertEqual(image.extent.height, 1920)

        }
    }

    func testDeletePhoto() async throws {
        try await tester.test(.DELETE, "/api/products/64AD150F-A5EA-4D12-86EB-DBC322A13BFA/photo") { res in
            XCTAssertEqual(res.status, .ok)

            guard let product = try await Product.find(UUID(uuidString: "64AD150F-A5EA-4D12-86EB-DBC322A13BFA")!, on: app.db) else {
                XCTFail()
                return
            }

            XCTAssertNil(product.photo)
        }
    }

    func testPostPhoto() async throws {
        let product = Product()
        product.fill(with: CreateProductDto(name: "Product Test", description: "Some description", price: 0.99))
        try await product.save(on: app.db)

        try tester.test(.POST, "/api/products/\(try product.requireID())/photo", beforeRequest: { req in
            let imageUrl = Bundle.module.url(forResource: "Example Data/Images/bananas.jpg", withExtension: nil)!
            let data = try! Data(contentsOf: imageUrl)
            req.body.writeData(data)
        }) { res in
            XCTAssertEqual(res.status, .ok)
        }

        guard let productPost = try await Product.find(product.requireID(), on: app.db) else {
            XCTFail()
            return
        }
        XCTAssertEqual(productPost.name, "Product Test")

        guard let data = productPost.photo, let image = CIImage(data: data) else {
            XCTFail()
            return
        }

        XCTAssertEqual(image.extent.width, 1920)
        XCTAssertEqual(image.extent.height, 1277)
    }

    func testPostPhotoInvalidProductId() async throws {
        try tester.test(.POST, "/api/products/E621E1F8-C36C-495A-93FC-0C247A3E6E5F/photo") { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertEqual(res.content["reason"], "Product not found")
        }
    }

    func testPostPhotoNoData() async throws {
        try tester.test(.POST, "/api/products/64AD150F-A5EA-4D12-86EB-DBC322A13BFA/photo", beforeRequest: { req in

        }) { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertEqual(res.content["reason"], "No image data given")
        }
    }

    func testPostPhotoInvalidData() async throws {
        let product = Product()
        product.fill(with: CreateProductDto(name: "Product Test", description: "Some description", price: 0.99))
        try await product.save(on: app.db)

        try tester.test(.POST, "/api/products/\(try product.requireID())/photo", beforeRequest: { req in
            let data = "Hallo".data(using: .utf8)!
            req.body.writeData(data)
        }) { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertEqual(res.content["reason"], "Unable to convert data to image")
        }
    }
}
