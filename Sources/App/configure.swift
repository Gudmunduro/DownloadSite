import FluentMySQL
import Vapor
import Leaf
import LeafErrorMiddleware
import Authentication

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentMySQLProvider())
    try services.register(LeafProvider())
    try services.register(AuthenticationProvider())

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
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(LeafErrorMiddleware.self)
    services.register(middlewares)

    // Configure a MySQL database
    guard let sqluser = try Environment.get("sqluser"), let sqlpass = try Environment.get("sqlpass"), let sqldb = Environment.get("sqldb") else {
        throw Abort(.internalServerError, reason: "Failed to get sql variables")
    }
    let mysqlConfig = MySQLDatabaseConfig(hostname: "localhost",
                                            username: sqluser,
                                            password: sqlpass,
                                            database: sqldb)
    let mysql = try MySQLDatabase(config: mysqlConfig)                                     
    

    /// Register the configured MySQL database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: mysql, as: .mysql)
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: DownloadFile.self, database: .mysql)
    migrations.add(model: User.self, database: .mysql)
    migrations.add(model: UserToken.self, database: .mysql)
    services.register(migrations)

}
