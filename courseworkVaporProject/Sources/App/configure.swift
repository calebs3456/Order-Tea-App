import NIOSSL
import Fluent
import FluentMySQLDriver
import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    var tls = TLSConfiguration.makeClientConfiguration()
    tls.certificateVerification = .none
    app.databases.use(DatabaseConfigurationFactory.mysql(
        hostname: Environment.get("DATABASE_HOST") ?? "0.0.0.0",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? MySQLConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "caleb",
        password: Environment.get("DATABASE_PASSWORD") ?? "",
        database: Environment.get("DATABASE_NAME") ?? "courseworkVapor",
        tlsConfiguration: tls,
        maxConnectionsPerEventLoop: 10
    ), as: .mysql)


    
    app.migrations.add(CreateTodo())
    app.middleware.use(SessionsMiddleware(session: app.sessions.driver))

    app.views.use(.leaf)
    
  

      // Start the scheduled task
    let notificationScheduler = NotificationPayloadDeveloper(app: app)
    //notificationScheduler.scheduleTask()
    let eventLoop = app.eventLoopGroup.next()
    eventLoop.scheduleRepeatedAsyncTask(initialDelay: .seconds(0), delay: .minutes(30)) { task in
        // This closure is executed every 30 minutes

        // Call your task function
        notificationScheduler.performScheduledNotification(app: app)

        // Return a future indicating the task is complete
        return eventLoop.makeSucceededFuture(())
    }

    // register routes
    try routes(app)
}
