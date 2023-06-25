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
    @State var category: CategoryDTO?
    @State var products: [ProductDTO] = []
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("There is **\(category!.productsCount)** product(s) being sold in **\(category!.name)**.").font(.title3)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
        .navigationTitle(category!.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

//struct CategoryListView_Previews: PreviewProvider {
//    static var previews: some View {
//        CategoryListView()
//    }
//}
