//
//  File.swift
//  
//
//  Created by Caleb Saunderson on 08/12/2023.
//

import Fluent
import Vapor
import Foundation
import Leaf

struct TaskIOSController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let tasks = routes.grouped("taskAPI")
        
        tasks.post("returnTasks",use: returnTasksDict)
        tasks.post("returnTaskDetails", use: returnTaskDetails)
        tasks.post("returnTaskIDs",use: returnTaskIDs)
        tasks.post("returnAllTasks",use: returnAllTasksDict)
        tasks.post("returnAllTaskIDs",use: returnAllTaskIDs)
        tasks.post("selectTask", use: selectTask)
        tasks.post("create", use: create)
        tasks.post("addUser",use:addUserToGroup)
        tasks.post("returnGroupUsers", use: returnGroupUsers)
        tasks.post("returnAllNonGroupUsers", use: returnAllNonGroupUsers)
        tasks.post("changeFactors", use: changeFactors)
        tasks.post("returnSubtasks",use: returnSubtasksDict)
    }
    
    func returnTasksDict(req: Request)  async throws -> [String:String]{
    
        var tasksDictionary = [String:String]()
        
        if let userID = req.session.data["user"] as? String {
            
            
            if let groupID = req.session.data["group"] as? String {
                let userAccess = try await Group.query(on:req.db).filter(\Group.$userID, .equal, userID).first()?.accessLevel ?? 1
                let tasks = try await Task.query(on: req.db).filter(\Task.$GroupID, .equal, groupID).group(.or) { or in
                    or.filter(\Task.$AccessLevel, .lessThanOrEqual, userAccess)
                    or.filter(\Task.$AssignedTo, .equal, userID)
                }.all()
                
                for task in tasks{
                    do {
                        tasksDictionary[task.id!+String(task.SubtaskNumber)] = task.title
                        
                        
                    }catch{
                        return ["Error":"Error"]
                    }
                    
                }
                 
                
                // Use the groupID from the session to build your view context
                
                
                return tasksDictionary
            } else {
                // Handle the case where there's no groupID in the session
                
                
                return ["Error Task": "Error"]
            }
            
        }else {
            
            return ["Error Task": "Error"] //Change this because this might respond with an error if this occurs
        }
        
        
    }
    
    func returnTaskIDs(req: Request)  async throws -> [String]{
        
        var factors: [String] = ["EndDate","Progress","StartDate","AccessLevel","AssignedPriority"]
        if let factorString = req.session.data["factors"] as? String{
            print("changing factors")
            factors = []
            factors = factorString.components(separatedBy: "-")
            print(factors)
        }
        else{
            factors = ["EndDate","Progress","StartDate","AccessLevel","AssignedPriority"]
        }
        var tasksArray = [String]()
        
        if let userID = req.session.data["user"] as? String {
            
            
            if let groupID = req.session.data["group"] as? String {
                let userAccess = try await Group.query(on:req.db).filter(\Group.$userID, .equal, userID).first()?.accessLevel ?? 1
                let tasks = try await Task.query(on: req.db).filter(\Task.$GroupID, .equal, groupID).group(.or) { or in
                    or.filter(\Task.$AccessLevel, .lessThanOrEqual, userAccess)
                    or.filter(\Task.$AssignedTo, .equal, userID)
                }.all()
                
                let schedulingAlgorithmUsed = schedulingAlgorithm()
                
                //.Group says that inside the bracket group multiple conditions together, .or says that it will be an or statement that groups them
                
                
                
                let orderedTasks = try await schedulingAlgorithmUsed.schedulingAlgorithmA(req: req ,tasks:tasks, factors: factors)  //Change to Only if assigned to you or above priority level
                
                
                for orderedTask in orderedTasks{
                    do {
                        
                        tasksArray.append((orderedTask.id ?? "error")+String(orderedTask.SubtaskNumber))
                        print("returning ", orderedTask.title)
                    }catch{
                        return ["Error"]
                    }
                    
                }
                // Use the groupID from the session to build your view context
                
                
                return tasksArray
            } else {
                // Handle the case where there's no groupID in the session
                
                
                return ["Error Task"]
            }
            
        }else {
            
            return ["Error Task"] //Change this because this might respond with an error if this occurs
        }
        
        
    }
    
    func selectGroup(req: Request)  throws -> String {
        struct GroupPacket: Decodable {
            let groupID: String
        }
        
        let groupPacket = try  req.content.decode(GroupPacket.self)
        req.session.data["group"] = groupPacket.groupID
        
        // Instead of using req.eventLoop.future, you can directly return the response.
        
        return  "Success"
    }
    func selectTask(req: Request)  throws -> String {
        struct TaskPacket: Decodable {
            let TaskID: String
        }
        
        let taskPacket = try req.content.decode(TaskPacket.self)
        req.session.data["task"] = String(taskPacket.TaskID.prefix(72))
        
        let subtask = taskPacket.TaskID.dropFirst(72)
        req.session.data["subtaskNumber"] = String(subtask)
        
        // Instead of using req.eventLoop.future, you can directly return the response.
        
        return  "Success"
    }
    
    
    func create(req: Request) async throws -> String{
        struct CreatePacket: Decodable{
            let Title: String
            let Description: String
            let AssignedPriority: String
            let StartDate:  String
            let EndDate:  String
            let Reminder: String
            let SubtaskNumber: String
            let AssignedTo: String
            let AccessLevel: String
            
        }
        
        let createPacket = try req.content.decode(CreatePacket.self)
        
        guard let assignedPriority = Int(createPacket.AssignedPriority) else { return "Fail" }
        guard let subtaskNumber = Int(createPacket.SubtaskNumber) else { return "Fail" }
        guard let accessLevel = Int(createPacket.AccessLevel) else { return "Fail" }
        
        
        
        guard let startDate = stringToDate(createPacket.StartDate, format: "yyyy-MM-dd HH:mm:ss") else{
            
            return "Fail"
            
        }
        guard let endDate = stringToDate(createPacket.EndDate,format: "yyyy-MM-dd HH:mm:ss") else{
            
            return "Fail"
            
        }
        
        guard let reminder = stringToDate(createPacket.Reminder,format: "yyyy-MM-dd HH:mm:ss") else{
            return "Fail"
        }
        
        
        if let GroupID = req.session.data["group"] as? String{
            let numberOfTitles = try await Task.query(on:req.db).filter(\Task.$GroupID, .equal, GroupID ).filter(\Task.$title,.equal, createPacket.Title).all().count
            if numberOfTitles>0{
                
                return "Title"
                
            }
        }
        else{
            return "Fail"
        }
        
        let assignedToUser = try await User.query(on:req.db).filter(\User.$id==createPacket.AssignedTo).all().count
        if assignedToUser==0{
            
            return "Title"
            
        }
        
        if let groupID = req.session.data["group"] as? String{
            
            if let userID = req.session.data["user"] as? String{
                
                let TaskID = try await generateUniqueTaskID(req: req)
                //Block tasks with the same name
                let task = Task(GroupID: groupID, TaskID: TaskID, title: createPacket.Title, description: createPacket.Description, subtaskNumber: subtaskNumber, AssignedTo: createPacket.AssignedTo, AssignedFrom: userID, StartDate: startDate, EndDate: endDate,Reminder: reminder , AssignedPriority: assignedPriority, AccessLevel: accessLevel, Complete: false)
                try await task.create(on: req.db)
                return "Success"
            }
            else{
                
                return "Fail"
            }
        }
        else{
            
            return "Fail"
        }
    }
    
    func stringToDate(_ dateString: String, format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Optional: Use for fixed format strings
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)    // Optional: Adjust if you need specific timezone
        
        return dateFormatter.date(from: dateString)
    }
    
    
    func dateToString(date: Date) -> String?{
        
        
        // Date format for formatting the dates to be stored in MySQL
        let outputDateFormatter = DateFormatter()
        
        let dateString = outputDateFormatter.string(from: date)
        
        return dateString
        
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
    func addUserToGroup(req: Request) async throws -> String{
        struct Packet: Decodable{
            let userID: String
            let accessLevel: String
        }
        
        
        let packet = try req.content.decode(Packet.self)
        guard let accessLevel = Int(packet.accessLevel) else { return "Fail" }
        let addedUserID = packet.userID
        if addedUserID==""{
            return "Fail"
        }
        if let groupID = req.session.data["group"] as? String{
            let userName = try await User.query(on: req.db).filter(\User.$id,.equal, addedUserID).first()?.username
            let group = Group(GroupID: groupID, userID: addedUserID, accessLevel: accessLevel)
            try await group.create(on: req.db)
        }
        return "Success"
    }
    
    func returnGroupUsers(req: Request) async throws -> [String:String]{
        var users:[String:String] = [:]
        if let groupID = req.session.data["group"] as? String{
            let query = try await Group.query(on: req.db).filter(\Group.$id, .equal, groupID).all()
            
            for row in query{
                
                guard let user = try await User.query(on:req.db).filter(\User.$id,.equal,row.userID).first() else{ return users}
                print(user.username)
                users[user.username] = user.id
            }
        }
        return users
    }
    
    func returnAllNonGroupUsers(req: Request) async throws -> [String:String]{
        var users:[String:String] = [:]
        if let userID = req.session.data["user"] as? String, let groupID = req.session.data["group"] as? String{
            
            
            let query = try await User.query(on: req.db).all()
            let groupUsers = try await Group.query(on:req.db).filter(\Group.$id, .equal, groupID).all()
            var groupedUser: Bool = false
            print("groupedUsers")
            for user in query{
                groupedUser = false
                for x in groupUsers{
                    groupedUser = false
                    if let checkUserID = user.id as? String{
                        let usersInGroup = try await Group.query(on: req.db).filter(\Group.$userID, .equal, checkUserID).filter(\Group.$id, .equal, groupID).all().count
                        
                    
                        if usersInGroup != 0{
                            groupedUser = true
                        }
                    }
                   
                  
                    
                }
                if user.id != userID && user.username != "Admin" && groupedUser==false{
                    users[user.username] = user.id
                }
            }
        }
        
        return users
    }
    
    func changeFactors(req: Request) async throws -> String{
        struct Packet: Decodable {
            let factors: String
        }
        
        let factors = try req.content.decode(Packet.self).factors
       
        req.session.data["factors"] = factors
        
        
        return "Success"
    }
    
    
    func returnAllTasksDict(req: Request)  async throws -> [String:String]{
        print("returning tasks")
       
        var tasksDictionary = [String:String]()
       
        if let userID = req.session.data["user"] as? String {
            
            let groups = try await Group.query(on: req.db).filter(\Group.$userID, .equal, userID).all()
            
            for group in groups{
                
                let userAccess = try await Group.query(on:req.db).filter(\Group.$userID, .equal, userID).first()?.accessLevel ?? 1
                let tasks = try await Task.query(on: req.db).filter(\Task.$GroupID, .equal, group.id).group(.or) { or in
                    or.filter(\Task.$AccessLevel, .lessThanOrEqual, userAccess)
                    or.filter(\Task.$AssignedTo, .equal, userID)
                }.all()
                for task in tasks{
                    do {
                       
                        tasksDictionary[task.id!+String(task.SubtaskNumber)] = task.title
                        
                        
                    }catch{
                        return ["Error":"Error"]
                    }
                    
                }
                 
                
                // Use the groupID from the session to build your view context
                
                
                
            }
            return tasksDictionary
        }else {
            
            return ["Error Task": "Error"] //Change this because this might respond with an error if this occurs
        }
        
        
    }
    
    func returnAllTaskIDs(req: Request)  async throws -> [String]{
        
        var factors: [String] = ["EndDate","Progress","StartDate","AccessLevel","AssignedPriority"]
        if let factorString = req.session.data["factors"] as? String{
            
            factors = []
            factors = factorString.components(separatedBy: "-")
           
        }
        else{
            factors = ["EndDate","Progress","StartDate","AccessLevel","AssignedPriority"]
        }
        var tasksArray = [String]()
        var allTasks: [Task] = []
        
        if let userID = req.session.data["user"] as? String {
            
            let groups = try await Group.query(on: req.db).filter(\Group.$userID, .equal, userID).all()
            for group in groups{
                let userAccess = try await Group.query(on:req.db).filter(\Group.$userID, .equal, userID).first()?.accessLevel ?? 1
                let tasks = try await Task.query(on: req.db).filter(\Task.$GroupID, .equal, group.id).group(.or) { or in
                    or.filter(\Task.$AccessLevel, .lessThanOrEqual, userAccess)
                    or.filter(\Task.$AssignedTo, .equal, userID)
                }.all()
                allTasks += tasks
            }
            let schedulingAlgorithmUsed = schedulingAlgorithm()
            
            //.Group says that inside the bracket group multiple conditions together, .or says that it will be an or statement that groups them
            
            
            
            let orderedTasks = try await schedulingAlgorithmUsed.schedulingAlgorithmA(req: req ,tasks:allTasks, factors: factors)  //Change to Only if assigned to you or above priority level
            
            
            for orderedTask in orderedTasks{
                do {
                    
                    tasksArray.append((orderedTask.id ?? "error")+String(orderedTask.SubtaskNumber))
                    print("returning ", orderedTask.title)
                }catch{
                    return ["Error"]
                }
                
            }
                // Use the groupID from the session to build your view context
                
                
                
            
            return tasksArray
        }else {
            
            return ["Error Task"] //Change this because this might respond with an error if this occurs
        }
        
        
    }
    
    // Return the task details for a specific task
    func returnTaskDetails(req: Request) async throws -> [String:String] {
        
        if let taskID = req.session.data["task"] as? String, let subtaskNumber = req.session.data["subtaskNumber"] as? String{
            
                    guard let task = try await Task.query(on: req.db).filter(\Task.$id,.equal,taskID).filter(\Task.$SubtaskNumber,.equal, Int(subtaskNumber) ?? 0).first()
                    else{
                        let context = ["TaskID": "Error","GroupID": "Error","Title:":"Error", "Description": "Error", "AssignedPriority": "Error", "StartDate":"Error", "EndDate":"Error","Reminder":"Error", "SubtaskNumber":"Error","AssignedTo":  "Error", "AssignedFrom":  "Error","CalculatedPriority":"Error", "AccessLevel": "Error", "Complete": "Error"]
                        return context
                            }
                           
                    let CalculatedPriority = 0
                    
                    
                    let assignedToUserName = try await User.find(task.AssignedTo, on:req.db)?.username
                    let assignedFromUserName = try await User.find(task.AssignedFrom, on:req.db)?.username
                    
                  
                    
                    // Rearrange order of dictionary as it shows on IOS app in that order
                    var context = [String: String]()

                    context["Title"] = task.title
                    context["Description"] = task.description
                    context["TaskID"] = task.id ?? "Error"
                    context["GroupID"] = task.GroupID ?? "Error"
                    context["AssignedPriority"] = String(task.AssignedPriority)
                    context["StartDate"] = dateToString(date: task.StartDate)
                    context["EndDate"] = dateToString(date: task.EndDate)
                    context["Reminder"] = dateToString(date: task.Reminder)
                    context["SubtaskNumber"] = String(task.SubtaskNumber)
                    context["AssignedTo"] = assignedToUserName ?? "Error"
                    context["AssignedFrom"] = assignedFromUserName ?? "Error"
                    context["CalculatedPriority"] = String(CalculatedPriority)
                    context["AccessLevel"] = String(task.AccessLevel)
                    context["Complete"] = String(task.Complete)
                           
                    return context
                } else {
                    // Handle the case where there's no taskID in the session
                    
               
     
                    let context = ["Title:":"Error", "Description": "Error", "TaskID": "Error","GroupID": "Error","AssignedPriority": "Error", "StartDate":"Error", "EndDate":"Error","Reminder":"Error", "SubtaskNumber":"Error","AssignedTo":  "Error", "AssignedFrom":  "Error","CalculatedPriority":"Error", "AccessLevel": "Error", "Complete": "Error"]
                    return context
                }

        
    }
    //Returns all subtasks in the group
    func returnSubtasksDict(req: Request)  async throws -> [String:String]{

        var tasksDictionary = [String:String]()
        
        if let userID = req.session.data["user"] as? String {
            
            
            if let groupID = req.session.data["group"] as? String {
                let userAccess = try await Group.query(on:req.db).filter(\Group.$userID, .equal, userID).first()?.accessLevel ?? 1
                let tasks = try await Task.query(on: req.db).filter(\Task.$GroupID, .equal, groupID).group(.or) { or in
                    or.filter(\Task.$AccessLevel, .lessThanOrEqual, userAccess)
                    or.filter(\Task.$AssignedTo, .equal, userID)
                }.all()
                for task in tasks{
                    do {
                        if task.SubtaskNumber>=1{
                            tasksDictionary[task.id!+String(task.SubtaskNumber)] = task.title
                        }
                       
                        
                        
                    }catch{
                        return ["Error":"Error"]
                    }
                    
                }
                 
                
                // Use the groupID from the session to build your view context
                
                
                return tasksDictionary
            } else {
                // Handle the case where there's no groupID in the session
                
                
                return ["Error Task": "Error"]
            }
            
        }else {
            
            return ["Error Task": "Error"]
        }
        
        
    }

    
}


