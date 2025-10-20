//
//  File.swift
//  
//
//  Created by Caleb Saunderson on 07/12/2023.
//

import Foundation
import Vapor
struct GroupIOSController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let groups = routes.grouped("groupAPI")
        groups.post("selectGroup",use: selectGroup)
        groups.post("returnGroups",use: returnGroups)
        groups.post("create", use: createGroup)
        groups.post("delete", use: deleteGroup)
        groups.post("notifyTopTask", use: notifyTopTask)
    }
    
    //Returns the avaliable groups for the user to select
    func returnGroups(req: Request)  async throws -> [String:String]{
        
        //Name:ID
        var returnGroups = [String:String]()
        if let userID = req.session.data["user"] as? String {
       
            // Use the groupID from the session to build your view context
            let groupIDs = try await Group.query(on: req.db).filter(\Group.$userID, .equal, userID).all()
    
            //var groups = [GroupName]()
            
            var groups = [GroupName]()
            
            
            for group in groupIDs{
                if let groupID = group.id as? String{
                
                    let groupName = try await GroupName.query(on: req.db).filter(\GroupName.$id, .equal, groupID).first()!
                    
                    do {
                        returnGroups[groupName.groupName] = groupName.id
                    }
                    catch{
                        return ["Error":"Error"]
                    }
                }
                
            }
           
        
            
            return returnGroups
        }else {
            // Handle the case where there's no UserID in the session
            print("No UserID")
            return ["Error":"Error"]
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
    
    
    
    
    func createGroup(req: Request) async throws -> String{
        struct CreatePacket: Decodable{
            let groupName: String
            
        }
        
        //Generates a unique ID and adds record to groupSets and groupName
        
        let createPacket = try req.content.decode(CreatePacket.self)
        var groupID = try await generateUniqueGroupID(req: req)
        let numberOfGroups = try await GroupName.query(on: req.db).filter(\GroupName.$groupName, .equal, createPacket.groupName).all().count
        
        if numberOfGroups>0{
            print("Failed to create group, already exists")
            return "Exists"
        }
      
        if let userID = req.session.data["user"] as? String {
            let groupName = GroupName(GroupID: groupID,  groupName:createPacket.groupName)
            
            try await groupName.create(on: req.db)
         
            let accessLevel = 5
          
            let group = Group(GroupID: groupID, userID: userID, accessLevel: accessLevel)
            
            try await group.create(on: req.db)
        }
        else{
            print("Failed to create group, no user logged in")
            return "User"
        }
        return "Success"
    }
    
    
    //Generates a unqiue group id
    func generateUniqueGroupID(req: Request) async throws -> String {
        var newGroupID: String
        
        newGroupID = UUID().uuidString
        
        let groupIDquery = try await Group.query(on:req.db).filter(\Group.$id, .equal, newGroupID).all()
        
        if groupIDquery.isEmpty {
            // No records found with the specified newUserID, so it's unique.
            return newGroupID
        } else {
            // The newUserID already exists, generate a new one.
            return try await generateUniqueGroupID(req: req)
        }
    }
    
    func deleteGroup(req: Request) async throws -> String {
        //Delete tasks
        //Delete GroupSets
        // Delete GroupNames
        if let groupID = req.session.data["group"] as? String{
            try await Task.query(on: req.db).filter(\Task.$GroupID,.equal,groupID).all().delete(on: req.db)
            try await Group.query(on: req.db).filter(\Group.$id,.equal,groupID).all().delete(on: req.db)
            try await GroupName.query(on: req.db).filter(\GroupName.$id,.equal,groupID).all().delete(on: req.db)
        }else{
            return "Fail"
        }
        return "Success"
    }

    func notifyTopTask(req: Request) async throws -> String{
        //Returns the name of the top task needed to be completed according to the default list of factors
        var factors: [String] = ["EndDate","Progress","StartDate","AccessLevel","AssignedPriority"]
        
        if let userID = req.session.data["user"] as String? {
            let userAccess = try await Group.query(on:req.db).filter(\Group.$userID, .equal, userID).first()?.accessLevel ?? 1
            let tasks = try await Task.query(on: req.db).group(.or) { or in
                or.filter(\Task.$AccessLevel, .lessThanOrEqual, userAccess)
                or.filter(\Task.$AssignedTo, .equal, userID)
            }.all()
            
            let schedulingAlgorithmUsed = schedulingAlgorithm()
            let orderedTasks = try await schedulingAlgorithmUsed.schedulingAlgorithmA(req: req ,tasks: tasks, factors: factors)
            return orderedTasks[0].title
        }
        
        return "Error"
        
    }
    
}

