//
//  File.swift
//  
//
//  Created by Samuel Schepp on 23.03.23.
//

import Foundation
import Fluent
@testable import FruitShopServer

class InMemoryDatabase: FluentDatabase {
    override func databaseConfig() -> DatabaseConfigurationFactory {
        return .sqlite(.memory)
    }
}
