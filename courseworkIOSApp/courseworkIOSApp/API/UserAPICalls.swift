//
//  APICalls.swift
//  courseworkIOSApp
//
//  Created by Caleb Saunderson on 06/12/2023.
//

/*
 In the provided code, API requests that require a response involve sending a request to a server and processing the received data or errors through completion handlers. These requests typically await a JSON or string response to decode and pass on to the calling function. Conversely, an API request that might not expect a detailed response, still involves error handling and potentially confirms the action's success with a simple string message, indicating a less complex data processing requirement. Both types of requests use URLSession for asynchronous network calls, handling responses within closures to maintain app responsiveness.
 */


//Switches are needed to allow the response data to be accessed and used



import Foundation
import UIKit


//API Request
public func createUser(username: String, password: String) -> Void {
    
    let url = URL(string: "http://127.0.0.1:8080/userAPI/IOScreateUser")!
    //let formData = "id=\(id)&title=\(title)&priority=\(priority)"
    
    var request = URLRequest(url: url)
    
    
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    //Set form data, request type, etc then send
    var requestBodyComponents = URLComponents()
    requestBodyComponents.queryItems = [URLQueryItem(name: "username", value: username),URLQueryItem(name: "password", value: password)]
    request.httpMethod = "POST"
    request.httpBody = requestBodyComponents.query?.data(using: .utf8)
    
    struct createPacket: Decodable {
        let username: String
        let password: String
    }
    
    URLSession.shared.dataTask(with: request){ (data, response, error) in
        
        
        
    }.resume()
}

//completion: @escaping (Result<[String:String], Error> allows result to be used in a switch case and data can be pulled out
func runLoginUser(username: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
    
    let url = URL(string: "http://127.0.0.1:8080/userAPI/IOSlogin")!
    //let formData = "id=\(id)&title=\(title)&priority=\(priority)"
    
    var request = URLRequest(url: url)
    
    
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    //Set form data, request type, etc and send
    var requestBodyComponents = URLComponents()
    requestBodyComponents.queryItems = [URLQueryItem(name: "username", value: username),URLQueryItem(name: "password", value: password)]
    request.httpMethod = "POST"
    request.httpBody = requestBodyComponents.query?.data(using: .utf8)
    
    struct loginPacket: Decodable {
        let username: String
        let password: String
    }
    
    URLSession.shared.dataTask(with: request){ (data, response, error) in
        //check for errors
        if let error = error {
            completion(.failure(error))
            return
        }

        if let data = data {
            do {
                //Decode response to a string
                if let responseString = String(data: data, encoding: .utf8) {
                    completion(.success(responseString))
                    
                } else {
                    completion(.failure(NSError(domain: "ResponseParsingError", code: -1, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }
           
        }.resume()
        
        
        
    
    }
    
public func login(username: String, password: String, completion: @escaping (String?, Error?) -> Void) {
    
    //Handle response so it can be used
    runLoginUser(username: username, password:password) { result in
        switch result {
        case .success(let success):
            print("Response: \(success)")
            
            completion(success, nil)
        
        case .failure(let error):
            print("Response: \(error)")
            completion(nil,error)
            
        }
    }
}

