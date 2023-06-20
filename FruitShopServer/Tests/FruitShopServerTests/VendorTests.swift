import Vapor
import XCTVapor
import XCTest
@testable import FruitShopServer

final class VendorTests: XCTestCase {
    var tester: XCTApplicationTester!
    var app: Application!

    override func setUp() async throws {
        (tester, app) = try await createTestEnvironment()
    }

    override func tearDown() async throws {
        app.shutdown()
    }

    func testGetAllVendors() throws {
        try tester.test(.GET, "/api/vendors") { res in
            XCTAssertEqual(res.status, .ok)
            let vendors = try res.content.decode(VendorsDto.self)
            XCTAssertEqual(vendors.page.page, 1)
            XCTAssertEqual(vendors.page.pageCount, 1)
            XCTAssertEqual(vendors.page.total, 1)
            XCTAssertEqual(vendors.page.per, 10)

            guard let vendor = vendors.vendors.first else {
                XCTFail()
                return
            }

            XCTAssertEqual(vendor, VendorDto(id: UUID(uuidString: "C993142B-3525-4DCD-A73E-8B58864BC943")!, name: "Orchard Delights", productsCount: 1))
        }
    }

    func testGetAllVendorsPaginated() async throws {
        try await Vendor.query(on: app.db).delete()
        for i in 0..<7 {
            let vendor = Vendor()
            vendor.id = UUID(uuidString: "80C3A122-B375-4800-BA49-99521495568\(i)")
            vendor.name = "Vendor \(i)"
            try await vendor.save(on: app.db)
        }

        try tester.test(.GET, "/api/vendors", beforeRequest: { req in
            try req.query.encode([
                "page": 2,
                "per": 2,
            ])
        }) { res in
            XCTAssertEqual(res.status, .ok)
            let vendors = try res.content.decode(VendorsDto.self)
            XCTAssertEqual(vendors.vendors.count, 2)
            XCTAssertEqual(vendors.page.page, 2)
            XCTAssertEqual(vendors.page.pageCount, 4)
            XCTAssertEqual(vendors.page.total, 7)
            XCTAssertEqual(vendors.page.per, 2)

            if vendors.vendors.count != 2 {
                XCTFail()
                return
            }

            let vendors1 = vendors.vendors[0]
            let vendors2 = vendors.vendors[1]

            XCTAssertEqual(vendors1, VendorDto(id: UUID(uuidString: "80C3A122-B375-4800-BA49-995214955682")!, name: "Vendor 2", productsCount: 0))
            XCTAssertEqual(vendors2, VendorDto(id: UUID(uuidString: "80C3A122-B375-4800-BA49-995214955683")!, name: "Vendor 3", productsCount: 0))

        }
    }

    func testCreateVendor() async throws {
        let createDto = CreateVendorDto(name: "Other")
        try await tester.test(.POST, "/api/vendors", beforeRequest: { req in
            try req.content.encode(createDto)
        }) { res in
            XCTAssertEqual(res.status, .ok)
            let vendor = try res.content.decode(VendorDto.self)

            XCTAssertEqual(vendor, VendorDto(id: vendor.id, name: "Other", productsCount: 0))

            let count = try await Vendor.query(on: app.db).count()
            XCTAssertEqual(count, 2)
        }
    }

    func testCreateVendorBadRequest() throws {
        try tester.test(.POST, "/api/vendors", beforeRequest: { req in
            try req.content.encode(["field": "no value"])
        }) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }

    func testGetVendor() async throws {
        try tester.test(.GET, "/api/vendors/C993142B-3525-4DCD-A73E-8B58864BC943") { res in
            XCTAssertEqual(res.status, .ok)
            let vendorDto = try res.content.decode(VendorDto.self)
            XCTAssertEqual(vendorDto, VendorDto(id: UUID(uuidString: "C993142B-3525-4DCD-A73E-8B58864BC943")!, name: "Orchard Delights", productsCount: 1))
        }
    }

    func testGetVendorInvalidId() async throws {
        try tester.test(.GET, "/api/vendors/invalid_id_format") { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertEqual(res.content["reason"], "Invalid id format")
        }
    }

    func testGetVendorVendorNotFound() async throws {
        try tester.test(.GET, "/api/vendors/E621E1F8-C36C-495A-93FC-0C247A3E6E5F") { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertEqual(res.content["reason"], "Vendor not found")
        }
    }

    func testDeleteVendor() async throws {
        let vendorCountPre = try await Vendor.query(on: app.db).count()

        try await tester.test(.DELETE, "/api/vendors/C993142B-3525-4DCD-A73E-8B58864BC943") { res in
            XCTAssertEqual(res.status, .ok)

            let vendorCountPost = try await Vendor.query(on: app.db).count()
            XCTAssertEqual(vendorCountPre - 1, vendorCountPost)
        }
    }

    func testDeleteVendorInvalidId() async throws {
        try tester.test(.DELETE, "/api/vendors/invalid_id_format") { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertEqual(res.content["reason"], "Invalid id format")
        }
    }

    func testDeleteVendorVendorNotFound() async throws {
        try tester.test(.DELETE, "/api/vendors/E621E1F8-C36C-495A-93FC-0C247A3E6E5F") { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertEqual(res.content["reason"], "Vendor not found")
        }
    }

    func testUpdateVendor() async throws {
        let update = CreateVendorDto(name: "Exotic Fruits Company")
        try tester.test(.PUT, "/api/vendors/C993142B-3525-4DCD-A73E-8B58864BC943", beforeRequest: { req in
            try req.content.encode(update)
        }) { res in
            XCTAssertEqual(res.status, .ok)
            let vendorDto = try res.content.decode(VendorDto.self)
            XCTAssertEqual(vendorDto, VendorDto(id: UUID(uuidString: "C993142B-3525-4DCD-A73E-8B58864BC943")!, name: "Exotic Fruits Company", productsCount: 1))
        }
    }

    func testUpdateVendorInvalidId() async throws {
        try tester.test(.PUT, "/api/vendors/invalid_id_format") { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertEqual(res.content["reason"], "Invalid id format")
        }
    }

    func testUpdateVendorVendorNotFound() async throws {
        let update = CreateVendorDto(name: "Fruits2")
        try tester.test(.PUT, "/api/vendors/E621E1F8-C36C-495A-93FC-0C247A3E6E5F", beforeRequest: { req in
            try req.content.encode(update)
        }) { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertEqual(res.content["reason"], "Vendor not found")
        }
    }

    func testUpdateVendorBadRequest() async throws {
        try tester.test(.PUT, "/api/vendors/E621E1F8-C36C-495A-93FC-0C247A3E6E5F", beforeRequest: { req in
            try req.content.encode(["invalid_field": "invalid_value"])
        }) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
}
