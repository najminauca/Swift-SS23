//
//  File.swift
//  
//
//  Created by Samuel Schepp on 21.03.23.
//

import Foundation
import Vapor
import VaporToOpenAPI

struct PayOrderDto: Content, WithExample {
    var paypalTransactionId: String

    static var example: PayOrderDto = PayOrderDto(paypalTransactionId: UUID.example.uuidString)
}
