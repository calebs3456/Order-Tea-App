//
//  File.swift
//  
//
//  Created by Caleb Saunderson on 12/10/2023.
//

import Foundation
import Vapor

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let usersToDo = routes.grouped("user")
        usersToDo.get(use: webLoginView)
        usersToDo.post("login", use: loginPost)
        usersToDo.post("createUser", use: createUser)
        usersToDo.post("deleteUser", use: deleteUser)
        
    }
    

    
    func loginView(req: Request)  throws -> EventLoopFuture<View> {
        return req.view.render("login.leaf")
    }
    
    
    struct UserLoginContext: Encodable {
        let title: String
        
    }
    
    func webLoginView(req: Request) async throws -> View {
        let context = UserLoginContext(title: "Task List")
        return try await req.view.render("Build/login", context)
    }
    
    
    //Checks username and hashed password against database record
    func loginPost(req: Request) throws -> EventLoopFuture<Response>{
        struct LoginPacket: Decodable {
            let Username: String
            let Password: String
        }
        
        let loginPacket = try req.content.decode(LoginPacket.self)
        //Hashes password
        let Hash = Hash()
        let hashedPassword = Hash.hashPassword(password: loginPacket.Password, withSalt: Hash.returnSalt())
        
        print(hashedPassword)
        return User.query(on: req.db).filter(\.$username, .equal, loginPacket.Username) // Explicitly specify the root type User
            .first()
            .flatMap { user in
                if let user = user, user.passwordMatches(hashedPassword) {
                    // Authentication successful
                    // Handle session or token creation here
                    req.session.data["user"] = user.id
                    return req.eventLoop.future(req.redirect(to: "/group"))
                } else {
                    // Authentication failed
                   
                    let message = "Failed to login"
                    let urlReturn = "user"
                    let pageName = "Login page"
                    
                    let errorString = message+"-"+urlReturn+"-"+pageName
                    req.session.data["errorMessage"] = errorString
                    
                    //Somehow send information back to show failed login
                    return req.eventLoop.future(req.redirect(to: "/error"))
                }
            }
        
    }
    //Delete User API
    func deleteUser(req:Request) async throws -> Response{
        
        if let userID = req.session.data["user"] as? String{
            try await Task.query(on: req.db).filter(\Task.$AssignedTo, .equal, userID).all().delete(on:req.db)
            try await Task.query(on: req.db).filter(\Task.$AssignedFrom, .equal, userID).all().delete(on:req.db)
          
            
            let groupUsers = try await Group.query(on: req.db).filter(\Group.$userID, .equal, userID).all()
            for groupUser in groupUsers{
                // Every group the user is a part of
                let groupUserAccessLevel = groupUser.accessLevel
                print(groupUserAccessLevel)
                if groupUserAccessLevel==5{ // If Access level is 5 we need to make sure another user can take control
                    let numberOfAccessFives = try await Group.query(on: req.db).filter(\Group.$id ,.equal, groupUser.id ?? "Error").filter(\Group.$accessLevel, .equal, 5).all().count
                    if numberOfAccessFives == 1{
                        //Only one person who is a level 5, so next person down is upgraded to controlling user
                        var accessLevel: Int = 4
                        while try await Group.query(on: req.db).filter(\Group.$id ,.equal, groupUser.id ?? "Error").filter(\Group.$accessLevel, .equal, accessLevel).all().count == 0{
                            accessLevel-=1
                            
                            if accessLevel == -1{
                                //No one else in the group delete everything to do with the group
                                
                                try await Task.query(on: req.db).filter(\Task.$GroupID, .equal, groupUser.id).delete()
                                try await GroupName.query(on: req.db).filter(\GroupName.$id, .equal, groupUser.id ?? "Error").delete()
                                try await Group.query(on: req.db).filter(\Group.$id ,.equal, groupUser.id ?? "Error").filter(\Group.$accessLevel, .equal, accessLevel).delete()
                                
                                break
                            }
                        }
                        if accessLevel > -1{
                            
                            var newControlUser = try await Group.query(on: req.db).filter(\Group.$id ,.equal, groupUser.id ?? "Error").filter(\Group.$accessLevel, .equal, accessLevel).filter(\Group.$userID, .notEqual, userID).first()
                            newControlUser?.accessLevel = 5
                            try await newControlUser?.save(on: req.db)
                        }
                       
                        
                        
                        
                    }
                    
                }
                try await Group.query(on:req.db).filter(\Group.$id,.equal,groupUser.id ?? "Error").filter(\Group.$userID,.equal,groupUser.userID).delete()
            }
            try await User.query(on: req.db).filter(\User.$id, .equal, userID).first()?.delete(on:req.db)
        }
        else{
            let message = "Failed to delete user"
            let urlReturn = "user"
            let pageName = "Login page"
            
            let errorString = message+"-"+urlReturn+"-"+pageName
            req.session.data["errorMessage"] = errorString
            
            
            return req.redirect(to: "/error")
        }
        return req.redirect(to: "/user")
        
    }
    //Create User API - packet with Username and Password
    func createUser(req: Request) async throws -> Response {
        struct CreatePacket: Decodable {
            let username: String
            let password: String
        }
        
        let createPacket = try req.content.decode(CreatePacket.self)
        let userID = try await generateUniqueUserID(req: req)
        //Hashes the password
        let Hash = Hash()
        let hashedPassword = Hash.hashPassword(password: createPacket.password, withSalt: Hash.returnSalt())
        //Ensures username is unique
        let numberOfUsers = try await User.query(on: req.db).filter(\User.$username, .equal, createPacket.username).all().count
        
        if numberOfUsers>0{
            print("Failed to create user, already exists")
            let message = "Failed to create user"
            let urlReturn = "user"
            let pageName = "Login page"
            
            let errorString = message+"-"+urlReturn+"-"+pageName
            req.session.data["errorMessage"] = errorString
            
            
            return req.redirect(to: "/error")
            
        }
        
        let user = User(userID: userID, username: createPacket.username, password: hashedPassword)
        try await user.create(on: req.db)
        
        return req.redirect(to: "/user")
    }
    
    func generateUniqueUserID(req: Request) async throws  -> String {
        
        //Ensures the UserID generated is unqiue
        var newUserID: String

        newUserID = UUID().uuidString
        
        let userIDquery = try await User.query(on:req.db).filter(\User.$id, .equal, newUserID).all()
        
        if userIDquery.isEmpty {
               // No records found with the specified newUserID, so it's unique.
               return newUserID
           } else {
               // The newUserID already exists, generate a new one.
               return try await generateUniqueUserID(req: req)
           }
        
    }





   

    
}
