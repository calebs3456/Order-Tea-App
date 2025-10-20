//
//  TaskView.swift
//  courseworkIOSApp
//
//  Created by Caleb Saunderson on 08/12/2023.
//

import SwiftUI
import UIKit


//This is a task template solely used for the purpose of ordering and correctly rendering the list of tasks
struct Task {
    var id: String
    var title: String
    var isSubtask: Bool
}

struct TaskView: View {
    
    @State public var groupView: GroupView
    @State private var responseDict: [String:String] = ["":""]
    @State private var taskDict: [Task] = []
    @State private var subtasksDict: [String:String] = ["":""]
    @State private var error: Error?
    @State private var titleList: [String] = []
    @State private var taskStrings: [String] = []
    
    @State public var isCreateActive: Bool = false
    @State private var activeTask: Bool = false
    @State public var addingUser: Bool = false
    @State public var changingFactors: Bool = false

    
    var body: some View {
        ZStack{
            Color.gray.edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Tasks")
                    .font(.largeTitle)
                    .onAppear {
                        self.isCreateActive=false
                        self.activeTask = false
                        self.addingUser = false
                        self.changingFactors = false
                        //Fetch the avaliable tasks to select
                        returnTasks { fetchedResponse, fetchedError in
                            if let fetchedResponse = fetchedResponse {
                                self.responseDict = fetchedResponse
                                
                            } else if let fetchedError = fetchedError {
                                self.responseDict = ["Failed": "Failed"]
                                self.error = fetchedError
                            }
                        }
                        // Used to show which tasks are subtasks
                        returnSubTasks { fetchedResponse, fetchedError in
                            if let fetchedResponse = fetchedResponse {
                                self.subtasksDict = fetchedResponse
                                
                            } else if let fetchedError = fetchedError {
                                self.subtasksDict = ["Failed": "Failed"]
                                self.error = fetchedError
                            }
                        }
                        
                        //Second return function of task names and IDs
                        
                        //Not working very well check
                        returnTaskIDs { fetchedResponse, fetchedError in
                            if let fetchedResponse = fetchedResponse {
                                
                                self.taskStrings = fetchedResponse
                                
                                
                                
                                self.error = nil
                            } else if let fetchedError = fetchedError {
                                self.taskStrings = ["Failed"]
                                self.error = fetchedError
                            }
                        }
                        
                    }
                
                Button("reload"){
                    reloadData()
                }.fontWeight(.medium)
                    .font(.title)
                    .foregroundColor(Color.white)
                    .background(Color.blue)
                    .frame(width: UIScreen.main.bounds.width*0.8)
                    .cornerRadius(10)
                   
                
                //Scroll view for the tasks
                ScrollView {
                    Text("Scroll")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    ForEach(self.taskStrings, id: \.self) {task in
                        
                        
                        
                        //Button for selecting tasks.
                        Button{
                            selectTask(taskID:  task) { fetchedResponse, fetchedError in
                                if let fetchedResponse = fetchedResponse {
                                    if fetchedResponse == "Success"{
                                        self.activeTask = true
                                        
                                    }
                                    else{
                                        Alert(title: Text("Selection failed!"))
                                        self.activeTask = false
                                    }
                                    
                                }
                                
                                
                            }
                        }label: {
                            
                            Text(self.responseDict[task] ?? "Error")
                                .fontWeight(.light)
                                .font(.largeTitle)
                                .foregroundColor(Color.white)
                                .background(self.subtasksDict[task] != nil ? Color.gray : Color.blue)
                                .frame(width: UIScreen.main.bounds.width*0.8)
                                .cornerRadius(10)
                                .padding()
                               
                        }
                        
                        //Navigate to detailed task page
                        NavigationLink(destination: DetailedTaskView(taskView: self), isActive: $activeTask ) {
                            EmptyView()
                        }.hidden()
                        
                        
                        
                    }
                   
                        Button{
                            self.isCreateActive = true
                        }label:{
                            Text("Create Task")
                                .fontWeight(.medium)
                                .font(.largeTitle)
                                .foregroundColor(Color.white)
                                .background(Color.blue)
                                .cornerRadius(10)
                                .padding()
                        }
                        
                        NavigationLink(destination: TaskCreateView(taskView: self), isActive: $isCreateActive ) {
                            EmptyView()
                        }.hidden()
                        
                        Button{
                            self.changingFactors = true
                        }label:{
                            Text("Change Factor Order")
                                .fontWeight(.medium)
                                .font(.largeTitle)
                                .foregroundColor(Color.white)
                                .background(Color.blue)
                                .cornerRadius(10)
                                .padding()
                        }
                        
                        NavigationLink(destination: ChangeFactorsView(taskView: self), isActive: $changingFactors ) {
                            EmptyView()
                        }.hidden()
                        
                        
                        
                        
                        Button{
                            self.addingUser = true
                        }label:{
                            Text("Add User to Group")
                                .fontWeight(.medium)
                                .font(.largeTitle)
                                .foregroundColor(Color.white)
                                .background(Color.blue)
                                .cornerRadius(10)
                                .padding()
                        }
                        
                        NavigationLink(destination: AddUserToGroupView(taskView: self), isActive: $addingUser ) {
                            EmptyView()
                        }.hidden()
                        
                        Button{
                            deleteGroup(){ fetchedResponse, fetchedError in
                                if let fetchedResponse = fetchedResponse {
                                    if fetchedResponse == "Success"{
                                        groupView.reloadData()
                                    }
                                }
                                
                            }
                        }label:{
                            Text("Delete Group")
                                .fontWeight(.medium)
                                .font(.largeTitle)
                                .foregroundColor(Color.white)
                                .background(Color.red)
                                .cornerRadius(10)
                                .padding()
                        }
                        
                    
                }.background(Color.white).scrollIndicatorsFlash(onAppear: true )
                Spacer()
                    
            }
        }
                                    
                
    }
    //Reload the data on the screen - tasks 
    public func reloadData(){
        
        self.isCreateActive=false
        self.activeTask = false
        self.addingUser = false
        self.changingFactors = false
        
        returnTasks { fetchedResponse, fetchedError in
            if let fetchedResponse = fetchedResponse {
                
                self.responseDict = fetchedResponse
                
                print(self.responseDict)
                
               
                self.error = nil
            } else if let fetchedError = fetchedError {
   
                self.error = fetchedError
            }
        }
        
        returnTaskIDs { fetchedResponse, fetchedError in
            if let fetchedResponse = fetchedResponse {
                self.taskStrings = fetchedResponse
              
                print(self.taskStrings)
      
                self.error = nil
            } else if let fetchedError = fetchedError {
                self.taskStrings = ["Failed"]
                self.error = fetchedError
            }
        }

    }
    
   

    
}
//Test
#Preview {
    TaskView(groupView: GroupView.init())
}
