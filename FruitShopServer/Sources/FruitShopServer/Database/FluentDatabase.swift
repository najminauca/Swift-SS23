import Foundation
import FluentKit
import Vapor

class FluentDatabase {
    private let app: Application

    init(app: Application) async throws {
        self.app = app

        app.databases.use(databaseConfig(), as: .sqlite)
        app.migrations.add(MigrationV1())
        app.databases.middleware.use(DatabaseMiddleware())
        try await app.autoMigrate()
    }

    func databaseConfig() -> DatabaseConfigurationFactory {
        let url = URL(fileURLWithPath: "\(FileManager.default.currentDirectoryPath)/database.sqlite")
        app.logger.debug("Database Path: \(url.absoluteString)")
        return .sqlite(.file(url.absoluteString))
    }

    private func getDocumentDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectoryPath = paths[0]
        return documentDirectoryPath
    }
}
