//
//  PageMetadata.swift
//  
//
//  Created by Samuel Schepp on 20.03.23.
//

import Foundation
import VaporToOpenAPI
import Fluent
import Vapor

struct PageMetadataDto: Content, WithExample, Equatable {
    var page: Int
    var per: Int
    var total: Int
    var pageCount: Int

    static func from(pageMetadata: PageMetadata) -> PageMetadataDto {
        PageMetadataDto(page: pageMetadata.page, per: pageMetadata.per, total: pageMetadata.total, pageCount: pageMetadata.pageCount)
    }

    public static var example: PageMetadataDto {
        PageMetadataDto(page: 0, per: 10, total: 23, pageCount: 3)
    }
}

