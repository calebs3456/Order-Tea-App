//
//  CreateGroupView.swift
//  courseworkIOSApp
//
//  Created by Caleb Saunderson on 07/01/2024.
//

import SwiftUI
import Combine //Library used to limit length of characters Just() function
struct CreateGroupView: View {
    //Group view used to reload data when creation is complete. Also used in all other create views
    @State public var groupView: GroupView
    @State public var groupName: String = ""
    @State private var characterLimit: Int = 255
    var body: some View {
        VStack{
            Text("Create Group")
                .font(/*@START_MENU_TOKEN@*/.largeTitle/*@END_MENU_TOKEN@*/)
                .fontWeight(.light)
                .multilineTextAlignment(.center).onAppear(){
                }
            Form{
                
                TextField("Name", text: $groupName).onReceive(Just(groupName)) { _ in
                    limitLength()}.font(.title)
                
                Button {
                    do{
                        //Create Group
                        createGroup(groupName: groupName){ fetchedResponse, fetchedError in
                            if let fetchedResponse = fetchedResponse {
                                if fetchedResponse=="Exists"{
                                    Alert(title: Text("Choose a unique name"))
                                }
                                if fetchedResponse=="Success"{
                                    self.groupView.reloadData()
                                    print("Success")
                                }
                                if fetchedResponse=="Fail"{
                                    Alert(title: Text("Failed to create group!"))
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
    func limitLength(){
        if groupName.count>characterLimit{
            groupName = String(groupName.prefix(characterLimit))
        }
        
        
    }
}
#Preview {
    CreateGroupView(groupView: GroupView.init())
}

    
