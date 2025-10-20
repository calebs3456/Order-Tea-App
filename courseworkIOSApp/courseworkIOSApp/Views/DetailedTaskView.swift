//
//  DetailedTaskView.swift
//  courseworkIOSApp
//
//  Created by Caleb Saunderson on 09/12/2023.
//

import SwiftUI

struct DetailedTaskView: View {
    
    public var taskView: TaskView
    @State private var responseDict: [String:String] = ["":""]
    @State private var specificDict: [String:String] = ["":""]
    @State private var error: Error?
    @State private var titleList: [String] = []
    
    
    
    @State public var isUpdateActive: Bool = false
    @State public var isCreateActive: Bool = false
    
    
    var body: some View {
        ZStack{
            Color.gray.edgesIgnoringSafeArea(.all)
        
            VStack {
                Text("Task Details")
                    .font(.largeTitle)
                    .onAppear {
                        //Fetch the the task details
                        self.isUpdateActive = false
                        self.isCreateActive=false
                        returnTaskDetails() { fetchedResponse, fetchedError in
                            if let fetchedResponse = fetchedResponse {
                                self.responseDict = fetchedResponse
                               
                                self.error = nil
                            } else if let fetchedError = fetchedError {
                                self.responseDict = ["Failed": "Failed"]
                                self.error = fetchedError
                            }
                        }
                    }
                
                ScrollView {
                    //Scroll view of the task information
                    
                    Text("Scroll")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    detailText("Title", value: responseDict["Title"] ?? "Error")
                    detailText("Description", value: responseDict["Description"] ?? "Error")
                    detailText("Assigned Priority", value: responseDict["AssignedPriority"] ?? "Error") 
                    detailText("Start Date", value: responseDict["StartDate"] ?? "Error")
                    detailText("End Date", value: responseDict["EndDate"] ?? "Error")
                    detailText("Reminder", value: responseDict["Reminder"] ?? "Error")
                    detailText("Subtask Number", value: responseDict["SubtaskNumber"] ?? "Error")
                    detailText("Assigned To", value: responseDict["AssignedTo"] ?? "Error")
                    detailText("Assigned From", value: responseDict["AssignedFrom"] ?? "Error")
                    detailText("Access Level", value: responseDict["AccessLevel"] ?? "Error")
                    detailText("Complete", value: responseDict["Complete"] ?? "Error")
                    /*
                    ForEach(responseDict.sorted(by: { $0.0 < $1.0 }), id: \.key) { key, value in
                        Text(key + " : " + value)
                            .fontWeight(.light)
                            .font(.largeTitle)
                            .foregroundColor(Color.white)
                            .background(Color.blue)
                            .frame(width: UIScreen.main.bounds.width*0.8)
                            .cornerRadius(10)
                            .padding()
                    }
                     */
                    Button{
                        self.isUpdateActive=true
                    } label: {
                        Text("Update Task")
                            .fontWeight(.medium)
                            .font(.largeTitle)
                            .foregroundColor(Color.white)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .padding()
                    }
                    
                    NavigationLink(destination: UpdateTaskView(detailedTaskView: self, SubtaskNumber: responseDict["SubtaskNumber"] ?? "Fail" , taskID: responseDict["TaskID"] ?? "Fail"), isActive: $isUpdateActive ) {
                        EmptyView()
                    }.hidden()
                    
                    // Can't make subtasks of subtasks
                    if responseDict["SubtaskNumber"]=="0"{
                        Button{
                            self.isCreateActive=true
                        } label: {
                            Text("Create Subtask")
                                .fontWeight(.medium)
                                .font(.largeTitle)
                                .foregroundColor(Color.white)
                                .background(Color.blue)
                                .cornerRadius(10)
                                .padding()
                        }
                    }
                    //Navigate to the create subtask view
                    NavigationLink(destination: SubtaskCreateView(detailedTask: self), isActive: $isCreateActive ) {
                        EmptyView()
                    }.hidden()
                    Button{
                        do{
                            //Send the delete task api request
                            runDeleteTask(taskID: responseDict["TaskID"]!, SubtaskNumber: responseDict["SubtaskNumber"]!){ fetchedResponse, fetchedError in
                                if let fetchedResponse = fetchedResponse {
                                    if fetchedResponse != "Success"{
                                        Alert(title: Text("Delete Failed!"))
                                    }
                                } else if let fetchedError = fetchedError {
                                    
                                }
                            }
                            taskView.reloadData()
                        }catch{
                            print("failed")
                        }
                    } label: {
                        Text("Delete Task")
                            .fontWeight(.medium)
                            .font(.largeTitle)
                            .foregroundColor(Color.white)
                            .background(Color.red)
                            .cornerRadius(10)
                            .padding()
                    }
                    
                    
                    
                }.background(Color.white)
                Spacer()
            }
            }
    }
    //Formatted information text function
    private func detailText(_ label: String, value: String) -> some View {
            Text("\(label) : \(value)")
                .fontWeight(.light)
                .font(.title)
                .foregroundColor(Color.black)
                .frame(width: UIScreen.main.bounds.width * 0.8)
                .cornerRadius(10)
                .padding()
        }
    //Reload - Refetch the task details 
    func reloadTaskDetails(){
        self.isUpdateActive = false
        returnTaskDetails() { fetchedResponse, fetchedError in
            if let fetchedResponse = fetchedResponse {
                self.responseDict = fetchedResponse
                self.specificDict = self.responseDict ?? ["Failed": "Failed"]
                self.error = nil
            } else if let fetchedError = fetchedError {
                self.responseDict = ["Failed": "Failed"]
                self.error = fetchedError
            }
        }

    }
}

#Preview {
    DetailedTaskView(taskView: TaskView.init(groupView: GroupView.init()))
}
