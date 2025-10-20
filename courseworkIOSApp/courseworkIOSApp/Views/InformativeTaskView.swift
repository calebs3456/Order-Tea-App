//
//  InformativeTaskView.swift
//  courseworkIOSApp
//
//  Created by Caleb Saunderson on 19/01/2024.
//

import SwiftUI

struct InformativeTaskView: View {
    
    public var taskView: TotalTaskView
    @State private var responseDict: [String:String] = ["":""]
    @State private var specificDict: [String:String] = ["":""]
    @State private var error: Error?
    @State private var titleList: [String] = []
    
    //Same as detailed task view except no edit, or create subtask
    
    var body: some View {
        
        ZStack{
            Color.gray.edgesIgnoringSafeArea(.all)
                VStack {
                    Text("Task Details")
                        .font(.largeTitle)
                        .onAppear {
                            
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
                    //Scrollable
                    ScrollView {
                        Text("Scroll")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        //Order of task information
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
                        
                        
                        
                        Button{
                            do{
                                
                                runDeleteTask(taskID: responseDict["TaskID"]!, SubtaskNumber: responseDict["SubtaskNumber"]!){ fetchedResponse, fetchedError in
                                    if let fetchedResponse = fetchedResponse {
                                        if fetchedResponse != "Success"{
                                            Alert(title: Text("Delete Failed!"))
                                        }
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
                                .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color.blue/*@END_MENU_TOKEN@*/)
                                .cornerRadius(10)
                                .padding()
                        }
                        
                        
                    }.background(Color.white)
                }
            }
    }
    //Formatting of information
    private func detailText(_ label: String, value: String) -> some View {
            Text("\(label) : \(value)")
                .fontWeight(.light)
                .font(.title)
                .foregroundColor(Color.black)
                .frame(width: UIScreen.main.bounds.width * 0.8)
                .cornerRadius(10)
                .padding()
        }
    //Refresh task details
    func reloadTaskDetails(){
        
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
    InformativeTaskView(taskView: TotalTaskView.init(groupView: GroupView.init()))
}
