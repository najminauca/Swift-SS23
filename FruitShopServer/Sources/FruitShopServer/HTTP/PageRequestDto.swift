//
//  PageRequestDto.swift
//  
//
//  Created by Samuel Schepp on 23.03.23.
//

import Foundation
import Fluent
import Vapor
import VaporToOpenAPI

struct PageRequestDto: Content, WithExample {
    var page: Int?
    var per: Int?

    public static var example: PageRequestDto = PageRequestDto(page: 1, per: 10)
}
