import Vapor
import XCTVapor
import XCTest
@testable import FruitShopServer

final class CategoryTests: XCTestCase {
    var tester: XCTApplicationTester!
    var app: Application!

    override func setUp() async throws {
        (tester, app) = try await createTestEnvironment()
    }

    override func tearDown() async throws {
        app.shutdown()
    }

    func testGetAllCategories() throws {
        try tester.test(.GET, "/api/categories") { res in
            XCTAssertEqual(res.status, .ok)
            let categories = try res.content.decode(CategoriesDto.self)
            XCTAssertEqual(categories.page.page, 1)
            XCTAssertEqual(categories.page.pageCount, 1)
            XCTAssertEqual(categories.page.total, 1)
            XCTAssertEqual(categories.page.per, 10)

            guard let category = categories.categories.first else {
                XCTFail()
                return
            }

            XCTAssertEqual(category, CategoryDto(id: UUID(uuidString: "29E2FF92-C35A-48E9-8E77-422FE69EFE42")!, name: "Pome fruit", productsCount: 1))
        }
    }

    func testGetAllCategoriesPaginated() async throws {
        try await Category.query(on: app.db).delete()
        for i in 0..<7 {
            let category = Category()
            category.id = UUID(uuidString: "80C3A122-B375-4800-BA49-99521495568\(i)")
            category.name = "Category \(i)"
            try await category.save(on: app.db)
        }

        try tester.test(.GET, "/api/categories", beforeRequest: { req in
            try req.query.encode([
                "page": 2,
                "per": 2,
            ])
        }) { res in
            XCTAssertEqual(res.status, .ok)
            let categories = try res.content.decode(CategoriesDto.self)
            XCTAssertEqual(categories.categories.count, 2)
            XCTAssertEqual(categories.page.page, 2)
            XCTAssertEqual(categories.page.pageCount, 4)
            XCTAssertEqual(categories.page.total, 7)
            XCTAssertEqual(categories.page.per, 2)

            if categories.categories.count != 2 {
                XCTFail()
                return
            }

            let category1 = categories.categories[0]
            let category2 = categories.categories[1]

            XCTAssertEqual(category1, CategoryDto(id: UUID(uuidString: "80C3A122-B375-4800-BA49-995214955682")!, name: "Category 2", productsCount: 0))
            XCTAssertEqual(category2, CategoryDto(id: UUID(uuidString: "80C3A122-B375-4800-BA49-995214955683")!, name: "Category 3", productsCount: 0))

        }
    }

    func testCreateCategory() async throws {
        let createDto = CreateCategoryDto(name: "Other")
        try await tester.test(.POST, "/api/categories", beforeRequest: { req in
            try req.content.encode(createDto)
        }) { res in
            XCTAssertEqual(res.status, .ok)
            let categoryDto = try res.content.decode(CategoryDto.self)

            XCTAssertEqual(categoryDto, CategoryDto(id: categoryDto.id, name: "Other", productsCount: 0))

            let count = try await Category.query(on: app.db).count()
            XCTAssertEqual(count, 2)
        }
    }

    func testCreateCategoryBadRequest() throws {
        try tester.test(.POST, "/api/categories", beforeRequest: { req in
            try req.content.encode(["field": "no value"])
        }) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }

    func testGetCategory() async throws {
        try tester.test(.GET, "/api/categories/29E2FF92-C35A-48E9-8E77-422FE69EFE42") { res in
            XCTAssertEqual(res.status, .ok)
            let categoryDto = try res.content.decode(CategoryDto.self)
            XCTAssertEqual(categoryDto, CategoryDto(id: UUID(uuidString: "29E2FF92-C35A-48E9-8E77-422FE69EFE42")!, name: "Pome fruit", productsCount: 1))
        }
    }

    func testGetCategoryInvalidId() async throws {
        try tester.test(.GET, "/api/categories/invalid_id_format") { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertEqual(res.content["reason"], "Invalid id format")
        }
    }

    func testGetCategoryCategoryNotFound() async throws {
        try tester.test(.GET, "/api/categories/E621E1F8-C36C-495A-93FC-0C247A3E6E5F") { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertEqual(res.content["reason"], "Category not found")
        }
    }

    func testDeleteCategory() async throws {
        let categoriesCountPre = try await Category.query(on: app.db).count()

        try await tester.test(.DELETE, "/api/categories/29E2FF92-C35A-48E9-8E77-422FE69EFE42") { res in
            XCTAssertEqual(res.status, .ok)

            let categoriesCountPost = try await Category.query(on: app.db).count()
            XCTAssertEqual(categoriesCountPre - 1, categoriesCountPost)
        }
    }

    func testDeleteCategoryInvalidId() async throws {
        try tester.test(.DELETE, "/api/categories/invalid_id_format") { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertEqual(res.content["reason"], "Invalid id format")
        }
    }

    func testDeleteCategoryCategoryNotFound() async throws {
        try tester.test(.DELETE, "/api/categories/E621E1F8-C36C-495A-93FC-0C247A3E6E5F") { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertEqual(res.content["reason"], "Category not found")
        }
    }

    func testUpdateCategory() async throws {
        let update = CreateCategoryDto(name: "Berries")
        try tester.test(.PUT, "/api/categories/29E2FF92-C35A-48E9-8E77-422FE69EFE42", beforeRequest: { req in
            try req.content.encode(update)
        }) { res in
            let categoryDto = try res.content.decode(CategoryDto.self)
            XCTAssertEqual(res.status, .ok)
            
            XCTAssertEqual(categoryDto, CategoryDto(id: UUID(uuidString: "29E2FF92-C35A-48E9-8E77-422FE69EFE42")!, name: "Berries", productsCount: 1))
        }
    }

    func testUpdateCategoryInvalidId() async throws {
        try tester.test(.PUT, "/api/categories/invalid_id_format") { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertEqual(res.content["reason"], "Invalid id format")
        }
    }

    func testUpdateCategoryCategoryNotFound() async throws {
        let update = CreateCategoryDto(name: "Fruits2")
        try tester.test(.PUT, "/api/categories/E621E1F8-C36C-495A-93FC-0C247A3E6E5F", beforeRequest: { req in
            try req.content.encode(update)
        }) { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertEqual(res.content["reason"], "Category not found")
        }
    }

    func testUpdateCategoryBadRequest() async throws {
        try tester.test(.PUT, "/api/categories/E621E1F8-C36C-495A-93FC-0C247A3E6E5F", beforeRequest: { req in
            try req.content.encode(["invalid_field": "invalid_value"])
        }) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
}
