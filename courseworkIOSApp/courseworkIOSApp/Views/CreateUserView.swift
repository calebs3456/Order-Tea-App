//
//  CreateUserView.swift
//  courseworkIOSApp
//
//  Created by Caleb Saunderson on 07/01/2024.
//

import SwiftUI
import Combine //Library used to limit length of characters Just() function
struct CreateUserView: View {
   
    public var loginView: LoginView
    @State public var username: String = ""
    @State public var password: String = ""
    @State private var characterLimit: Int = 255
    
    var body: some View {
        VStack{
            Text("Create User")
                .font(/*@START_MENU_TOKEN@*/.largeTitle/*@END_MENU_TOKEN@*/)
                .fontWeight(.light)
                .multilineTextAlignment(.center).onAppear(){
                }
            Form{
                
                TextField("Username", text: $username).onReceive(Just(username)) { _ in
                    limitLength()}.font(.title)
                TextField("Password", text: $password).onReceive(Just(password)) { _ in
                    limitLength()}.font(.title)
                
                Button {
                    do{
                        //Create user
                        createUser(username: username, password: password)
                        
                        //Alert if failed
                        loginView.createUser=false
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
        if username.count>characterLimit{
            username = String(username.prefix(characterLimit))
        }
        if password.count>characterLimit{
            password = String(password.prefix(characterLimit))
        }
        
        
    }
}
#Preview {
    CreateUserView(loginView: LoginView.init())
}

    
