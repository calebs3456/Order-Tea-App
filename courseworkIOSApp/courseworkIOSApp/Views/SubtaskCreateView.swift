//
//  TaskCreateView.swift
//  courseworkIOSApp
//
//  Created by Caleb Saunderson on 11/12/2023.
//

import SwiftUI
import Combine
struct SubtaskCreateView: View {
    
    public var detailedTask: DetailedTaskView
   
    @State public var Title: String = ""
    @State public var Description: String = ""
    @State public var AssignedTo: String = ""
    @State public var AssignedPriority: Int = 1
    @State public var AccessLevel: Int = 1
    @State public var StartDate: String = ""
    @State public var EndDate: String = ""
    @State public var Reminder: String = ""
    @State public var startDate = Date()
    @State public var endDate = Date()
    @State public var reminder = Date()
    @State private var characterLimit: Int = 255
    

    @State private var error: Error?
    
    
    @State public var avaliableUsers: [String:String] = [:]
    @State public var avaliableUsernames: [String] = []
    @State public var selectedUser: String = "" //assigned to
    
    
    @State private var activeCreation: Bool = false
    
    
    @State private var searchQuery: String = ""
    var filteredUsernames: [String] {
            guard !searchQuery.isEmpty else {
                return avaliableUsernames
            }
            return avaliableUsernames.filter { $0.lowercased().contains(searchQuery.lowercased()) }
        }
    
    var body: some View {
        VStack{
            Text("Create Task")
                .font(/*@START_MENU_TOKEN@*/.largeTitle/*@END_MENU_TOKEN@*/)
                .fontWeight(.light)
                .multilineTextAlignment(.center).onAppear(){
                    self.activeCreation=false
                    //Fetches users in the group
                    returnUsersOfGroup() { fetchedResponse, fetchedError in
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
                //Textfield to enter text
                TextField("Title", text: $Title).onReceive(Just(Title)) { _ in
                    limitLength()}.font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                TextField("Description", text: $Description).onReceive(Just(Description)) { _ in
                    limitLength()}.font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
               //Number picker
                Stepper(value: $AssignedPriority, in: 1...10) {
                    Text("Priority: " + String(self.AssignedPriority))
                }
                Stepper(value: $AccessLevel, in: 1...5) {
                    Text("Access Level: " + String(self.AccessLevel))
                }
              //Search for users
                Section(header: Text("Assigned To")) {
                    Text(self.selectedUser)
                    TextField("Search Users", text: $searchQuery)
                    
                    List(filteredUsernames, id: \.self) { username in
                                                Text(username)
                                                    .onTapGesture {
                                                        self.selectedUser = username
                                                        
                                                    }.foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    }
                }
                DatePicker("Start Date", selection: $startDate)
                DatePicker("End Date", selection: $endDate)
                DatePicker("Reminder", selection: $reminder)
            }
            
            Button {
                do{
                    StartDate = dateToString(date: startDate)!
                    EndDate = dateToString(date: endDate)!
                    Reminder = dateToString(date: reminder)!
                    
                    AssignedTo = self.avaliableUsers[selectedUser] ?? ""
                    createSubtask(Title: Title, Description: Description, AssignedTo: AssignedTo, AssignedPriority: AssignedPriority, AccessLevel: AccessLevel, StartDate: StartDate, EndDate: EndDate,Reminder: Reminder){ fetchedResponse, fetchedError in
                        if let fetchedResponse = fetchedResponse {
                            if fetchedResponse=="Title"{
                                Alert(title: Text("Choose a unique title"))
                            }
                            if fetchedResponse=="Success"{
                                detailedTask.taskView.reloadData()
                                print("Success")
                            }
                            if fetchedResponse=="Fail"{
                                Alert(title: Text("Failed to create task!"))
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
                Text("Submit")
            }
        
        }
        
    }
    //Limit length
    
    func limitLength(){
        if Title.count>characterLimit{
            Title = String(Title.prefix(characterLimit))
        }
        if Description.count>characterLimit{
            Description = String(Description.prefix(characterLimit))
        }
        
    }
    
    func dateToString(date: Date) -> String?{
        // Date format for formatting the dates to be stored in MySQL
       
        // Initialize a DateFormatter
        let dateFormatter = DateFormatter()

        // Set the date format
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        // Convert Date to String
        let dateString = dateFormatter.string(from: date)

        return dateString
        
    }
    
    
}

#Preview {
    SubtaskCreateView(detailedTask: DetailedTaskView.init(taskView: TaskView.init(groupView: GroupView.init())))
}
