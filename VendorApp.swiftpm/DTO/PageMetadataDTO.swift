//
//  PageMetadataDTO.swift
//  ProductApp
//
//  Created by Najmi Antariksa on 20.06.23.
//

import Foundation

struct PageMetadataDTO: Codable {
    var per: Int64
    var page: Int64
    var total: Int64
    var pageCount: Int64
}
