//
//  TotalTaskView.swift
//  courseworkIOSApp
//
//  Created by Caleb Saunderson on 19/01/2024.
//

import SwiftUI

struct TotalTaskView: View {
    
    @State public var groupView: GroupView
    @State private var responseDict: [String:String] = ["":""]
    @State private var specificDict: [String:String] = ["":""]
    @State private var error: Error?
    @State private var titleList: [String] = []
    @State private var taskStrings: [String] = []
    
    
    @State private var activeTask: Bool = false

    @State public var changingFactors: Bool = false
    
    var body: some View {
        ZStack{
            Color.gray.edgesIgnoringSafeArea(.all)
            VStack {
                Text("Tasks")
                    .font(.largeTitle)
                    .onAppear {
                        
                        self.activeTask = false
                        
                        self.changingFactors = false
                        //Fetch all tasks related to user
                        returnAllTasks { fetchedResponse, fetchedError in
                            if let fetchedResponse = fetchedResponse {
                                self.responseDict = fetchedResponse
                                
                                
                                
                            } else if let fetchedError = fetchedError {
                                self.responseDict = ["Failed": "Failed"]
                                self.error = fetchedError
                            }
                        }
                        
                        
                        returnAllTaskIDs { fetchedResponse, fetchedError in
                            if let fetchedResponse = fetchedResponse {
                                
                                self.taskStrings = fetchedResponse
                                
                                
                                self.specificDict = self.responseDict ?? ["Failed": "Failed"]
                                self.error = nil
                            } else if let fetchedError = fetchedError {
                                self.taskStrings = ["Failed"]
                                self.error = fetchedError
                            }
                        }
                        
                    }
                
                Button("reload"){
                    reloadData()
                }
                //Scroll view of tasks
                
                ScrollView {
                    
                    ForEach(self.taskStrings, id: \.self) {task in
                        
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
                                .background(Color.blue)
                                .frame(width: UIScreen.main.bounds.width*0.8)
                                .cornerRadius(10)
                                .padding()
                        }
                        
                        
                        
                        
                        
                        
                    }
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
                    
                    NavigationLink(destination: ChangeAllFactorsView(taskView: self), isActive: $changingFactors ) {
                        EmptyView()
                    }.hidden()
                    
                    NavigationLink(destination: InformativeTaskView(taskView: self), isActive: $activeTask ) {
                        EmptyView()
                    }.hidden()
                }.background(Color.white)
                
                Spacer()
            }
        }
    }
    
    //Refresh task list
    func reloadData(){
        
        
        self.activeTask = false
        
        self.changingFactors = false
        
        returnAllTasks { fetchedResponse, fetchedError in
            if let fetchedResponse = fetchedResponse {
                
                self.responseDict = fetchedResponse
                
                
                
                
                self.error = nil
            } else if let fetchedError = fetchedError {
                
                self.error = fetchedError
            }
        }
        
        returnAllTaskIDs { fetchedResponse, fetchedError in
            if let fetchedResponse = fetchedResponse {
                self.taskStrings = fetchedResponse
                
                
                
                self.error = nil
            } else if let fetchedError = fetchedError {
                self.taskStrings = ["Failed"]
                self.error = fetchedError
            }
        }
        
    }
        
    
}
#Preview {
    TotalTaskView(groupView: GroupView.init())
}
