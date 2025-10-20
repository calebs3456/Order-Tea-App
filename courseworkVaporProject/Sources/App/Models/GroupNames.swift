//
//  File.swift
//  
//
//  Created by Caleb Saunderson on 30/09/2023.
//

import Foundation
import Fluent
import Vapor

final class GroupName: Model, Content {
  
    
   
    //Model of a record in the table groupNames
    static let schema = "groupNames"
    
    
    @ID(custom: "GroupID")
    var id: String?

    @Field(key: "GroupName")
    var groupName: String
    
    
    
   
   

    init() { }

    init(GroupID: String, groupName: String) {
        self.id = GroupID
        self.groupName = groupName
        
        
        
    }
}
