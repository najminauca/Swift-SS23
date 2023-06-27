//
//  CategoryListView.swift
//  ProductApp
//
//  Created by Najmi Antariksa on 20.06.23.
//

import SwiftUI

struct CategoryListView: View {
    @State var categories: [CategoryDTO] = []
    var body: some View {
        NavigationView {
            List {
                ForEach(categories) { category in
                    NavigationLink(destination: CategoryDetail(category: category)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(category.name)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Categories")
        }
        .task {
            let getCategories = URL(string: "http://127.0.0.1:8080/api/categories")
            let (data, _) = try! await URLSession.shared.data(from: getCategories!)
            let categoriesDTO = try! JSONDecoder().decode(
                CategoriesDTO.self,
            from: data
            )
            self.categories = categoriesDTO.categories
        }
    }
}

struct CategoryDetail: View {
    @State var category: CategoryDTO
    @State var products: [ProductDTO] = []
    
    var body: some View {
        GeometryReader { proxy in
            List {
                VStack {
                    if category.productsCount > 1 {
                        Text("There are **\(category.productsCount)** products being sold in **\(category.name)**.").font(.title3)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    } else {
                        Text("There is **\(category.productsCount)** product being sold in **\(category.name)**.").font(.title3)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    }
                }
                ForEach(products) { product in
                    NavigationLink(destination: ProductDetail(productID: product.id, showCategoryLink: false)) {
                        HStack {
                            ProductPic(productID: product.id, width: proxy.size.width * 0.3, height: proxy.size.height * 0.15)
                            VStack(alignment: .leading) {
                                Text(product.name).font(.title2)
                                Text(product.price.formatted(.currency(code: "USD"))).foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle(category.name)
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            var page = 1
            if category.productsCount > 0 {
                while self.products.count != category.productsCount {
                    let getProducts = URL(string: "http://127.0.0.1:8080/api/products?page=\(page)&per=\(10)")
                    let (data, _) = try! await URLSession.shared.data(from: getProducts!)
                    let productsDTO = try! JSONDecoder().decode(
                        ProductsDTO.self,
                    from: data
                    )
                    self.products += productsDTO.products.filter {
                        $0.categoryId == category.id
                    }
                    page += 1
                }
            }
            
        }
    }
}

//struct CategoryListView_Previews: PreviewProvider {
//    static var previews: some View {
//        CategoryListView()
//    }
//}
