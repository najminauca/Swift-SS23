//
//  CreateVendorDto.swift
//  
//
//  Created by Samuel Schepp on 20.03.23.
//

import Foundation
import Vapor
import VaporToOpenAPI

struct CreateVendorDto: Content, WithExample {
    var name: String

    static var example: CreateVendorDto {
        CreateVendorDto(name: "Fruit GmbH")
    }
}
