import Fluent
import Vapor

final class Task: Model, Content {
    

    //Model of a record in the table tasks
    static let schema = "tasks"

    @Field(key: "GroupID")
    var GroupID: String?
    
    @ID(custom: "TaskID")
    var id: String?

    @Field(key: "Title")
    var title: String
    
    @Field(key: "Description")
    var description: String
        
    @Field(key: "AssignedTo")
    var AssignedTo: String
    
    @Field(key: "AssignedFrom")
    var AssignedFrom: String
    @Field(key: "AccessLevel")
    var AccessLevel: Int
    @Field(key: "StartDate")
    var StartDate: Date
    
    @Field(key: "EndDate")
    var EndDate: Date
    
    @Field(key: "Reminder")
    var Reminder: Date
    
    @Field(key: "AssignedPriority")
    var AssignedPriority: Int
    @Field(key: "SubtaskNumber")
    var SubtaskNumber: Int
    
    @Field(key: "Complete")
    var Complete: Bool

    init() { }


    init(GroupID: String?,TaskID: String?, title: String, description: String, subtaskNumber: Int, AssignedTo: String, AssignedFrom: String,  StartDate: Date,  EndDate: Date,Reminder: Date, AssignedPriority: Int, AccessLevel: Int, Complete: Bool) {
        self.GroupID = GroupID
        self.id = TaskID
        self.title = title
        self.description = description
        self.SubtaskNumber = subtaskNumber
        self.AssignedTo = AssignedTo
        self.AssignedFrom = AssignedFrom
        self.StartDate = StartDate
        self.EndDate = EndDate
        self.Reminder=Reminder
        self.AssignedPriority = AssignedPriority
        self.AccessLevel = AccessLevel
        self.Complete = Complete
        
    }

        
}

