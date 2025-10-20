//
//  AddUserToGroupView.swift
//  courseworkIOSApp
//
//  Created by Caleb Saunderson on 07/01/2024.
//

import SwiftUI

struct AddUserToGroupView: View {
    @State public var taskView: TaskView
    @State public var userID: String = ""
    @State public var AccessLevel: Int = 1
    
    @State private var characterLimit: Int = 255
    
    @State public var avaliableUsers: [String:String] = [:]
    @State public var avaliableUsernames: [String] = []
    @State public var selectedUser: String = "" //assigned to
    
    @State private var searchQuery: String = ""
    var filteredUsernames: [String] {
            guard !searchQuery.isEmpty else {
                return avaliableUsernames
            }
            return avaliableUsernames.filter { $0.lowercased().contains(searchQuery.lowercased()) }
        }
    
    var body: some View {
        VStack{
            Text("Add User To Group")
                .font(/*@START_MENU_TOKEN@*/.largeTitle/*@END_MENU_TOKEN@*/)
                .fontWeight(.light)
                .multilineTextAlignment(.center).onAppear(){
                    returnAllNonGroupUsers() { fetchedResponse, fetchedError in
                        if let fetchedResponse = fetchedResponse {
                            self.avaliableUsers = fetchedResponse
                            self.avaliableUsernames = Array(self.avaliableUsers.keys)
                        } else if let fetchedError = fetchedError {
                            self.avaliableUsers = ["Failed": "Failed"]
                            self.avaliableUsernames = ["Failed"]
                        }
                    }
                }
            Form{
                
                
                
                Stepper(value: $AccessLevel, in: 1...5) {
                    Text("Access Level: " + String(self.AccessLevel))
                }
               
                //Search for users
                Section(header: Text("User")) {
                    Text(self.selectedUser)
                    TextField("Search Users", text: $searchQuery)
                    
                    List(filteredUsernames, id: \.self) { username in
                                                Text(username)
                                                    .onTapGesture {
                                                        self.selectedUser = username
                                                        
                                                    }.foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    }
                }

     
                
                Button {
                    do{
                        //Add user to group api request
                        userID = self.avaliableUsers[selectedUser] ?? ""
                        addUserToGroup(userID: userID, AccessLevel: AccessLevel ){ fetchedResponse, fetchedError in
                            if let fetchedResponse = fetchedResponse {
                                
                                if fetchedResponse=="Success"{
                                    self.taskView.addingUser = false
                                    print("Success")
                                }
                                if fetchedResponse=="Fail"{
                                    Alert(title: Text("Failed to add user!"))
                                    print("Fail")
                                }
                                
                                
                                
                            }
                            if let fetchedError = fetchedError{
                                print(fetchedError)
                            }
                        }
                    }
                    catch{
                        Alert(title: Text("Fill out all fields"))
                    }
                }label: {
                    Text("Submit").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                }
                
            }
        }
        
        
    }

}
#Preview {
    AddUserToGroupView(taskView: TaskView.init(groupView: GroupView.init()))
}
