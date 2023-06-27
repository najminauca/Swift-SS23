//
//  OrderEntryListView.swift
//  VendorApp
//
//  Created by Najmi Antariksa on 27.06.23.
//

import SwiftUI

struct OrderEntryListView: View {
    @State var order: OrderDTO
    @State var page = 2
    @State var updateOrders: () async -> Void
    
    var per = 5
    
    var body: some View {
        GeometryReader { proxy in
            List {
                VStack(alignment: .leading) {
                    switch order.state {
                    case OrderStatus.completed.rawValue:
                        HStack {
                            Text("Status: ").font(.title2)
                            Text("\(order.state)").foregroundColor(.green).font(.title2)
                        }
                        
                    case OrderStatus.processing.rawValue:
                        HStack {
                            Text("Status: ").font(.title2)
                            Text("\(order.state)").foregroundColor(.blue).font(.title2)
                        }
                        HStack {
                            Button(action: {
                                Task {
                                    await cancel()
                                }
                            }) {
                                Text("Cancel").frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .buttonBorderShape(.roundedRectangle)
                            .controlSize(.large)
                            .tint(.red)
                            Button(action: {
                                Task {
                                    await complete()
                                }
                            }) {
                                Text("Complete").frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .buttonBorderShape(.roundedRectangle)
                            .controlSize(.large)
                            .tint(.green)
                        }
                        
                    case OrderStatus.cancelled.rawValue:
                        HStack {
                            Text("Status: ").font(.title2)
                            Text("\(order.state)").foregroundColor(.red).font(.title2)
                        }
                        Button(action: {
                            Task {
                                await delete()
                            }
                        }) {
                            Text("Delete").frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.roundedRectangle)
                        .controlSize(.large)
                        .tint(.red)
                        
                    default:
                        HStack {
                            Text("Status: ").font(.title2)
                            Text("\(order.state)").foregroundColor(.yellow).font(.title2)
                        }
                        HStack {
                            Button(action: {
                                Task {
                                    await cancel()
                                }
                            }) {
                                Text("Cancel").frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .buttonBorderShape(.roundedRectangle)
                            .controlSize(.large)
                            .tint(.red)
                        }
                    }
                }
                ForEach(order.entries) { entry in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(entry.productID).font(.title2)
                            Text("x\(entry.amount)").foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Entries")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func cancel() async {
        let url = URL(
            string: "http://127.0.0.1:8080/api/orders/\(order.id)/cancel")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let (data, response) = try! await URLSession.shared.data(for: request)
        await updateOrders()
    }
    
    func delete() async {
        let url = URL(
            string: "http://127.0.0.1:8080/api/orders/\(order.id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let (data, response) = try! await URLSession.shared.data(for: request)
        await updateOrders()
    }
    
    func complete() async {
        let url = URL(
            string: "http://127.0.0.1:8080/api/orders/\(order.id)/complete")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let (data, response) = try! await URLSession.shared.data(for: request)
        await updateOrders()
    }
}

//struct OrderEntryListView_Previews: PreviewProvider {
//    static var previews: some View {
//        OrderEntryListView()
//    }
//}
