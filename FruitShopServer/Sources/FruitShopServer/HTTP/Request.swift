//
//  Request.swift
//  
//
//  Created by Samuel Schepp on 20.03.23.
//

import Foundation
import Vapor

extension Request {
    func requireID(fieldName: String = "id") throws -> UUID {
        guard let idString = self.parameters.get("id") else {
            throw Abort(.badRequest, reason: "No id given")
        }
        let id = try idString.requireID()
        return id
    }
}
