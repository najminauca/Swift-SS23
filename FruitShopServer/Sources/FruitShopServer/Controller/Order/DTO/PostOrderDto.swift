//
//  PostOrderDto.swift
//  
//
//  Created by Samuel Schepp on 21.03.23.
//

import Foundation
import VaporToOpenAPI
import Fluent
import Vapor

struct PostOrderDto: Content, WithExample {
    var entries: [PostOrderEntryDto]

    static var example: PostOrderDto {
        PostOrderDto(entries: [PostOrderEntryDto.example, PostOrderEntryDto.example, PostOrderEntryDto.example])
    }
}
