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
    @State var total: Decimal = 0.0
    @State var showOrderSheet: Bool = false
    @State var order: OrderDTO? = nil
    
    var body: some View {
        GeometryReader { proxy in
            NavigationView {
                List {
                    ForEach(cartEntries) { entry in
                        NavigationLink(destination: ProductDetail(productID: entry.productID)) {
                            HStack {
                                ProductPic(productID: entry.productID, width: proxy.size.width * 0.3, height: proxy.size.height * 0.15)
                                VStack(alignment: .leading) {
                                    Text(entry.name).font(.title2)
                                    Text("\(entry.price.formatted(.currency(code: "USD")))").foregroundColor(.secondary)
                                    HStack(spacing: 0) {
                                        Stepper("", onIncrement: {
                                            databaseService.addNewEntry(of: entry.productID)
                                        }, onDecrement: {
                                            databaseService.decreaseAmount(of: entry.productID)
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
                                databaseService.deleteEntry(of: entry.productID)
                            }) {
                                Image(systemName: "trash")
                            }
                        }
                    }
                    if total != 0.0 {
                        Button(action: {
                            Task {
                                await placeOrder(of: cartEntries)
                            }
                            showOrderSheet = true
                        }) {
                            Text("Place binding order \(total.formatted(.currency(code: "USD")))").frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.roundedRectangle)
                        .controlSize(.large)
                        .tint(.blue)
                    }
                }
                .navigationTitle("Cart")
            }
            .onAppear {
                self.cartEntrySubscription = ValueObservation
                    .tracking { (db: Database) -> [CartEntry] in
                        try CartEntry.fetchAll(db)
                    }
                    .publisher(in: databaseService.queue)
                    .assertNoFailure()
                    .sink { (cartEntries: [CartEntry]) -> Void in
                        self.cartEntries = cartEntries
                        total = cartEntries.map {
                            $0.price * Decimal($0.amount)
                        }.reduce(0, { x, y in
                            x + y
                        })
                    }
            }
            .sheet(isPresented: $showOrderSheet) {
                if let order = order {
                    OrderView(orderID: order.id ?? "")
                }
            }
        }
    }
    
    func placeOrder(of entries: [CartEntry]) async {
        let url = URL(
        string: "http://127.0.0.1:8080/api/orders")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let item = OrderDTO(entries: entries.map {
            OrderEntryDTO(amount: Int64($0.amount), productID: $0.productID)
        })
        request.httpBody = try! JSONEncoder().encode(item)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let (data, response) = try! await URLSession.shared.data(for: request)
        self.order = try! JSONDecoder().decode(
            OrderDTO.self,
        from: data
        )
    }
}

struct OrderView: View {
    @Environment(\.presentationMode) private var presentation
    @State var orderID: String
    
    var body: some View {
        NavigationView {
            List {
                Button(action: {
                    Task {
                        await pay()
                    }
                }) {
                    Text("Confirm payment").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle)
                .controlSize(.large)
                .tint(.blue)
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button("Cancel", role: .cancel, action: cancel)
                }
            }
        }
    }
    
    func cancel() {
        presentation.wrappedValue.dismiss()
    }
    
    func pay() async {
        let url = URL(
        string: "http://127.0.0.1:8080/api/orders/\(orderID)/pay")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        let item = PaymentDTO(paypalTransactionId: UUID().uuidString)
        request.httpBody = try! JSONEncoder().encode(item)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let (data, response) = try! await URLSession.shared.data(for: request)
    }
}

struct CartEntryListView_Previews: PreviewProvider {
    static var previews: some View {
        CartEntryListView()
    }
}
