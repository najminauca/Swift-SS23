//
//  CartEntryListView.swift
//  ProductApp
//
//  Created by Najmi Antariksa on 25.06.23.
//

import SwiftUI
import GRDB
import Combine

struct CartEntryListView: View {
    @EnvironmentObject private var databaseService: DatabaseService
    @State private var cartEntrySubscription: Cancellable? = nil
    @State var cartEntries: [CartEntry] = []
    @State var products: [ProductDTO] = []
    
    var body: some View {
        NavigationView {
            GeometryReader { proxy in
                List {
                    ForEach(cartEntries) { entry in
                        var product: ProductDTO? = nil
                        NavigationLink(destination: ProductDetail(productId: entry.productId)) {
                            HStack {
                                
                                ProductPic(productId: entry.productId, width: proxy.size.width * 0.3, height: proxy.size.height * 0.15)
                                VStack(alignment: .leading) {
                                    Text(entry.name ?? "").font(.title2)
                                    Text("$\(entry.price.description)").foregroundColor(.secondary)
                                    HStack(spacing: 0) {
                                        Stepper("", onIncrement: {
                                            databaseService.addNewEntry(of: entry.productId)
                                        }, onDecrement: {
                                            databaseService.decreaseAmount(of: entry.productId)
                                        })
                                        .labelsHidden()
                                        Spacer()
                                        Text("Qty: \(entry.amount)")
                                            .bold()
                                    }
                                }
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive, action: {
                                databaseService.deleteEntry(of: entry.productId)
                            }) {
                                Image(systemName: "trash")
                            }
                        }
                    }
                }
                .navigationTitle("Cart")
            }
        }
        .onAppear {
            self.cartEntrySubscription = ValueObservation
                .tracking { (db: Database) -> [CartEntry] in
                    try CartEntry.fetchAll(db)
                }
                .publisher(in: databaseService.queue)
                .assertNoFailure()
                .sink { (cartEntries: [CartEntry]) -> Void in
                    withAnimation {
                        self.cartEntries = cartEntries
                    }
                }
        }
    }
}

struct CartEntryListView_Previews: PreviewProvider {
    static var previews: some View {
        CartEntryListView()
    }
}
