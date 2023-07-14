//
//  CategoryListView.swift
//  ProductApp
//
//  Created by Najmi Antariksa on 20.06.23.
//

import SwiftUI

struct CategoryListView: View {
    @State var categories: [CategoryDTO] = []
    
    @State var page = 2
    
    private var per = 5
    
    var body: some View {
        NavigationView {
            List {
                ForEach(categories) { category in
                    NavigationLink(destination: CategoryDetail(category: category)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(category.name).font(.title2)
                            }
                        }
                        .onAppear {
                            if hasReachedEnd(of: category) {
                                Task {
                                    await loadMoreCategories()
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Categories")
        }
        .onAppear {
            Task {
                self.categories = []
                let getCategories = URL(string: "http://127.0.0.1:8080/api/categories?page=\(1)&per=\(10)")
                let (data, _) = try! await URLSession.shared.data(from: getCategories!)
                let categoriesDTO = try! JSONDecoder().decode(
                    CategoriesDTO.self,
                from: data
                )
                self.categories = categoriesDTO.categories
                page = 2
            }
        }
    }
    
    func loadMoreCategories() async {
        page += 1
        
        let loadMore = URL(string: "http://127.0.0.1:8080/api/categories?page=\(page)&per=\(per)")
        let (data, _) = try! await URLSession.shared.data(from: loadMore!)
        let categoriesDTO = try! JSONDecoder().decode(
            CategoriesDTO.self,
        from: data
        )
        self.categories += categoriesDTO.categories
    }
    
    func hasReachedEnd(of category: CategoryDTO) -> Bool {
        return categories.last?.id == category.id
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
