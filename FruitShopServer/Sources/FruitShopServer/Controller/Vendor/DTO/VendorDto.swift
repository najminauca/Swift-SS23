//
//  VendorDto.swift
//  
//
//  Created by Samuel Schepp on 20.03.23.
//

import Foundation
import Vapor
import VaporToOpenAPI

struct VendorDto: Content, WithExample, Equatable {
    var id: UUID
    var name: String
    var productsCount: Int

    static var example: VendorDto {
        VendorDto(id: UUID.example, name: "Fruit GmbH", productsCount: 2)
    }
}
