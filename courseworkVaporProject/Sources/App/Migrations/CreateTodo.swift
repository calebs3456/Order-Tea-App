import Fluent

struct CreateTodo: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("tasks")
            .id()
            .field("Title", .string, .required)
            .field("Description", .string, .required)
            .field("ETTC", .int, .required)
            .field("AssignedFrom", .string, .required)
            .field("AssignedTo", .string, .required)
            .field("Deadline", .datetime, .required)
            .field("AsssignedPriority", .string, .required)
            .field("id", .uuid, .required)


            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("tasks").delete()
    }
}
