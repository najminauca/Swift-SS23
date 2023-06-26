//
//  File.swift
//  
//
//  Created by Najmi Antariksa on 25.06.23.
//

import Foundation
import GRDB
import SwiftUI

struct CartEntry: Codable, FetchableRecord, PersistableRecord, Identifiable {
    static var databaseTableName: String = "CartEntry"
    
    var id: Int?
    var productID: String
    var name: String
    var price: Decimal
    var amount: Int
    
    enum Columns: String, ColumnExpression { case id, productID, name, price, amount
    }
}
