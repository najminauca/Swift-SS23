//
//  PostOrderEntryDto.swift
//  
//
//  Created by Samuel Schepp on 21.03.23.
//

import Foundation
import VaporToOpenAPI
import Fluent
import Vapor

struct PostOrderEntryDto: Content, WithExample {
    var productID: UUID
    var amount: Int

    static var example: PostOrderEntryDto {
        PostOrderEntryDto(productID: UUID.example, amount: 2)
    }
}
