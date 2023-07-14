//
//  VendorListView.swift
//  ProductApp
//
//  Created by Najmi Antariksa on 20.06.23.
//

import SwiftUI

struct VendorListView: View {
    @State var vendors: [VendorDTO] = []
    
    @State var page = 2
    
    private var per = 5
    
    var body: some View {
        NavigationView {
            List {
                ForEach(vendors) { vendor in
                    NavigationLink(destination: VendorDetail(vendor: vendor)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(vendor.name).font(.title2)
                            }
                        }
                        .onAppear {
                            if hasReachedEnd(of: vendor) {
                                Task {
                                    await loadMoreVendors()
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Vendors")
        }        
        .onAppear {
            Task {
                self.vendors = []
                let getVendors = URL(string: "http://127.0.0.1:8080/api/vendors?page=\(1)&per=\(10)")
                let (data, _) = try! await URLSession.shared.data(from: getVendors!)
                let vendorsDTO = try! JSONDecoder().decode(
                    VendorsDTO.self,
                from: data
                )
                self.vendors = vendorsDTO.vendors
                page = 2
            }
        }
    }
    
    func loadMoreVendors() async {
        page += 1
        
        let loadMore = URL(string: "http://127.0.0.1:8080/api/vendors?page=\(page)&per=\(per)")
        let (data, _) = try! await URLSession.shared.data(from: loadMore!)
        let vendorsDTO = try! JSONDecoder().decode(
            VendorsDTO.self,
        from: data
        )
        self.vendors += vendorsDTO.vendors
    }
    
    func hasReachedEnd(of vendor: VendorDTO) -> Bool {
        return vendors.last?.id == vendor.id
    }
}

struct VendorDetail: View {
    @State var vendor: VendorDTO
    @State var products: [ProductDTO] = []
    
    var body: some View {
        GeometryReader { proxy in
            List {
                VStack(spacing: 20) {
                    Image(uiImage: UIImage(systemName: "person.fill")!).resizable()
                        .frame(width: 150, height: 150, alignment: .center)
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(.greatestFiniteMagnitude)
                        .padding(3)
                        .overlay(
                            RoundedRectangle(cornerRadius: .infinity)
                                .stroke(Color.white, lineWidth: 6)
                        )
                        .shadow(radius: 3)
                    if vendor.productsCount > 1 {
                        Text("There are **\(vendor.productsCount)** products being sold by **\(vendor.name)**.").font(.title3)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    } else {
                        Text("There is **\(vendor.productsCount)** product being sold by **\(vendor.name)**.").font(.title3)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    }
                    
                }
                ForEach(products) { product in
                    NavigationLink(destination: ProductDetail(productID: product.id, showVendorLink: false)) {
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
            .navigationTitle(vendor.name)
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            var page = 1
            if vendor.productsCount > 0 {
                while self.products.count != vendor.productsCount {
                    let getProducts = URL(string: "http://127.0.0.1:8080/api/products?page=\(page)&per=\(10)")
                    let (data, _) = try! await URLSession.shared.data(from: getProducts!)
                    let productsDTO = try! JSONDecoder().decode(
                        ProductsDTO.self,
                    from: data
                    )
                    self.products += productsDTO.products.filter {
                        $0.vendorId == vendor.id
                    }
                    page += 1
                }
            }
        }
    }
}

struct VendorListView_Previews: PreviewProvider {
    static var previews: some View {
        VendorListView()
    }
}
