//
//  Item.swift
//  courseworkIOSApp
//
//  Created by Caleb Saunderson on 06/12/2023.
//

import Foundation
import SwiftData

@Model
final class Settings {
   
    
    var Username: String
    var Password: String
    var UserID: String


    init(username: String, password: String, userID: String){
        self.Username = username
        self.Password = password
        self.UserID = userID
    }

        
}
