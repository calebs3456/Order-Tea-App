//
//  File.swift
//  
//
//  Created by Caleb Saunderson on 01/11/2023.
//

import Fluent
import Vapor
import Foundation
import Leaf

struct DetailedTaskController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let taskRoute = routes.grouped("specificTask")
        taskRoute.get(use: WebTaskTable)
        taskRoute.post("update", use: update)
        taskRoute.post("create", use: create)

    }
    
    struct errorContext: Encodable {
        var message: String
        var urlReturn: String
        var pageName: String
        
    }
    //Template for task details data
    struct TaskDetailsListContext: Encodable {
        let title: String
    
        let TaskID: String
        let GroupID: String
        let Title: String
        let Description: String
        let AssignedPriority: String
        let StartDate: String
        let EndDate: String
        let Reminder: String
        let SubtaskNumber: String
        let AssignedTo: String
        let AssignedFrom: String
        let CalculatedPriority: String
        let AccessLevel: String
        let Complete: String
        
        let groupUsers: [User]
    }
    //Uses TaskDetailsListContext to format data then send it to DetailedTask.leaf
    func WebTaskTable(req: Request) async throws -> View {
        
        if let taskID = req.session.data["task"] as? String, let subtaskNumber = req.session.data["subtaskNumber"] as? String{
                    // Use the groupID from the session to build your view context
            
            
                    
                    guard let task =  try await Task.query(on: req.db).filter(\Task.$id==taskID).filter(\Task.$SubtaskNumber==Int(subtaskNumber) ?? 0).first()
                    else{
                            let message = "Failed to view task detail"
                            let urlReturn = "tasks"
                            let pageName = "Task page"
                            let context = errorContext(message: message, urlReturn: urlReturn, pageName: pageName)
                            return try await req.view.render("Build/Error", context)
                            }
                           
                    let CalculatedPriority = 0
                    
                    
                    let assignedToUserName = try await User.find(task.AssignedTo, on:req.db)?.username
                    let assignedFromUserName = try await User.find(task.AssignedFrom, on:req.db)?.username
                    
            
            
                            
                    let context = TaskDetailsListContext(title: "Specific Task Information",  TaskID: task.id ?? "Error",GroupID: task.GroupID ?? "Error",Title: task.title, Description: task.description, AssignedPriority: String(task.AssignedPriority), StartDate:dateToString(date: task.StartDate), EndDate: dateToString(date: task.EndDate),Reminder: dateToString(date: task.Reminder), SubtaskNumber:String(task.SubtaskNumber),AssignedTo: assignedToUserName ?? "Error", AssignedFrom: assignedFromUserName ?? "Error",CalculatedPriority:String(CalculatedPriority),AccessLevel:String(task.AccessLevel), Complete: String(task.Complete), groupUsers: try await returnGroupUsers(req: req))
                   
                    return try await req.view.render("Build/DetailedTask", context)
                } else {
                    // Handle the case where there's no taskID in the session
                    
               
     
                    let message = "Failed to view task detail"
                    let urlReturn = "tasks"
                    let pageName = "Task page"
                    let context = errorContext(message: message, urlReturn: urlReturn, pageName: pageName)
                    return try await req.view.render("Build/Error", context)
                }
       
        
    }
    
    
    //Updates the task record in the database
    func update(req: Request) async throws -> Response{
        
        struct UpdatePacket: Decodable{
            let TaskID: String
            let SubtaskNumber: Int
            let Title: String?
            let Description: String?
            let AssignedPriority: Int?
            let StartDate:  String?
            let EndDate:  String?
            let Reminder:  String?
            let AccessLevel: Int?
            let AssignedTo: String?
            let Complete: Bool?
        }
        
        let updatePacket = try req.content.decode(UpdatePacket.self)
        guard let task = try await Task.query(on: req.db).filter(\Task.$id,.equal,updatePacket.TaskID).filter(\Task.$SubtaskNumber,.equal, updatePacket.SubtaskNumber).first()
        else{
            let message = "Task not able to update"
            let urlReturn = "specificTask"
            let pageName = "Detailed Task page"
            
            let errorString = message+"-"+urlReturn+"-"+pageName
            req.session.data["errorMessage"] = errorString
            return req.redirect(to: "/error")
        }
        
        //checks if the updated title already exists and checks if user wants to update title
        if let GroupID = req.session.data["group"] as? String{
            if updatePacket.Title == ""{
                task.title = task.title
            }
            else{
                if ((try await Task.query(on:req.db).filter(\Task.$GroupID, .equal, GroupID).filter(\Task.$title, .equal, updatePacket.Title ?? task.title).all().count)) != 0{
                    task.title = task.title
                }
                else{
                    task.title = updatePacket.Title ?? task.title
                }
            }
        }

        //If there is nothing to update to, don't update it
        if updatePacket.Description == ""{
            task.description = task.description
        }
        else{
            task.description = updatePacket.Description ?? task.description
        }
        if updatePacket.AssignedPriority == 0{
            task.AssignedPriority = task.AssignedPriority
        }
        else{
            task.AssignedPriority = updatePacket.AssignedPriority ?? task.AssignedPriority
        }
        if updatePacket.AccessLevel == 0{
            task.AccessLevel = task.AccessLevel
        }
        else{
            task.AccessLevel = updatePacket.AccessLevel ?? task.AccessLevel
        }
        if updatePacket.StartDate == ""{
            task.StartDate = task.StartDate
        }
        else{
            task.StartDate = stringToDate(date: updatePacket.StartDate) ?? task.StartDate
        }
        if updatePacket.EndDate == ""{
            task.EndDate = task.EndDate
        }
        else{
            task.EndDate = stringToDate(date: updatePacket.EndDate) ??  task.EndDate
        }
        if updatePacket.Reminder == ""{
            task.Reminder = task.Reminder
        }
        else{
            task.Reminder = stringToDate(date: updatePacket.Reminder) ??  task.EndDate
        }
        
        if updatePacket.AssignedTo == ""{
            task.AssignedTo = task.AssignedTo
        }
        else{
            task.AssignedTo = updatePacket.AssignedTo ?? task.AssignedTo
        }
        if updatePacket.Complete != true{
            task.Complete=false
        }
        else{
            task.Complete=true
        }
        
        

        
        try await task.save(on:req.db)
        
      
        
        return req.redirect(to: "/specificTask")

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
    //Date to string using inbuilt functions
    func dateToString(date: Date) -> String{
        let outputDateFormatter = DateFormatter()
        outputDateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
           
        let dateString = outputDateFormatter.string(from: date)
           
        return dateString
        
    }
    
    
    //Function to create subtasks (same as function to create tasks just different subtask number)
    
    func create(req: Request) async throws -> Response{
        struct CreatePacket: Decodable{
            let Title: String
            let Description: String
            let AssignedPriority: Int
            let StartDate:  String
            let EndDate:  String
            let Reminder:  String
            let AssignedTo: String
            let AccessLevel: Int
        }

        let createPacket = try req.content.decode(CreatePacket.self)
        print(createPacket.StartDate)
        
        
        
  
        guard let startDate = stringToDate(date: createPacket.StartDate) else{
            print("Error")
            let message = "Unable to create subtask"
            let urlReturn = "specificTask"
            let pageName = "Detailed Task page"
            
            let errorString = message+"-"+urlReturn+"-"+pageName
            req.session.data["errorMessage"] = errorString
            return req.redirect(to: "/error")
        }
        guard let endDate = stringToDate(date: createPacket.EndDate) else{
            print("Error")
            let message = "Unable to create subtask"
            let urlReturn = "specificTask"
            let pageName = "Detailed Task page"
            
            let errorString = message+"-"+urlReturn+"-"+pageName
            req.session.data["errorMessage"] = errorString
            return req.redirect(to: "/error")
        }
        guard let reminder = stringToDate(date: createPacket.Reminder) else{
            print("Error")
            let message = "Unable to create subtask"
            let urlReturn = "specificTask"
            let pageName = "Detailed Task page"
            
            let errorString = message+"-"+urlReturn+"-"+pageName
            req.session.data["errorMessage"] = errorString
            return req.redirect(to: "/error")
        }
        
        
        if let groupID = req.session.data["group"] as? String{
            
            if let userID = req.session.data["user"] as? String, let parentTaskID = req.session.data["task"] as? String, let subtaskNumber = req.session.data["subtaskNumber"] as? String{
                
                let subtasks = try await Task.query(on: req.db).filter(\Task.$id==parentTaskID).filter(\Task.$SubtaskNumber==Int(subtaskNumber) ?? 0).all()
                
                let subtaskNumber = subtasks.count
                //Parent task ID + taskID
                let generated = try await generateUniqueTaskID(req: req)
                let TaskID = parentTaskID + generated
                let task = Task(GroupID: groupID, TaskID: TaskID, title: createPacket.Title, description: createPacket.Description, subtaskNumber: subtaskNumber, AssignedTo: createPacket.AssignedTo, AssignedFrom: userID, StartDate: startDate, EndDate: endDate , Reminder: reminder, AssignedPriority: createPacket.AssignedPriority, AccessLevel: createPacket.AccessLevel, Complete: false)
                try await task.create(on: req.db)
                return req.redirect(to: "/specificTask")
            }
            else{
                let message = "Unable to create subtask"
                let urlReturn = "specificTask"
                let pageName = "Detailed Task page"
                
                let errorString = message+"-"+urlReturn+"-"+pageName
                req.session.data["errorMessage"] = errorString
                return req.redirect(to: "/error")
            }
        }
        else{
            let message = "Unable to create subtask"
            let urlReturn = "specificTask"
            let pageName = "Detailed Task page"
            
            let errorString = message+"-"+urlReturn+"-"+pageName
            req.session.data["errorMessage"] = errorString
            return req.redirect(to: "/error")
        }
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
    //Returns all users in group to select
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
    
    
}
