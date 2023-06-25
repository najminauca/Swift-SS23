//
//  VendorDTO.swift
//  ProductApp
//
//  Created by Najmi Antariksa on 20.06.23.
//

import Foundation

struct VendorsDTO: Codable {
    var vendors: [VendorDTO]
    var page: PageMetadataDTO
}

struct VendorDTO: Codable, Identifiable {
    var id: String?
    var name: String
    var productsCount: Int64
}
