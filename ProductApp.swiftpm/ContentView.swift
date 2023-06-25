//
//  ContentView.swift
//  ProductApp
//
//  Created by Najmi Antariksa on 20.06.23.
//

import SwiftUI
import GRDB
import Combine

struct ContentView: View {
    var body: some View {
        TabView {
            ProductListView()
                .tabItem {
                    Label("Products", systemImage: "house.fill")
                }
            CategoryListView()
                .tabItem {
                    Label("Categories", systemImage: "square.grid.2x2")
                }
            VendorListView()
                .tabItem {
                    Label("Vendors", systemImage: "person.3.fill")
                }
            CartEntryListView()
                .tabItem {
                    Label("Cart", systemImage: "cart.fill")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
