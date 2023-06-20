//
//  DemoDataGenerator.swift
//  
//
//  Created by Samuel Schepp on 23.03.23.
//

import Foundation
import FluentKit
import Vapor

class DemoDataGenerator {
    private let app: Application

    init(app: Application) {
        self.app = app
    }

    var shouldGenerateDemoData: Bool {
        get async throws {
            let productCount = try await Product.query(on: app.db).count()
            if productCount > 0 {
                return false
            }

            let categoryCount = try await Category.query(on: app.db).count()
            if categoryCount > 0 {
                return false
            }

            let vendorCount = try await Vendor.query(on: app.db).count()
            if vendorCount > 0 {
                return false
            }

            return true
        }
    }

    func generateDemoDataIfNeeded() async throws {
        if try await !shouldGenerateDemoData {
            app.logger.debug("Will skip creation of demo data.")
            return
        }
        app.logger.debug("Will create demo data.")

        let products = try loadDemoProducts()

        for product in products {
            let model = map(dto: product)

            if let foundCategory = try await Category.query(on: app.db).filter(\.$name == product.classification).first() {
                model.$category.id = try foundCategory.requireID()
            } else {
                let newCategory = Category()
                newCategory.fill(with: CreateCategoryDto(name: product.classification))
                try await newCategory.save(on: app.db)
                model.$category.id = try newCategory.requireID()
            }

            if let foundVendor = try await Vendor.query(on: app.db).filter(\.$name == product.vendor).first() {
                model.$vendor.id = try foundVendor.requireID()
            } else {
                let newVendor = Vendor()
                newVendor.fill(with: CreateVendorDto(name: product.vendor))
                try await newVendor.save(on: app.db)
                model.$vendor.id = try newVendor.requireID()
            }

            if let imageFileName = product.imageFileName {
                guard let url = Bundle.module.url(forResource: "Example Data/Images/\(imageFileName)", withExtension: nil) else {
                    app.logger.error("Unable to load image for product \(product.title)")
                    continue
                }
                let data = try Data(contentsOf: url)
                model.photo = data
            }

            try await model.save(on: app.db)
        }
    }

    private func loadDemoProducts() throws -> [DemoDataProductDto] {
        let jsonUrl = Bundle.module.url(forResource: "Example Data/products.json", withExtension: nil)!
        let jsonData = try Data(contentsOf: jsonUrl)
        let data = try JSONDecoder().decode(Array<DemoDataProductDto>.self, from: jsonData)
        return data
    }

    private func map(dto: DemoDataProductDto) -> Product {
        let product = Product()
        product.name = dto.title
        product.description = dto.description
        product.price = dto.price
        return product
    }
}
