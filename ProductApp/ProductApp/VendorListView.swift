//
//  VendorListView.swift
//  ProductApp
//
//  Created by Najmi Antariksa on 20.06.23.
//

import SwiftUI

struct VendorListView: View {
    @State var vendors: [VendorDTO] = []
    
    var body: some View {
        NavigationView {
            List {
                ForEach(vendors) { vendor in
                    NavigationLink(destination: VendorDetail(vendor: vendor)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(vendor.name)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Vendors")
        }        
        .task {
            let getVendors = URL(string: "http://127.0.0.1:8080/api/vendors")
            let (data, _) = try! await URLSession.shared.data(from: getVendors!)
            let vendorsDTO = try! JSONDecoder().decode(
                VendorsDTO.self,
            from: data
            )
            self.vendors = vendorsDTO.vendors
        }
    }
}

struct VendorDetail: View {
    @State var vendor: VendorDTO?
    @State var products: [ProductDTO] = []
    
    var body: some View {
        VStack(spacing: 20) {
            Image(uiImage: UIImage(systemName: "person.fill")!).resizable()
                .frame(width: 200, height: 200, alignment: .center)
                .aspectRatio(contentMode: .fit)
                .cornerRadius(.greatestFiniteMagnitude)
                .padding(3)
                .overlay(
                    RoundedRectangle(cornerRadius: .infinity)
                        .stroke(Color.white, lineWidth: 6)
                )
                .shadow(radius: 5)
            Text("There is **\(vendor!.productsCount)** product(s) being sold by **\(vendor!.name)**.").font(.title3)
                .multilineTextAlignment(.center)
        }
        .padding()
        .navigationTitle(vendor!.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

//struct VendorListView_Previews: PreviewProvider {
//    static var previews: some View {
//        VendorListView()
//    }
//}
