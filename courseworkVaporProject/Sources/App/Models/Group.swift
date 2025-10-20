//
//  File.swift
//  
//
//  Created by Caleb Saunderson on 29/09/2023.
//

import Fluent
import Vapor

final class Group: Model, Content {
    
    //Model of a record in the table groupSets
    
    static let schema = "groupSets"
    
    
    @ID(custom: "GroupID")
    var id: String?

    @Field(key: "UserID")
    var userID: String
    
    @Field(key: "AccessLevel")
    var accessLevel: Int
    
   
   

    init() { }

    init(GroupID: String, userID: String, accessLevel: Int) {
        self.id = GroupID
        self.userID = userID
        self.accessLevel = accessLevel
        
    }
}
