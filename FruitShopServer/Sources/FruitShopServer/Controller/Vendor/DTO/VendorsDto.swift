//
//  VendorsDto.swift
//  
//
//  Created by Samuel Schepp on 20.03.23.
//

import Foundation
import Vapor
import VaporToOpenAPI
import Fluent

struct VendorsDto: Content, WithExample {
    var vendors: [VendorDto]
    var page: PageMetadataDto

    static var example: VendorsDto {
        VendorsDto(vendors: [VendorDto.example, VendorDto.example, VendorDto.example], page: PageMetadataDto.example)
    }
}
