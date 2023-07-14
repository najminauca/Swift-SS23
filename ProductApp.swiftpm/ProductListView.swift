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
                        NavigationLink(destination: ProductDetail(productID: product.id)) {
                            HStack {
                                ProductPic(productID: product.id, width: proxy.size.width * 0.3, height: proxy.size.height * 0.15)
                                VStack(alignment: .leading) {
                                    Text(product.name).font(.title2)
                                    Text(product.price.formatted(.currency(code: "USD"))).foregroundColor(.secondary)
                                }
                            }
                            .onAppear {
                                if hasReachedEnd(of: product) {
                                    Task {
                                        await loadMoreProducts()
                                    }
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Products")
            }
        }
        .onAppear {
            Task {
                self.products = []
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
    @State var productID: String
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
            let cache = getDocumentsDirectory().appendingPathComponent("\(productID).png")
            if FileManager.default.fileExists(atPath: cache.path) {
//                print("Loading \(productID).png from cache")
                self.photoData = UIImage(contentsOfFile: cache.path)
            } else {
                let url = URL(string: "http://127.0.0.1:8080/api/products/\(self.productID)/photo")
                do {
                    let (data, _) = try await URLSession.shared.data(from: url!)
                    self.photoData = UIImage(data: data)
                    if let photoData = photoData?.pngData() {
//                        print("Saving \(productID).png to cache")
                        try? photoData.write(to: cache)
                    }
                } catch {
                    print("Photo couldn't be loaded.")
                }
            }
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

struct ProductDetail: View {
    @EnvironmentObject private var databaseService: DatabaseService
    @State var productID: String
    @State var product: ProductDTO? = nil
    @State var vendor: VendorDTO? = nil
    @State var category: CategoryDTO? = nil
    @State var sheetOpen: Bool = false
    @State var showVendorLink: Bool = true
    @State var showCategoryLink: Bool = true
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 15) {
                    if let product = product {
                        HStack {
                            Text("\(product.name)")
                                .font(.largeTitle)
                                .bold()
                            Spacer()
                        }
                        ProductPic(productID: product.id, width: proxy.size.width - 40, height: proxy.size.height * 0.35)
                        HStack {
                            Text(product.price.formatted(.currency(code: "USD")))
                                .font(.title2)
                                .foregroundColor(Color.secondary)
                            Spacer()
                            
                            if let category = category {
                                if showCategoryLink {
                                    NavigationLink(category.name) {
                                        CategoryDetail(category: category)
                                    }.font(.title3)
                                } else {
                                    Text(category.name)
                                    .font(.title3)
                                }
                            }
                        }
                        Button(action: {
                            databaseService.addNewEntry(of: product.id, name: product.name, price: product.price)
                        }) {
                            Text("Add to cart").frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.roundedRectangle)
                        .controlSize(.large)
                        .tint(.blue)
                        Text(product.description)
                            .multilineTextAlignment(.leading)
                    }
                    
                    HStack {
                        if let vendor = vendor {
                            if showVendorLink {
                                NavigationLink(destination: VendorDetail(vendor: vendor)) {
                                    Label(vendor.name, systemImage: "person.fill")
                                }
                            } else {
                                Label(vendor.name, systemImage: "person.fill")
                            }
                        }
                        Spacer()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .padding(.horizontal)
            .task {
                //Get Product
                let productURL = URL(string: "http://127.0.0.1:8080/api/products/\(productID)")
                let (productData, _) = try! await URLSession.shared.data(from: productURL!)
                self.product = try! JSONDecoder().decode(
                    ProductDTO.self,
                from: productData
                )
                
                //Get Vendor
                let vendorURL = URL(string: "http://127.0.0.1:8080/api/vendors/\(product!.vendorId)")
                let (vendorData, _) = try! await URLSession.shared.data(from: vendorURL!)
                self.vendor = try! JSONDecoder().decode(
                    VendorDTO.self,
                from: vendorData
                )
                
                //Get Category
                let catURL = URL(string: "http://127.0.0.1:8080/api/categories/\(product!.categoryId)")
                let (catData, _) = try! await URLSession.shared.data(from: catURL!)
                self.category = try! JSONDecoder().decode(
                    CategoryDTO.self,
                from: catData
                )
            }
        }
    }
}

struct ProductListView_Previews: PreviewProvider {
    static var previews: some View {
        ProductListView()
    }
}
