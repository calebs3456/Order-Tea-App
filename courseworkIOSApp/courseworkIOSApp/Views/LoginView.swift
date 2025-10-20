//
//  LoginView.swift
//  courseworkIOSApp
//
//  Created by Caleb Saunderson on 06/12/2023.
//

import SwiftUI
import SwiftData


struct LoginView: View {
    
    @State private var username: String = ""
    @State private var password: String = ""

    @State private var activeLogin: Bool = false
    @State public var createUser: Bool = false
    var body: some View {
                            
        //Navigation view allows navigation to different pages
        NavigationView(content: {
          
                VStack{
                    Text("Order Tea")
                        .font(.system(size:64))
                        .fontWeight(.light)
                        .foregroundColor(Color.black)
                    
                        .multilineTextAlignment(.center).onAppear(){
                            //When the text appears set the following variables that are used for navigation to false
                            self.activeLogin=false
                            self.createUser = false
                        }
                        
                    Spacer()
            
                    
                    //Forms are used throughout the IOS app, and they automatically set any user input to a variable
                    
                
                    Section {
                        TextField("Username", text: $username)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(5.0)
                            .padding(.all)
                    }
                    
                    Section { 
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(5.0)
                            .padding(.all)
                        
                    }.background(Color.clear)
                    
                    Spacer()
                        
                        
                        Button{
                            
                            login(username: username, password: password) { fetchedResponse, fetchedError in
                                if let fetchedResponse = fetchedResponse {
                                    if fetchedResponse == "Success"{
                                        self.activeLogin = true
                                        print(self.activeLogin)
                                    }
                                    else{
                                        Alert(title: Text("Failed to login!"))
                                        print("failed")
                                        self.activeLogin = false
                                    }
                                    
                                }
                                
                            }
                        } label: {
                            Text("Login")
                                .fontWeight(.light)
                                .font(.largeTitle)
                                .foregroundColor(Color.white)
                        }
                    //Set the width and height of the frame
                        .frame(width: UIScreen.main.bounds.width*0.8, height:UIScreen.main.bounds.height*0.1)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding()
                    
                    
                    
                        Button{
                            self.createUser = true
                        }label: {
                            Text("Create User")
                                .fontWeight(.light)
                                .font(.largeTitle)
                                .foregroundColor(Color.white)
                                
                                
                        }
                        .frame(width: UIScreen.main.bounds.width*0.8, height:UIScreen.main.bounds.height*0.1)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding()
                    
                    
                    NavigationLink(destination: CreateUserView(loginView: self), isActive: $createUser ) {
                        EmptyView()
                    }.hidden()
                    
                  
                    //Change/navigate to the group view page
                    NavigationLink(destination: GroupView(), isActive: $activeLogin ) {
                        EmptyView()
                    }.padding().frame(width: nil).hidden()
                }
                .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color.gray/*@END_MENU_TOKEN@*/)
                
            
        })
        .background(Color.gray)
    
        
           
        
            
            
        
       
        
    }
}

#Preview {
    LoginView()
}
