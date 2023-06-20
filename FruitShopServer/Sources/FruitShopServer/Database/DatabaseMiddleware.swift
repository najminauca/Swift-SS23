//
//  DatabaseMiddleware.swift
//  
//
//  Created by Samuel Schepp on 20.03.23.
//

import Foundation
import FluentKit
import Vapor

class DatabaseMiddleware: AnyModelMiddleware {
    func handle(_ event: ModelEvent, _ model: AnyModel, on db: Database, chainingTo next: AnyModelResponder) -> EventLoopFuture<Void> {
        db.logger.debug("\(event) \(model.description)")
        return next.handle(event, model, on: db)
    }
}
