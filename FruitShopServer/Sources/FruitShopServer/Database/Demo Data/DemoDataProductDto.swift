//
//  File.swift
//  
//
//  Created by Samuel Schepp on 23.03.23.
//

import Foundation

struct DemoDataProductDto: Codable {
    var title: String
    var description: String
    var price: Decimal
    var classification: String
    var vendor: String
    var imageFileName: String?
}
