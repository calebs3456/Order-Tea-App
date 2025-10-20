//
//  File.swift
//
//
//  Created by Caleb Saunderson on 12/10/2023.
//

import Foundation
import Vapor

struct GroupController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let groups = routes.grouped("group")
        groups.get(use: GroupWebView)
        groups.post("selectGroup",use: selectGroup)
        groups.post("createGroup", use: createGroup)
        groups.post("delete", use: deleteGroup)
        groups.post("logout", use: logOut)
    }
    
    
    func GroupView(req: Request)  throws -> EventLoopFuture<View> {
        return req.view.render("groups")
    }
    
    struct errorContext: Encodable {
        var message: String
        var urlReturn: String
        var pageName: String
        
    }
    //Template for data to be sent to groups.leaf
    struct GroupsContext: Encodable {
        let title: String
        let groups: [GroupName]
        let groupSets: [Group]
        let allTasks: [Task]
        let userName: String
        let userID: String
    }
    
    //Use GroupsContext template for data to be sent to groups.leaf
    //Queries database to get avaliable groups
    func GroupWebView(req: Request) async throws -> View {
        
        
        if let userID = req.session.data["user"] as? String {
            // Use the groupID from the session to build your view context
            let groupIDs = try await Group.query(on: req.db).filter(\Group.$userID, .equal, userID).all()
            
            //var groups = [GroupName]()
            
            var groups = [GroupName]()
            
            
            for group in groupIDs{
                if let groupID = group.id as? String{
                    try await groups.append(try await GroupName.query(on: req.db)
                        .filter(\GroupName.$id, .equal, groupID)
                        .first()!)
                    
                }
                
            }
            var username = "Error"
            do{
                username = try await User.query(on:req.db).filter(\User.$id,.equal,userID).first()!.username
            }
            catch{
                username = "Error"
            }
            let allTasks = try await returnAllTask(req: req)
            let context = GroupsContext(title: "Group List", groups: groups, groupSets: groupIDs, allTasks: allTasks, userName: username, userID: userID)
            
            return try await req.view.render("Build/groups", context)
        }else {
            let allTasks = try await returnAllTask(req: req)
            // Handle the case where there's no groupID in the session
            //let context = GroupsContext(title: "Group List", groups: try await GroupName.query(on: req.db).all(), allTasks: allTasks,userName: "Error", userID: "Error")
            
            let message = "Failed to view groups"
            let urlReturn = "user"
            let pageName = "User page"
            let context = errorContext(message: message, urlReturn: urlReturn, pageName: pageName)
            return try await req.view.render("Build/Error", context)
        }
        
    }
    
    func getGroupIDsFromDatabase(req: Request) throws -> EventLoopFuture<[String?]> {
        
        if let userID = req.session.data["user"] as? String {
            return Group.query(on: req.db)
                .filter(\Group.$userID, .equal, userID)
                .all()
                .map { groups in
                    return groups.map { $0.id }
                }
        }else{
            return req.eventLoop.future([])
        }
        
    }
    
    
    
    func selectGroup(req: Request)  throws -> EventLoopFuture<Response> {
        struct GroupPacket: Decodable {
            let groupID: String
        }
        
        let groupPacket = try  req.content.decode(GroupPacket.self)
        req.session.data["group"] = groupPacket.groupID
        
        // Instead of using req.eventLoop.future, you can directly return the response.
        
        return  req.eventLoop.future(req.redirect(to: "/tasks"))
    }
    
    func createGroup(req: Request) async throws -> Response{
        struct CreatePacket: Decodable{
            let groupName: String
            
        }
        let createPacket = try req.content.decode(CreatePacket.self)
        var groupID = try await generateUniqueGroupID(req: req)
        let numberOfGroups = try await GroupName.query(on: req.db).filter(\GroupName.$groupName, .equal, createPacket.groupName).all().count
        
        if numberOfGroups>0{
            print("Failed to create group, already exists")
            let message = "Failed to create group"
            let urlReturn = "group"
            let pageName = "Group page"
            
            let errorString = message+"-"+urlReturn+"-"+pageName
            req.session.data["errorMessage"] = errorString
            
            
            return req.redirect(to: "/error")
        }
        
        if let userID = req.session.data["user"] as? String {
            let groupName = GroupName(GroupID: groupID,  groupName:createPacket.groupName)
            
            try await groupName.create(on: req.db)
            
            let accessLevel = 5
            
            let group = Group(GroupID: groupID, userID: userID, accessLevel: accessLevel)
            try await group.create(on: req.db)
        }
        else{
            let message = "Failed to create group"
            let urlReturn = "group"
            let pageName = "Group page"
            
            let errorString = message+"-"+urlReturn+"-"+pageName
            req.session.data["errorMessage"] = errorString
            
            
            return req.redirect(to: "/error")
        }
        return req.redirect(to: "/group")
    }
    
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
    
    func deleteGroup(req: Request) async throws -> Response {
        //Delete tasks
        //Delete GroupSets
        // Delete GroupNames
        struct packet: Decodable{
            let groupID: String
        }
        let groupID = try req.content.decode(packet.self).groupID
        try await Task.query(on: req.db).filter(\Task.$GroupID,.equal,groupID).all().delete(on: req.db)
        try await Group.query(on: req.db).filter(\Group.$id,.equal,groupID).all().delete(on: req.db)
        try await GroupName.query(on: req.db).filter(\GroupName.$id,.equal,groupID).all().delete(on: req.db)
        
        return req.redirect(to: "/group")
    }
    
    func returnAllTask(req: Request)  async throws -> [Task]{
        
        var factors: [String] = ["EndDate","Progress","StartDate","AccessLevel","AssignedPriority"]
        if let factorString = req.session.data["factors"] as? String{
            
            factors = []
            factors = factorString.components(separatedBy: "-")
           
        }
        else{
            factors = ["EndDate","Progress","StartDate","AccessLevel","AssignedPriority"]
        }
        var tasksArray = [Task]()
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
                    
                    tasksArray.append(orderedTask)
                    
                }catch{
                    return [Task.init()]
                }
                
            }
                // Use the groupID from the session to build your view context
                
                
                
            
            return tasksArray
        }else {
            
            return [Task.init()] //Change this because this might respond with an error if this occurs
        }
        
        
    }
    
    
    func logOut(req: Request) async throws -> Response{
        
        req.session.data["user"] = ""
        req.session.data["group"] = ""
        req.session.data["factors"] = ""
        req.session.data["task"] = ""
        req.session.data["errorMessage"] = ""
        return req.redirect(to: "/user")
    }


}
