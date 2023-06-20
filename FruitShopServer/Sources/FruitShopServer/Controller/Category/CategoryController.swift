import Fluent
import Foundation
import Vapor
import VaporToOpenAPI

class CategoryController {
    let app: Application

    init(app: Application) {
        self.app = app
    }

    func register(router: RoutesBuilder) {
        router.group("categories") { group in
            group.get() { req -> CategoriesDto in
                let page = try await Category.query(on: self.app.db).sort(\.$name).paginate(for: req)
                let categoriesDto = try await self.createDto(page: page)
                return categoriesDto
            }
            .openAPI(
                tags: ["Categories"],
                summary: "Get categories",
                query: PageRequestDto.self,
                response: CategoriesDto.self
            )

            group.post() { request -> CategoryDto in
                let createDto = try request.content.decode(CreateCategoryDto.self)
                let category = Category.from(createDto: createDto)
                try await category.save(on: self.app.db)
                let categoryDto = try await self.createDto(category: category)
                return categoryDto
            }
            .openAPI(
                tags: ["Categories"],
                summary: "Create a category",
                body: CreateCategoryDto.self,
                response: CategoryDto.self
            )

            group.get(":id") { request -> CategoryDto in
                let id = try request.requireID()
                guard let category = try await Category.query(on: self.app.db).filter(\Category.$id == id).first() else {
                    throw Abort(.notFound, reason: "Category not found")
                }
                let categoryDto = try await self.createDto(category: category)
                return categoryDto
            }
            .openAPI(
                tags: ["Categories"],
                summary: "Get a category",
                response: CategoryDto.self
            )

            group.delete(":id") { request -> CategoryDto in
                let id = try request.requireID()
                guard let category = try await Category.query(on: self.app.db).filter(\Category.$id == id).first() else {
                    throw Abort(.notFound, reason: "Category not found")
                }
                try await category.delete(on: self.app.db)
                let categoryDto = try await self.createDto(category: category)
                return categoryDto
            }
            .openAPI(
                tags: ["Categories"],
                summary: "Delete a category",
                response: CategoryDto.self
            )

            group.put(":id") { request -> CategoryDto in
                let id = try request.requireID()
                let createDto = try request.content.decode(CreateCategoryDto.self)
                guard let category = try await Category.query(on: self.app.db).filter(\Category.$id == id).first() else {
                    throw Abort(.notFound, reason: "Category not found")
                }
                category.fill(with: createDto)
                try await category.save(on: self.app.db)
                let categoryDto = try await self.createDto(category: category)
                return categoryDto
            }
            .openAPI(
                tags: ["Categories"],
                summary: "Update a category",
                body: CreateCategoryDto.self,
                response: CategoryDto.self
            )
        }
    }

    private func createDto(category: Category) async throws -> CategoryDto {
        let productCount = try await Product.query(on: app.db)
            .join(Category.self, on: \Product.$category.$id == \Category.$id)
            .filter(Category.self, \.$id == category.requireID())
            .count()

        return CategoryDto(id: try category.requireID(), name: category.name, productsCount: productCount)
    }

    private func createDto(page: Page<Category>) async throws -> CategoriesDto {
        var categoryDtos: [CategoryDto] = []

        for category in page.items {
            categoryDtos.append(try await createDto(category: category))
        }

        return CategoriesDto(categories: categoryDtos, page: PageMetadataDto.from(pageMetadata: page.metadata))
    }
}
