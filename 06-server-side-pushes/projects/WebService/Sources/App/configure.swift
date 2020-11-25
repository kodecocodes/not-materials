import Fluent
import FluentPostgresDriver
import Vapor
import APNS

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database"
    ), as: .psql)

    app.migrations.add(CreateToken())
    
    try! app.autoMigrate().wait()

    if app.environment != .production {
        app.http.server.configuration.hostname = "0.0.0.0"
    }

    try routes(app)

    let apnsEnvironment: APNSwiftConfiguration.Environment
    apnsEnvironment = app.environment == .production ? .production : .sandbox

    let auth: APNSwiftConfiguration.AuthenticationMethod = try .jwt(
        key: .private(filePath: "/full/path/to/AuthKey_...p8"),
        keyIdentifier: "...",
        teamIdentifier: "..."
    )

    app.apns.configuration = .init(authenticationMethod: auth,
                                   topic: "com.raywenderlich.PushNotifications",
                                   environment: apnsEnvironment)}
