//
//  VendorController.swift
//  
//
//  Created by Samuel Schepp on 20.03.23.
//

import Foundation
import Fluent
import Vapor
import VaporToOpenAPI

class VendorController {
    let app: Application

    init(app: Application) {
        self.app = app
    }

    func register(router: RoutesBuilder) {
        router.group("vendors") { group in
            group.get() { req -> VendorsDto in
                let page = try await Vendor.query(on: self.app.db).sort(\.$name).paginate(for: req)
                let vendorsDto = try await self.createDto(page: page)
                return vendorsDto
            }
            .openAPI(
                tags: ["Vendors"],
                summary: "Get vendors",
                query: PageRequestDto.self,
                response: VendorsDto.self
            )

            group.post() { request -> VendorDto in
                let createDto = try request.content.decode(CreateVendorDto.self)
                let vendor = Vendor.from(createDto: createDto)
                try await vendor.save(on: self.app.db)
                let vendorDto = try await self.createDto(vendor: vendor)
                return vendorDto
            }
            .openAPI(
                tags: ["Vendors"],
                summary: "Create a vendor",
                body: CreateVendorDto.self,
                response: VendorDto.self
            )

            group.get(":id") { request -> VendorDto in
                let id = try request.requireID()
                guard let vendor = try await Vendor.query(on: self.app.db).filter(\Vendor.$id == id).first() else {
                    throw Abort(.notFound, reason: "Vendor not found")
                }
                let vendorDto = try await self.createDto(vendor: vendor)
                return vendorDto
            }
            .openAPI(
                tags: ["Vendors"],
                summary: "Get a vendor",
                response: VendorDto.self
            )

            group.delete(":id") { request -> VendorDto in
                let id = try request.requireID()
                guard let vendor = try await Vendor.query(on: self.app.db).filter(\Vendor.$id == id).first() else {
                    throw Abort(.notFound, reason: "Vendor not found")
                }
                try await vendor.delete(on: self.app.db)
                let vendorDto = try await self.createDto(vendor: vendor)
                return vendorDto
            }
            .openAPI(
                tags: ["Vendors"],
                summary: "Get a vendor",
                response: VendorDto.self
            )

            group.put(":id") { request -> VendorDto in
                let id = try request.requireID()
                let createDto = try request.content.decode(CreateVendorDto.self)
                guard let vendor = try await Vendor.query(on: self.app.db).filter(\Vendor.$id == id).first() else {
                    throw Abort(.notFound, reason: "Vendor not found")
                }
                vendor.fill(with: createDto)
                try await vendor.save(on: self.app.db)
                let vendorDto = try await self.createDto(vendor: vendor)
                return vendorDto
            }
            .openAPI(
                tags: ["Vendors"],
                summary: "Update a vendor",
                body: CreateVendorDto.self,
                response: VendorDto.self
            )
        }
    }

    private func createDto(vendor: Vendor) async throws -> VendorDto {
        let productCount = try await Product.query(on: app.db)
            .join(Vendor.self, on: \Product.$vendor.$id == \Vendor.$id)
            .filter(Vendor.self, \.$id == vendor.requireID())
            .count()

        return VendorDto(id: try vendor.requireID(), name: vendor.name, productsCount: productCount)
    }

    private func createDto(page: Page<Vendor>) async throws -> VendorsDto {
        var vendorDtos: [VendorDto] = []

        for vendor in page.items {
            vendorDtos.append(try await createDto(vendor: vendor))
        }

        return VendorsDto(vendors: vendorDtos, page: PageMetadataDto.from(pageMetadata: page.metadata))
    }
}
