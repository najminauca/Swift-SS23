//
//  File.swift
//  
//
//  Created by Samuel Schepp on 21.03.23.
//

import Foundation
import Vapor

extension String {
    func requireID() throws -> UUID {
        guard let id = UUID(uuidString: self) else {
            throw Abort(.badRequest, reason: "Invalid id format")
        }
        return id
    }
}
