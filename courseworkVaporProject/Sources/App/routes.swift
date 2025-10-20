import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async throws in
        try await req.view.render("index.leaf", ["title": "Order Tea Collaborative To Do List"])
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    try app.register(collection: TaskController())
    try app.register(collection: UserController())
    try app.register(collection: GroupController())
    try app.register(collection: DetailedTaskController())
    try app.register(collection: UserIOSController())
    try app.register(collection: GroupIOSController())
    try app.register(collection: TaskIOSController())
    try app.register(collection: DetailedTaskIOSController())
    try app.register(collection: errorControllerWeb())
    
}
