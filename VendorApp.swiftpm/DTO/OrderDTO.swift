//
//  Order.swift
//  ProductApp
//
//  Created by Najmi Antariksa on 20.06.23.
//

import Foundation

struct OrdersDTO: Codable {
    var orders: [OrderDTO]
    var page: PageMetadataDTO
}

struct OrderDTO: Codable, Identifiable {
    var entries: [OrderEntryDTO]
    var id: String
    var state: String
}

struct OrderEntryDTO: Codable, Identifiable {
    var amount: Int64
    var id: String
    var productID: String
}
