import Fluent
import Vapor
import Foundation
import Leaf

struct TaskController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let todos = routes.grouped("tasks")
        todos.get(use: WebTaskTable)
        todos.post("create",use: create)
        todos.post("delete", use:delete)
        todos.post("changeFactorTasks", use: changeFactorsTask)
        todos.post("changeFactorAll", use: changeFactorsAll)
        todos.post("options",use:goToOptions)
        todos.post("addUser",use:addUserToGroup)
    }
    
    //Template for data to be sent to basepage.leaf
    struct TaskListContext: Encodable {
        let title: String
        let tasks: [Task]
        let controllingUser: Group
        let groupUsers: [User]
        let nonGroupUsers: [User]
    }
    
    struct errorContext: Encodable {
        var message: String
        var urlReturn: String
        var pageName: String
        
    }
    
    //Uses the template of TaskListContext to send data to the basepage.leaf
    //WebTaskTable queries the data then formats it into TaskListContext and returns it as a view
    func WebTaskTable(req: Request) async throws -> View {
       
        var factors: [String] = ["EndDate","Progress","StartDate","AccessLevel","AssignedPriority"]
        if let factorString = req.session.data["factors"] as? String{
            factors = []
            factors = factorString.components(separatedBy: "-")
            print(factors)
        }
        else{
            factors = ["EndDate","Progress","StartDate","AccessLevel","AssignedPriority"]
        }
        if let userID = req.session.data["user"] as? String {
            
            
            if let groupID = req.session.data["group"] as? String {
                
                let userAccess = try await Group.query(on:req.db).filter(\Group.$userID, .equal, userID).first()?.accessLevel ?? 1
                let tasks = try await Task.query(on: req.db).filter(\Task.$GroupID, .equal, groupID).group(.or) { or in
                    or.filter(\Task.$AccessLevel, .lessThanOrEqual, userAccess)
                    or.filter(\Task.$AssignedTo, .equal, userID)
                }.all()
                print(tasks)
                print("Assigned To", userID)
                
                let schedulingAlgorithmUsed = schedulingAlgorithm()
                let orderedTasks = try await schedulingAlgorithmUsed.schedulingAlgorithmA(req: req ,tasks: tasks, factors: factors)
                print(orderedTasks)
                // Use the groupID from the session to build your view context
                let context = TaskListContext(title: "Task List", tasks: orderedTasks, controllingUser:  try await Group.query(on: req.db).filter(\Group.$userID == userID).first()!, groupUsers: try await returnGroupUsers(req: req), nonGroupUsers: try await returnAllNonGroupUsers(req: req))
                
                return try await req.view.render("Build/BasePage", context)
            } else {
                // Handle the case where there's no groupID in the session
                let message = "Failed to view tasks"
                let urlReturn = "group"
                let pageName = "Group page"
                let context = errorContext(message: message, urlReturn: urlReturn, pageName: pageName)
                return try await req.view.render("Build/Error", context)
            }
           
        }else {

            let message = "Failed to view tasks"
            let urlReturn = "group"
            let pageName = "Group page"
            let context = errorContext(message: message, urlReturn: urlReturn, pageName: pageName)
            return try await req.view.render("Build/Error", context) //Change this because this might respond with an error if this occurs
        }
    }

    func create(req: Request) async throws -> Response{
        
        
        struct CreatePacket: Decodable{
            let Title: String
            let Description: String
            let AssignedPriority: Int
            let StartDate:  String
            let EndDate:  String
            let Reminder: String
            let SubtaskNumber: Int
            let AssignedTo: String
            let AccessLevel: Int
            
        }

        let createPacket = try req.content.decode(CreatePacket.self)
        
        //Data through packet cannot be sent in the format of a date, so it is sent as a string
        //Converting the string to date
  
        guard let startDate = stringToDate(date: createPacket.StartDate) else{
            print("Error")
            let message = "Failed to create task"
            let urlReturn = "tasks"
            let pageName = "Task page"
            
            let errorString = message+"-"+urlReturn+"-"+pageName
            req.session.data["errorMessage"] = errorString
            
            
            return req.redirect(to: "/error")
        }
        guard let endDate = stringToDate(date: createPacket.EndDate) else{
            print("Error")
            let message = "Failed to create task"
            let urlReturn = "tasks"
            let pageName = "Task page"
            
            let errorString = message+"-"+urlReturn+"-"+pageName
            req.session.data["errorMessage"] = errorString
            
            
            return req.redirect(to: "/error")
        }
        guard let reminder = stringToDate(date: createPacket.Reminder) else{
            print("Error")
            let message = "Failed to create task"
            let urlReturn = "tasks"
            let pageName = "Task page"
            
            let errorString = message+"-"+urlReturn+"-"+pageName
            req.session.data["errorMessage"] = errorString
            
            
            return req.redirect(to: "/error")
        }
        if let GroupID = req.session.data["group"] as? String{
            
            
            
            let numberOfTitles = try await Task.query(on:req.db).filter(\Task.$GroupID, .equal, GroupID).filter(\Task.$title==createPacket.Title).all().count
            if numberOfTitles>0{
                let message = "Title already exists"
                let urlReturn = "tasks"
                let pageName = "Task page"
                
                let errorString = message+"-"+urlReturn+"-"+pageName
                req.session.data["errorMessage"] = errorString
                return req.redirect(to: "/error")
            }
        }
        else{
            let message = "Failed to create tasks"
            let urlReturn = "tasks"
            let pageName = "Task page"
            
            let errorString = message+"-"+urlReturn+"-"+pageName
            req.session.data["errorMessage"] = errorString
            return req.redirect(to: "/error")
        }

        let assignedToUser = try await User.query(on:req.db).filter(\User.$id==createPacket.AssignedTo).all().count
        if assignedToUser==0{
            
            let message = "No user found"
            let urlReturn = "tasks"
            let pageName = "Task page"
            
            let errorString = message+"-"+urlReturn+"-"+pageName
            req.session.data["errorMessage"] = errorString

            return req.redirect(to: "/error")
        }
        
        if let groupID = req.session.data["group"] as? String{
            
            if let userID = req.session.data["user"] as? String{
                
                
                let TaskID = try await generateUniqueTaskID(req: req)
              //Block tasks with the same name
                let task = Task(GroupID: groupID, TaskID: TaskID, title: createPacket.Title, description: createPacket.Description, subtaskNumber: createPacket.SubtaskNumber, AssignedTo: createPacket.AssignedTo, AssignedFrom: userID, StartDate: startDate, EndDate: endDate, Reminder:reminder , AssignedPriority: createPacket.AssignedPriority, AccessLevel: createPacket.AccessLevel, Complete: false)
                try await task.create(on: req.db)
                return req.redirect(to: "/tasks")
            }
            else{
                let message = "Failed to create task"
                let urlReturn = "tasks"
                let pageName = "Login page"
                
                let errorString = message+"-"+urlReturn+"-"+pageName
                req.session.data["errorMessage"] = errorString
                return req.redirect(to: "/error")
            }
        }
        else{
            let message = "Failed to create task"
            let urlReturn = "tasks"
            let pageName = "Login page"
            
            let errorString = message+"-"+urlReturn+"-"+pageName
            req.session.data["errorMessage"] = errorString
            return req.redirect(to: "/error")
        }
    }
    
    func goToOptions(req:Request) async throws -> Response{
        struct OptionsPacket: Decodable{
            let id: String
            let SubtaskNumber: Int
        }
        
        let optionsPacket = try req.content.decode(OptionsPacket.self)
        
        guard let task = try await Task.query(on: req.db).filter(\Task.$id==optionsPacket.id).filter(\Task.$SubtaskNumber==optionsPacket.SubtaskNumber).first()
        else{
            
            let message = "Failed to select task"
            let urlReturn = "tasks"
            let pageName = "Task page"
            
            let errorString = message+"-"+urlReturn+"-"+pageName
            req.session.data["errorMessage"] = errorString
            
            
            return req.redirect(to: "/error")
        }
        
        req.session.data["task"] = task.id
        req.session.data["subtaskNumber"] = String(task.SubtaskNumber)
        
        let CalculatedPriority = 0
        
        
        let assignedToUserName = try await User.find(task.AssignedTo, on:req.db)?.username
        let assignedFromUserName = try await User.find(task.AssignedFrom, on:req.db)?.username
        
        let information = ["TaskID": task.id,"GroupID": task.GroupID,"Title": task.title, "Description": task.description, "AssignedPriority": String(task.AssignedPriority), "StartDate":dateToString(date: task.StartDate), "EndDate": dateToString(date: task.EndDate),"Reminder": dateToString(date: task.Reminder), "SubtaskNumber":String(task.SubtaskNumber),"AssignedTo": assignedToUserName, "AssignedFrom": assignedFromUserName,"CalculatedPriority":String(CalculatedPriority), "AccessLevel": String(task.AccessLevel), "Complete": String(task.Complete)]
        
        
        
        return req.redirect(to: "/specificTask")
    }
    

    func delete(req: Request) async throws -> Response {
        
        struct DeletePacket: Decodable{
            let TaskID: Task.IDValue
            let subtaskNumber: Int
        }
        let deletePacket = try req.content.decode(DeletePacket.self)
        //Finds unique task by subtask number and taskID 
        try await Task.query(on: req.db).filter(\Task.$id==deletePacket.TaskID).filter(\Task.$SubtaskNumber==deletePacket.subtaskNumber).first()?.delete(on: req.db)
        //try await Task.find(deletePacket.TaskID, on: req.db)?.delete(on:req.db)
       
        
        return req.redirect(to:"/tasks")
    }
    
    
    
    func generateUniqueTaskID(req: Request) async throws -> String {
       
        if let groupID = req.session.data["group"] as? String{
            
            
            var newTaskID: String
            
            newTaskID = UUID().uuidString + groupID
            
            let taskIDquery = try await Group.query(on:req.db).filter(\Group.$id, .equal, newTaskID).all()
            
            if taskIDquery.isEmpty {
                // No records found with the specified newUserID, so it's unique.
                return newTaskID
            } else {
                // The newUserID already exists, generate a new one.
                return try await generateUniqueTaskID(req: req)
            }
        }
        else{
            return "Error"
        }
    }
    func stringToDate(date: String?) -> Date?{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = date
        
        // Date format for parsing the input strings
        let inputDateFormatter = DateFormatter()
        inputDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"

        // Date format for formatting the dates to be stored in MySQL
        let outputDateFormatter = DateFormatter()
        outputDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if date==nil{
            return nil
        }
        // Parse the start date
        if date != nil{
            var formattedDate = Date()
            if let dateFormat = inputDateFormatter.date(from: date!) {
                var formattedDate = outputDateFormatter.string(from: dateFormat)
                
                return dateFormat
                
            } else {
                
                return nil
            }
        }
        return nil
    }
    
    func dateToString(date: Date) -> String?{
        // Date format for formatting the dates to be stored in MySQL
        let outputDateFormatter = DateFormatter()
        
        let dateString = outputDateFormatter.string(from: date)
        
        return dateString
        
    }
    
    //Adds users to group - receives packet of data
    func addUserToGroup(req: Request) async throws -> Response{
        struct Packet: Decodable{
            let userID: String
            let accessLevel: Int
        }
        
        
        let packet = try req.content.decode(Packet.self)
        let accessLevel = packet.accessLevel
        let addedUserID = packet.userID
        
        //Find the user then add it to group
        if let groupID = req.session.data["group"] as? String{
            let userName = try await User.query(on: req.db).filter(\User.$id == addedUserID).first()?.username
            let group = Group(GroupID: groupID, userID: addedUserID, accessLevel: accessLevel)
            try await group.create(on: req.db)
        }
        return req.redirect(to: "/tasks")
    }
    //Returns users in the current group - used for assigned to in tasks
    func returnGroupUsers(req: Request) async throws -> [User]{
        var users:[User] = []
        if let groupID = req.session.data["group"] as? String{
            let query = try await Group.query(on: req.db).filter(\Group.$id, .equal, groupID).all()
            
            for row in query{
                
                guard let user = try await User.query(on:req.db).filter(\User.$id,.equal,row.userID).first() else{ return users}
                users.append(user)
            }
        }
        return users
    }
    //Return all the users in the user table that are not a part of the current group - used for adding users to groups
    func returnAllNonGroupUsers(req: Request) async throws -> [User]{
        var users:[User] = []
        if let userID = req.session.data["user"] as? String, let groupID = req.session.data["group"] as? String{
            
            
            let query = try await User.query(on: req.db).all()
            let groupUsers = try await Group.query(on:req.db).filter(\Group.$id, .equal, groupID).all()
            var groupedUser: Bool = false
            for user in query{
                groupedUser = false
                if let checkUserID = user.id as? String{
                    let usersInGroup = try await Group.query(on: req.db).filter(\Group.$userID, .equal, checkUserID).filter(\Group.$id, .equal, groupID).all().count
                   
                
                    if usersInGroup != 0{
                        groupedUser = true
                    }
                }
               
              
                if user.id != userID && user.username != "Admin" && groupedUser==false{                   
                    users.append(user)
                }
            }
        }
        return users
    }

    func changeFactorsTask(req: Request) async throws -> Response{
        struct Packet: Decodable {
            let factors: [[String:String]]
        }
        
        let factors = try req.content.decode(Packet.self).factors
        print(factors)
        var arrayOfFactors: [String] = []
        for factor in factors{
            arrayOfFactors += factor.values
        }

        let factorString = arrayOfFactors.joined(separator: "-")
       
        req.session.data["factors"] = factorString
        
      
        
        return req.redirect(to: "/tasks")
    }
    //Changes the factors for the total task view
    func changeFactorsAll(req: Request) async throws -> Response{
        struct Packet: Decodable {
            let factors: [String]
        }
        
        let factors = try req.content.decode(Packet.self).factors
        let factorString = factors.joined(separator: "-")
        
        req.session.data["factors"] = factorString
        
       
        
        return req.redirect(to: "/group")
    }
    
    
    
    
    
    
    
    
    
    
    
}


