//
//  OrderListView.swift
//  VendorApp
//
//  Created by Najmi Antariksa on 27.06.23.
//

import SwiftUI

struct OrderListView: View {
    @State var orders: [OrderDTO] = []
    @State var page = 2
    
    var per = 5
    
    var body: some View {
        NavigationView {
            List {
                ForEach(orders) { order in
                    NavigationLink(
                        destination: OrderEntryListView(order: order, updateOrders: updateOrders)
                    ) {
                        VStack(alignment: .leading) {
                            Text(order.id).font(.title3).multilineTextAlignment(.leading)
                            switch order.state {
                            case OrderStatus.processing.rawValue:
                                Text(order.state).foregroundColor(.blue)
                                
                            case OrderStatus.completed.rawValue:
                                Text(order.state).foregroundColor(.green)
                                
                            case OrderStatus.cancelled.rawValue:
                                Text(order.state).foregroundColor(.red)
                            default:
                                Text(order.state).foregroundColor(.yellow)
                            }
                        }
                    }
                    .onAppear {
                        Task {
                            if hasReachedEnd(of: order) {
                                await loadMoreOrders()
                            }
                        }
                    }
                }
            }
            .refreshable {
                await updateOrders()
            }
            .navigationTitle("Orders")
        }
        .onAppear {
            Task {
                await updateOrders()
            }
        }
    }
    
    func updateOrders() async {
        self.orders = []
        let getOrders = URL(string: "http://127.0.0.1:8080/api/orders?page=\(1)&per=\(10)")
        let (data, _) = try! await URLSession.shared.data(from: getOrders!)
        let ordersDTO = try! JSONDecoder().decode(
            OrdersDTO.self,
        from: data
        )
        self.orders = ordersDTO.orders
        
        page = 2
    }
    
    func loadMoreOrders() async {
        page += 1
        
        let loadMore = URL(string: "http://127.0.0.1:8080/api/orders?page=\(page)&per=\(per)")
        let (data, _) = try! await URLSession.shared.data(from: loadMore!)
        let ordersDTO = try! JSONDecoder().decode(
            OrdersDTO.self,
        from: data
        )
        self.orders += ordersDTO.orders
    }
    
    func hasReachedEnd(of order: OrderDTO) -> Bool {
        return orders.last?.id == order.id
    }
}

//struct OrderListView_Previews: PreviewProvider {
//    static var previews: some View {
//        OrderListView()
//    }
//}
