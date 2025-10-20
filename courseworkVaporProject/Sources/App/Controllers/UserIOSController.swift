//
//  File.swift
//  
//
//  Created by Caleb Saunderson on 06/12/2023.
//

import Foundation
import Vapor

//Every controller has a web version and an IOS version due to formatting responses

struct UserIOSController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let usersToDo = routes.grouped("userAPI")
        usersToDo.post("IOSlogin", use: IOSloginPost)
        usersToDo.post("IOScreateUser", use: IOScreateUser)
      
        
    }
    
    func IOSloginPost(req: Request) throws -> EventLoopFuture<String>{
        struct LoginPacket: Decodable {
            let username: String
            let password: String
        }
        
        let loginPacket = try req.content.decode(LoginPacket.self)
        //Hashes the password
        let Hash = Hash()
        let hashedPassword = Hash.hashPassword(password: loginPacket.password, withSalt: Hash.returnSalt())
        print(hashedPassword)
        
        return User.query(on: req.db).filter(\.$username, .equal, loginPacket.username) // Explicitly specify the root type User
            .first()
            .flatMap { user in
                if let user = user, user.passwordMatches(hashedPassword) {
                    // Authentication successful
                    // Handle session or token creation here
                    req.session.data["user"] = user.id
                    print("Login Success")
                    return req.eventLoop.future("Success")
                } else {
                    // Authentication failed
                    return req.eventLoop.future("Fail")
                }
            }
        
    }
    
    func IOScreateUser(req: Request) async throws -> String {
        struct CreatePacket: Decodable {
            let username: String
            let password: String
        }
        
        let createPacket = try req.content.decode(CreatePacket.self)
        let userID = try await generateUniqueUserID(req: req)
        
        let Hash = Hash()
        let hashedPassword = Hash.hashPassword(password: createPacket.password, withSalt: Hash.returnSalt())
        //Check that no users already exist with the same username
        
        let numberOfUsers = try await User.query(on: req.db).filter(\User.$username, .equal, createPacket.username).all().count
        
        if numberOfUsers>0{
            return "Fail"
        }
        let user = User(userID: userID, username: createPacket.username, password: hashedPassword)
        try await user.create(on: req.db)
        
        return "Success"
    }
    
    func generateUniqueUserID(req: Request) async throws  -> String {
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
