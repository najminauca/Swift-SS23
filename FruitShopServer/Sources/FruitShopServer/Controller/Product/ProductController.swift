//
//  ProductController.swift
//  
//
//  Created by Samuel Schepp on 20.03.23.
//

import Foundation
import Fluent
import Vapor
import VaporToOpenAPI
import CoreImage

class ProductController {
    let app: Application

    init(app: Application) {
        self.app = app
    }

    func register(router: RoutesBuilder) {
        router.group("products") { group in
            group.group(":id", "photo") { photoGroup in
                photoGroup.on(.POST, body: .collect(maxSize: "10mb")) { request -> ProductDto in
                    let id = try request.requireID()
                    guard let product = try await Product.query(on: self.app.db).filter(\Product.$id == id).first() else {
                        throw Abort(.notFound, reason: "Product not found")
                    }
                    guard let dataBuffer = request.body.data else {
                        throw Abort(.badRequest, reason: "No image data given")
                    }

                    let data = Data(buffer: dataBuffer)
                    guard let _ = CIImage(data: data) else {
                        throw Abort(.badRequest, reason: "Unable to convert data to image")
                    }
                    product.photo = data
                    try await product.save(on: self.app.db)
                    let productDto = try ProductDto.from(product: product)
                    return productDto
                }
                .openAPI(
                    tags: ["Product Photo"],
                    summary: "Upload a product photo",
                    bodyType: .multipart(.formData),
                    response: ProductDto.self
                )

                photoGroup.get() { request -> Response in
                    let id = try request.requireID()
                    guard let product = try await Product.query(on: self.app.db).filter(\Product.$id == id).first() else {
                        throw Abort(.notFound, reason: "Product not found")
                    }
                    if let photo = product.photo {
                        let headers: HTTPHeaders = [
                            "content-type": "image/jpg"
                        ]
                        return Response(status: .ok, headers: headers, body: .init(data: photo))
                    } else {
                        return Response(status: .notFound)
                    }
                }
                .openAPI(
                    tags: ["Product Photo"],
                    summary: "Get a product photo"
                )

                photoGroup.delete() { request -> ProductDto in
                    let id = try request.requireID()
                    guard let product = try await Product.query(on: self.app.db).filter(\Product.$id == id).first() else {
                        throw Abort(.notFound, reason: "Product not found")
                    }
                    product.photo = nil
                    try await product.save(on: self.app.db)
                    let productDto = try ProductDto.from(product: product)
                    return productDto
                }
                .openAPI(
                    tags: ["Product Photo"],
                    summary: "Delete a product photo",
                    response: ProductDto.self
                )
            }

            group.get() { req -> ProductsDto in
                let page = try await Product.query(on: self.app.db).sort(\.$name).paginate(for: req)
                let productsDto = try ProductsDto.from(page: page)
                return productsDto
            }
            .openAPI(
                tags: ["Products"],
                summary: "Get products",
                query: PageRequestDto.self,
                bodyType: .application(.json),
                response: ProductsDto.self
            )

            group.post() { request -> ProductDto in
                let createDto = try request.content.decode(CreateProductDto.self)
                let product = Product.from(createDto: createDto)
                try await product.save(on: self.app.db)
                let productDto = try ProductDto.from(product: product)
                return productDto
            }
            .openAPI(
                tags: ["Products"],
                summary: "Create a product",
                body: CreateProductDto.self,
                response: ProductDto.self
            )

            group.get(":id") { request -> ProductDto in
                let id = try request.requireID()
                guard let product = try await Product.query(on: self.app.db).filter(\Product.$id == id).first() else {
                    throw Abort(.notFound, reason: "Product not found")
                }
                let productDto = try ProductDto.from(product: product)
                return productDto
            }
            .openAPI(
                tags: ["Products"],
                summary: "Get a product",
                response: ProductDto.self
            )

            group.delete(":id") { request -> ProductDto in
                let id = try request.requireID()
                guard let product = try await Product.query(on: self.app.db).filter(\Product.$id == id).first() else {
                    throw Abort(.notFound, reason: "Product not found")
                }
                try await product.delete(on: self.app.db)
                let productDto = try ProductDto.from(product: product)
                return productDto
            }
            .openAPI(
                tags: ["Products"],
                summary: "Delete a product",
                response: ProductDto.self
            )

            group.put(":id") { request -> ProductDto in
                let id = try request.requireID()
                let createDto = try request.content.decode(CreateProductDto.self)
                guard let product = try await Product.query(on: self.app.db).filter(\Product.$id == id).first() else {
                    throw Abort(.notFound, reason: "Product not found")
                }
                product.fill(with: createDto)
                try await product.save(on: self.app.db)
                let productDto = try ProductDto.from(product: product)
                return productDto
            }
            .openAPI(
                tags: ["Products"],
                summary: "Edit a product",
                body: CreateProductDto.self,
                response: ProductDto.self
            )
        }
    }
}
