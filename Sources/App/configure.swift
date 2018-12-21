import FluentMySQL
import Vapor
import Leaf
import LeafErrorMiddleware

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentMySQLProvider())
    try services.register(LeafProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Use Leaf for rendering views
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    config.prefer(LeafRenderer.self, for: TemplateRenderer.self)

    services.register { worker in
        return try LeafErrorMiddleware(environment: worker.environment)
    }

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(LeafErrorMiddleware.self)
    services.register(middlewares)

    // Configure a SQLite database
    guard let sqluser = try Environment.get("sqluser"), let sqlpass = try Environment.get("sqlpass") else {
        throw Abort(.internalServerError, reason: "Failed to get sql variables")
    }
    let mysqlConfig = MySQLDatabaseConfig(hostname: "localhost",
                                            username: sqluser,
                                            password: sqlpass,
                                            database: "downloadfiletest")
    let mysql = try MySQLDatabase(config: mysqlConfig)                                            
    

    /// Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: mysql, as: .mysql)
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: DownloadFile.self, database: .mysql)
    services.register(migrations)

}
