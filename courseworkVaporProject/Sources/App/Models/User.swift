//
//  File.swift
//  
//
//  Created by Caleb Saunderson on 09/09/2023.
//
import Fluent
import Vapor


final class User: Model, Content {

    //Model for a record in the table users
    static let schema = "users"
    
    
    @ID(custom:  "userID")
    var id: String?

    @Field(key: "username")
    var username: String
    
    @Field(key: "password")
    var password: String
    
    func passwordMatches(_ plaintext: String) -> Bool {
           
            return plaintext == password
    }
   

    init() { }

    init(userID: String? = nil, username: String, password: String) {
        self.id = userID
        self.username = username
        self.password = password
        
    }
    
  
}
