//
//  File.swift
//  
//
//  Created by Najmi Antariksa on 25.06.23.
//

import Foundation
import GRDB

class DatabaseService: ObservableObject {
    let queue: DatabaseQueue
    
    init(inMemory: Bool) {
        if inMemory {
            queue = try! DatabaseQueue(path: ":memory:")
        } else {
            let documentsDirectory = try! FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let databaseUrl = documentsDirectory.appendingPathComponent("database.sqlite")
            let databasePath = databaseUrl.absoluteString
            print("Database Path: \(databasePath)")
            queue = try! DatabaseQueue(path: databasePath)
        }
        
        var migrator: DatabaseMigrator = DatabaseMigrator()
        
        migrator.registerMigration("V1") { db in
            try db.create(table: "CartEntry") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("productID", .text).notNull()
                t.column("name", .text).notNull()
                t.column("price", .real).notNull()
                t.column("amount", .integer).notNull()
            }
        }

        try! migrator.migrate(queue)
    }
    
    func addNewEntry(of productID: String, name: String? = nil, price: Decimal? = nil) {
        let cartEntry: CartEntry? = try! queue.read { db -> CartEntry? in
            return try! CartEntry.filter(CartEntry.Columns.productID == productID).fetchOne(db)
        }
        
        if let cartEntry = cartEntry {
            try! queue.write { db in
                var update = cartEntry
                update.amount += 1
                try! update.save(db)
            }
        } else {
            try! queue.write { db in
                let new = CartEntry(productID: productID, name: name ?? "", price: price ?? 0.0, amount: 1)
                try! new.save(db)
            }
        }
    }
    
    func decreaseAmount(of productID: String) {
        let cartEntry: CartEntry = try! queue.read { db -> CartEntry in
            return try! CartEntry.filter(CartEntry.Columns.productID == productID).fetchOne(db)!
        }
        
        if cartEntry.amount > 1 {
            try! queue.write { db in
                var update = cartEntry
                update.amount -= 1
                try! update.save(db)
            }
        } else {
            deleteEntry(of: productID)
        }
    }
    
    func deleteEntry(of productID: String) {
        let cartEntry: CartEntry = try! queue.read { db -> CartEntry in
            return try! CartEntry.filter(CartEntry.Columns.productID == productID).fetchOne(db)!
        }
        
        try! queue.write { db in
            try! cartEntry.delete(db)
        }
    }
    
    func deleteAllEntries() {
        try! queue.write { db in
            try! CartEntry.deleteAll(db)
        }
    }
}
