import Authentication
import FluentSQLite
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentSQLiteProvider())
    try services.register(AuthenticationProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    // middlewares.use(SessionsMiddleware.self) // Enables sessions.
    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Configure a SQLite database
    let sqlite = try SQLiteDatabase(storage: .memory)

    // Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.enableLogging(on: .sqlite)
    databases.add(database: sqlite, as: .sqlite)
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Private.User.self,
                   database: DatabaseIdentifier<Private.User.Database>.sqlite)
    migrations.add(model: Private.UserToken.self,
                   database: DatabaseIdentifier<Private.UserToken.Database>.sqlite)
    migrations.add(model: Private.Category.self,
                   database: DatabaseIdentifier<Private.Category.Database>.sqlite)
    migrations.add(model: Private.Event.self,
                   database: DatabaseIdentifier<Private.Event.Database>.sqlite)
    migrations.add(model: Private.Note.self,
                   database: DatabaseIdentifier<Private.Note.Database>.sqlite)
    migrations.add(model: Private.Period.self,
                   database: DatabaseIdentifier<Private.Period.Database>.sqlite)
    migrations.add(model: Private.Part.self,
                   database: DatabaseIdentifier<Private.Part.Database>.sqlite)
    migrations.add(model: Private.Photo.self,
                   database: DatabaseIdentifier<Private.Photo.Database>.sqlite)
    migrations.add(model: Private.AwardOffice.self,
                   database: DatabaseIdentifier<Private.AwardOffice.Database>.sqlite)
    migrations.add(model: Private.Award.self,
                   database: DatabaseIdentifier<Private.Award.Database>.sqlite)
    migrations.add(model: Private.AwardType.self,
                   database: DatabaseIdentifier<Private.AwardType.Database>.sqlite)
    services.register(migrations)

}
