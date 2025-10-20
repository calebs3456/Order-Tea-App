//
//  GroupView.swift
//  courseworkIOSApp
//
//  Created by Caleb Saunderson on 07/12/2023.
//

import SwiftUI

struct GroupView: View {
    
    @State public var userID: String = ""
    @State private var responseDict: [String:String] = ["":""]
    @State private var specificDict: [String:String] = ["":""]
    @State private var error: Error?
    @State private var titleList: [String] = []
    @State private var activeGroup: Bool = false
    @State private var creatingGroup: Bool = false
    @State private var totalTask: Bool = false
    
    //VStacks stack the UI elements vertically
    //The ZStack in this case is used to change the colour of the background of the whole app
    var body: some View {
        ZStack{
            Color.gray.edgesIgnoringSafeArea(.all)
            
            VStack {
                
                Text("Groups")
                    .font(.largeTitle)
                    .onAppear {
                        
                        //On the text appearing fetch the avaliable groups
                        self.activeGroup=false
                        self.creatingGroup=false
                        self.totalTask=false
                        returnGroups { fetchedResponse, fetchedError in
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
                
                Button{
                    self.totalTask = true
                }label: {
                    Text("View all Tasks")
                        .fontWeight(.light)
                        .font(.largeTitle)
                        .foregroundColor(Color.white)
                        .background(Color.blue).frame(width: UIScreen.main.bounds.width*0.8)
                        .cornerRadius(10)
                    
                        .padding()
                }
                NavigationLink(destination: TotalTaskView(groupView: self), isActive: $totalTask ) {
                    EmptyView()
                }.hidden()
                //Scroll view fits UI elements that would otherwise not fit onto a single page by using scrolling
                ScrollView {
                    Text("Scroll")
                        .font(.subheadline)
                        .fontWeight(.semibold).frame(width: UIScreen.main.bounds.width*0.8)
                        
                    ForEach(responseDict.sorted(by: { $0.0 < $1.0 }), id: \.key) { key, value in
                        //Display the groups as buttons so they can be selected
                        Button{
                            selectGroup(groupID: value) { fetchedResponse, fetchedError in
                                if let fetchedResponse = fetchedResponse {
                                    if fetchedResponse == "Success"{
                                        self.activeGroup = true
                                        
                                    }
                                    else{
                                        Alert(title: Text("Selection failed"))
                                        self.activeGroup = false
                                    }
                                    
                                }
                                
                                
                            }
                        }label: {
                            Text(key)
                                .fontWeight(.light)
                                .font(.largeTitle)
                                .foregroundColor(Color.white)
                                .background(Color.blue).frame(width: UIScreen.main.bounds.width*0.8)
                                .cornerRadius(10)
                                .padding()
                        }
                        
                    }
                    
                }.background(Color.white)
                
                //Navigate to the task view according to the selected group
                NavigationLink(destination: TaskView(groupView: self), isActive: $activeGroup ) {
                    EmptyView()
                }.hidden()
                
                Button{
                    self.creatingGroup = true
                }label: {
                    Text("Create Group")
                        .fontWeight(.light)
                        .font(.largeTitle)
                        .foregroundColor(Color.white)
                        .background(Color.blue).frame(width: UIScreen.main.bounds.width*0.8)
                        .cornerRadius(10)
                        .padding()
                }
                NavigationLink(destination: CreateGroupView(groupView: self), isActive: $creatingGroup ) {
                    EmptyView()
                }.hidden()
                
            }.background(Color.gray.edgesIgnoringSafeArea(.all))
        }
        }
    //Reload the avaliable groups
    func reloadData(){
        self.activeGroup=false
        self.creatingGroup=false
        self.totalTask=false
        returnGroups { fetchedResponse, fetchedError in
            if let fetchedResponse = fetchedResponse {
                self.responseDict = fetchedResponse
              
                self.error = nil
            } else if let fetchedError = fetchedError {
                self.responseDict = ["Failed": "Failed"]
                self.error = fetchedError
            }
        }
    }
    }


#Preview {
    GroupView()
}
