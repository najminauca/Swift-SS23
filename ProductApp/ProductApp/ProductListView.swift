//
//  ProductListView.swift
//  ProductApp
//
//  Created by Najmi Antariksa on 20.06.23.
//

import SwiftUI
import UIKit
import AVFoundation

struct ProductListView: View {
    @State var products: [ProductDTO] = []
    @State var page = 2
    
    private var per = 5
    
    var body: some View {
        
        NavigationView {
            GeometryReader { proxy in
                List {
                    ForEach(products) { product in
                        NavigationLink(destination: ProductDetail(product: product)) {
                            HStack {
                                ProductPic(productId: product.id, width: proxy.size.width * 0.3, height: proxy.size.height * 0.15)
                                VStack(alignment: .leading) {
                                    Text(product.name).font(.title2)
                                    Text("$"+product.price.description).foregroundColor(.secondary)
                                }
                            }
                            .task {
                                if hasReachedEnd(of: product) {
                                    await loadMoreProducts()
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Products")
            }
        }
        .task {
            let getProducts = URL(string: "http://127.0.0.1:8080/api/products?page=\(1)&per=\(10)")
            let (data, _) = try! await URLSession.shared.data(from: getProducts!)
            let productsDTO = try! JSONDecoder().decode(
                ProductsDTO.self,
            from: data
            )
            self.products = productsDTO.products
            page = 2
        }
    }
    
    func loadMoreProducts() async {
        page += 1
        
        let loadMore = URL(string: "http://127.0.0.1:8080/api/products?page=\(page)&per=\(per)")
        let (data, _) = try! await URLSession.shared.data(from: loadMore!)
        let productsDTO = try! JSONDecoder().decode(
            ProductsDTO.self,
        from: data
        )
        self.products += productsDTO.products
    }
    
    func hasReachedEnd(of product: ProductDTO) -> Bool {
        return products.last?.id == product.id
    }
}

struct ProductPic: View {
    @State var productId: String?
    @State var photoData: UIImage? = nil
    @State var width: CGFloat
    @State var height: CGFloat
    
    var body: some View {
        VStack {
            if let photoData = photoData {
                Image(uiImage: photoData)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .clipped()
                    .cornerRadius(10)
                
            } else {
                Image(uiImage: UIImage(systemName: "eye.slash")!).resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: width, height: height)
                    .cornerRadius(10)
            }
        }
        .task {
            let url = URL(string: "http://127.0.0.1:8080/api/products/\(self.productId ?? "")/photo")
            do {
                let (data, _) = try await URLSession.shared.data(from: url!)
                self.photoData = UIImage(data: data)
            } catch {
                print("Photo couldn't be loaded.")
            }
        }
    }
}

struct ProductDetail: View {
    @State var product: ProductDTO
    @State var vendor: VendorDTO? = nil
    @State var category: CategoryDTO? = nil
    @State var sheetOpen: Bool = false
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 15) {
                    ProductPic(productId: product.id, width: proxy.size.width - 40, height: proxy.size.height * 0.35)
                    HStack {
                        Text("$\(product.price.description)")
                            .font(.title2)
                            .foregroundColor(Color.secondary)
                        Spacer()
                        NavigationLink(category?.name ?? "") {
                            CategoryDetail(category: category)
                        }.font(.title3)
                    }
                    
                    Text(product.description)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        NavigationLink(destination: VendorDetail(vendor: vendor)) {
                            Label(vendor?.name ?? "", systemImage: "person.fill")
                        }
                        Spacer()
                        
                    }
                }
            }
            .navigationTitle(product.name)
            .navigationBarTitleDisplayMode(.inline)
            .padding(.horizontal)
            .task {
                //Get Vendor
                let vendorURL = URL(string: "http://127.0.0.1:8080/api/vendors/\(product.vendorId)")
    //            vendorlink?.path = "/" + product.vendorId
                let (vendorData, _) = try! await URLSession.shared.data(from: vendorURL!)
                self.vendor = try! JSONDecoder().decode(
                    VendorDTO.self,
                from: vendorData
                )
                
                //Get Category
                let catURL = URL(string: "http://127.0.0.1:8080/api/categories/\(product.categoryId)")
                let (catData, _) = try! await URLSession.shared.data(from: catURL!)
                self.category = try! JSONDecoder().decode(
                    CategoryDTO.self,
                from: catData
                )
            }
        }
        
    }
    
}

//struct ProductListView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProductListView()
//    }
//}
