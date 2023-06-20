//
//  File.swift
//  
//
//  Created by Samuel Schepp on 20.03.23.
//

import Foundation
import FluentKit

final class Vendor: Model {
    static let schema = "Vendor"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    init() { }

    class func from(createDto: CreateVendorDto) -> Vendor {
        let vendor = Vendor()
        vendor.fill(with: createDto)
        return vendor
    }

    func fill(with dto: CreateVendorDto) {
        self.name = dto.name
    }
}
