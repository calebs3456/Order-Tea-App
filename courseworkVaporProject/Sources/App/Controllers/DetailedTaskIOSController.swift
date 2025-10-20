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

struct DetailedTaskIOSController: RouteCollection {
    //Handles the API requests and directs them to the correct function
    func boot(routes: RoutesBuilder) throws {
        let taskRoute = routes.grouped("IOSSpecificTask")
        taskRoute.post("returnTaskDetails",use: returnTaskDetails)
        taskRoute.post("update", use: update)
        taskRoute.post("create", use: create)
        taskRoute.post("delete", use: deleteTask)
        taskRoute.post("returnUsers", use: returnUsersOfGroup)

    }
    //Query task details from database then return it
    func returnTaskDetails(req: Request) async throws -> [String:String] {
        
        if let taskID = req.session.data["task"] as? String, let subtaskNumber = req.session.data["subtaskNumber"] as? String{
                    // Use the groupID from the session to build your view context
            
            
            
                    guard let task =  try await Task.query(on: req.db).filter(\Task.$id==taskID).filter(\Task.$SubtaskNumber==Int(subtaskNumber) ?? 0).first()
                    else{
                        let context = ["TaskID": "Error","GroupID": "Error","Title:":"Error", "Description": "Error", "AssignedPriority": "Error", "StartDate":"Error", "EndDate":"Error", "Reminder":"Error", "SubtaskNumber":"Error","AssignedTo":  "Error", "AssignedFrom":  "Error", "AccessLevel": "Error", "Complete": "Error"]
                        return context
                            }
                           
                    
                    
                    
                    let assignedToUserName = try await User.find(task.AssignedTo, on:req.db)?.username
                    let assignedFromUserName = try await User.find(task.AssignedFrom, on:req.db)?.username
                    
                  
                    
                    // Rearrange order of dictionary as it shows on IOS app in that order
            let context = ["Title": task.title,"Description": task.description,"TaskID": task.id ?? "Error","GroupID": task.GroupID ?? "Error",  "AssignedPriority": String(task.AssignedPriority), "StartDate":dateToString(date: task.StartDate), "EndDate": dateToString(date: task.EndDate), "Reminder": dateToString(date: task.Reminder),"SubtaskNumber":String(task.SubtaskNumber),"AssignedTo": assignedToUserName ?? "Error", "AssignedFrom": assignedFromUserName ?? "Error","AccessLevel":String(task.AccessLevel), "Complete": String(task.Complete)]
                           
                    return context
                } else {
                    // Handle the case where there's no taskID in the session
                    
               
     
                    let context = ["Title:":"Error", "Description": "Error", "TaskID": "Error","GroupID": "Error","AssignedPriority": "Error", "StartDate":"Error", "EndDate":"Error","Reminder":"Error", "SubtaskNumber":"Error","AssignedTo":  "Error", "AssignedFrom":  "Error", "AccessLevel": "Error", "Complete": "Error"]
                    return context
                }
       
        
    }
    
    
    // In the IOS Api's only strings can be sent, which means certain variables need to be converted to the correct format when received to be dealt with in SQL
    func update(req: Request) async throws -> String{
        
        struct UpdatePacket: Decodable{
            let TaskID: String
            let SubtaskNumber: String
            let Title: String?
            let Description: String?
            let AssignedPriority: String?
            let StartDate:  String?
            let EndDate:  String?
            let Reminder:  String?
            let AccessLevel: String?
            let AssignedTo: String?
            let Complete: String?
        }
        
        var AssignedPriority = 0
        var AccessLevel = 0
        var Complete = false
        
        
        //Formats variables into the correct types to use
        let updatePacket = try req.content.decode(UpdatePacket.self)
        guard let SubtaskNumber = Int(updatePacket.SubtaskNumber) else { return "Fail" }
        do { AssignedPriority = Int(updatePacket.AssignedPriority ?? "0") ?? 0 } catch {  AssignedPriority=0}
        do {  AccessLevel = Int(updatePacket.AccessLevel ?? "0") ?? 0 } catch {  AccessLevel = 0}
        do {  Complete = Bool(updatePacket.Complete ?? "false") ?? false } catch {  Complete = false}
        
        
        guard let task = try await Task.query(on: req.db).filter(\Task.$id,.equal,updatePacket.TaskID).filter(\Task.$SubtaskNumber,.equal, SubtaskNumber).first()
        else{
            return "Fail"
        }
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
        if AssignedPriority == 0{
            task.AssignedPriority = task.AssignedPriority
        }
        else{
            task.AssignedPriority = AssignedPriority ?? task.AssignedPriority
        }
        if AccessLevel == 0{
            task.AccessLevel = task.AccessLevel
        }
        else{
            task.AccessLevel = AccessLevel ?? task.AccessLevel
        }
        if updatePacket.StartDate == ""{
            task.StartDate = task.StartDate
        }
        else{
            do { task.StartDate = stringToDate(updatePacket.StartDate!, format: "yyyy-MM-dd HH:mm:ss") ?? task.StartDate } catch { return "Fail"}
        }
        if updatePacket.EndDate == ""{
            task.EndDate = task.EndDate
        }
        else{
            do { task.EndDate = stringToDate(updatePacket.EndDate!, format: "yyyy-MM-dd HH:mm:ss") ??  task.EndDate } catch { return "Fail"}
        }
        if updatePacket.Reminder == ""{
            task.Reminder = task.Reminder
        }
        else{
            do { task.Reminder = stringToDate(updatePacket.Reminder!, format: "yyyy-MM-dd HH:mm:ss") ??  task.Reminder } catch { return "Fail"}
        }
        if updatePacket.AssignedTo == ""{
            task.AssignedTo = task.AssignedTo
        }
        else{
            task.AssignedTo = updatePacket.AssignedTo ?? task.AssignedTo
        }
        if Complete != true{
            task.Complete=false
        }
        else{
            task.Complete=true
        }
        
        

        
        
        try await task.save(on:req.db)
        return "Success"

    }

    
    //Converts string to date using the inbuilt date formatter function
    func stringToDate(_ dateString: String, format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Optional: Use for fixed format strings
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)    // Optional: Adjust if you need specific timezone
        
        return dateFormatter.date(from: dateString)
    }
    
    
    //Converts date to string using the inbuilt date formatter function
    func dateToString(date: Date) -> String{
        let outputDateFormatter = DateFormatter()
        outputDateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
           
        let dateString = outputDateFormatter.string(from: date)
           
        return dateString
        
    }
    
    
    //Function to create subtasks (same as function to create tasks just different subtask number)
    
    func create(req: Request) async throws -> String{
        struct CreatePacket: Decodable{
            let Title: String
            let Description: String
            let AssignedPriority: String
            let StartDate:  String
            let EndDate:  String
            let Reminder: String
            let AssignedTo: String
            let AccessLevel: String
            
        }

        let createPacket = try req.content.decode(CreatePacket.self)
        
        
        guard let AssignedPriority = Int(createPacket.AssignedPriority) else {return "Fail"}
        guard let AccessLevel = Int(createPacket.AccessLevel) else {return "Fail"}
        
        print(createPacket.StartDate)
        guard let startDate = stringToDate(createPacket.StartDate, format: "yyyy-MM-dd HH:mm:ss") else{
            print("Error")
            return "Fail"
        }
        guard let endDate = stringToDate(createPacket.EndDate, format: "yyyy-MM-dd HH:mm:ss") else{
            print("Error2")
            return "Fail"
        }
   
        guard let reminder = stringToDate(createPacket.Reminder, format: "yyyy-MM-dd HH:mm:ss") else{
            print("Error3")
            return "Fail"
        }
        
        
        if let groupID = req.session.data["group"] as? String{
            
            if let userID = req.session.data["user"] as? String, let parentTaskID = req.session.data["task"] as? String, let subtaskNumber = req.session.data["subtaskNumber"] as? String{
                
                let subtasks = try await Task.query(on: req.db).filter(\Task.$id==parentTaskID).filter(\Task.$SubtaskNumber==Int(subtaskNumber) ?? 0).all()
                
                let subtaskNumber = subtasks.count
                
                let TaskID = try await generateUniqueTaskID(req: req)
              
                let task = Task(GroupID: groupID, TaskID: TaskID, title: createPacket.Title, description: createPacket.Description, subtaskNumber: subtaskNumber, AssignedTo: createPacket.AssignedTo, AssignedFrom: userID, StartDate: startDate, EndDate: endDate ,Reminder: reminder,  AssignedPriority: AssignedPriority, AccessLevel: AccessLevel, Complete: false)
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
    
    //Generates a random task id for subtask
    func generateUniqueTaskID(req: Request) async throws -> String {
       
        if let groupID = req.session.data["group"] as? String{
            
            
            var newTaskID: String
            
            newTaskID = UUID().uuidString + groupID
            
            let taskIDquery = try await Group.query(on:req.db).filter(\Group.$id, .equal, newTaskID).all()
            
            if taskIDquery.isEmpty {
                // No records found with the specified newTaskID, so it's unique.
                return newTaskID
            } else {
                // The newTaskID already exists, generate a new one.
                return try await generateUniqueTaskID(req: req)
            }
        }
        else{
            return "Error"
        }
    }
    //Deletes task by finding the record using the primary composite key TaskID + SubtaskNumber then deleting from database
    func deleteTask(req: Request) async throws -> String {
        print("Delete")
        struct DeletePacket: Decodable{
            let TaskID: String
            let subtaskNumber: String
        }
        
        let deletePacket = try req.content.decode(DeletePacket.self)
        guard let SubtaskNumber = Int(deletePacket.subtaskNumber) else { return "Fail" }
        //Finds unique task by subtask number and taskID
        try await Task.query(on: req.db).filter(\Task.$id,.equal,deletePacket.TaskID).filter(\Task.$SubtaskNumber,.equal, SubtaskNumber).first()?.delete(on: req.db)
        
       
        
        return "Success"
    }
    
    
    
    //Returns avaliable users as part of group to select
    func returnUsersOfGroup(req: Request) async throws -> [String: String]{
        var users = [String:String]()
        if let groupID = req.session.data["group"] as? String{
            let groups = try await Group.query(on: req.db).filter(\Group.$id, .equal, groupID).all()
            for user in groups{
                let userID = user.userID
                guard let username = try await User.query(on: req.db).filter(\User.$id, .equal, userID).first()?.username else {return ["":""]}
                users[username]=userID
            }
        }
        else{
            users = ["":""]
        }
        return users
    }
    
    
}


