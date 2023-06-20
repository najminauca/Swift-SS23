//
//  OrderEntryDto.swift
//  
//
//  Created by Samuel Schepp on 21.03.23.
//

import Foundation
import VaporToOpenAPI
import Fluent
import Vapor

struct OrderEntryDto: Content, WithExample, Equatable {
    var id: UUID
    var productID: UUID?
    var amount: Int

    static var example: OrderEntryDto {
        OrderEntryDto(id: UUID.example, productID: UUID.example, amount: 2)
    }
}
