//
//  GroupAPICalls.swift
//  courseworkIOSApp
//
//  Created by Caleb Saunderson on 07/12/2023.
//


/*
 In the provided code, API requests that require a response involve sending a request to a server and processing the received data or errors through completion handlers. These requests typically await a JSON or string response to decode and pass on to the calling function. Conversely, an API request that might not expect a detailed response, still involves error handling and potentially confirms the action's success with a simple string message, indicating a less complex data processing requirement. Both types of requests use URLSession for asynchronous network calls, handling responses within closures to maintain app responsiveness.
 */

//Switches are needed to allow the response data to be accessed and used
import Foundation


func runReturnGroups(completion: @escaping (Result<[String: String], Error>) -> Void) {
    let url = URL(string: "http://127.0.0.1:8080/groupAPI/returnGroups")!
    var request = URLRequest(url: url)
    
    // Set the content type to form data (you can adjust this based on your server's expectations)
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    // Set an empty httpBody
    request.httpBody = Data()
    
    request.httpMethod = "POST"
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        // Check for errors
        if let error = error {
            completion(.failure(error))
            return
        }

        if let data = data {
            do {
                // Decode response to a dictionary
                if let responseDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                    completion(.success(responseDict))
                } else {
                    completion(.failure(NSError(domain: "ResponseParsingError", code: -1, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }.resume()
}
    
public func returnGroups( completion: @escaping ([String:String]?, Error?) -> Void) {
    runReturnGroups() { result in
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

func runSelectGroup(groupID: String, completion: @escaping (Result<String, Error>) -> Void ){
    
    let url = URL(string: "http://127.0.0.1:8080/groupAPI/selectGroup")!
    //let formData = "id=\(id)&title=\(title)&priority=\(priority)"
    
    var request = URLRequest(url: url)
    
    
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    var requestBodyComponents = URLComponents()
    requestBodyComponents.queryItems = [URLQueryItem(name: "groupID", value: groupID)]
    request.httpMethod = "POST"
    request.httpBody = requestBodyComponents.query?.data(using: .utf8)

    
    URLSession.shared.dataTask(with: request){ (data, response, error) in
        if let error = error {
            completion(.failure(error))
            return
        }

        if let data = data {
            do {
                // Decode response to a dictionary
                if let responseString = String(data: data, encoding: .utf8)  {
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


public func selectGroup(groupID:String, completion: @escaping (String?, Error?) -> Void) {
    runSelectGroup(groupID: groupID) { result in
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

func runCreateGroup(groupName: String, completion: @escaping (Result<String, Error>) -> Void ){
    
    let url = URL(string: "http://127.0.0.1:8080/groupAPI/create")!
    //let formData = "id=\(id)&title=\(title)&priority=\(priority)"
    
    var request = URLRequest(url: url)
    
    
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    var requestBodyComponents = URLComponents()
    requestBodyComponents.queryItems = [URLQueryItem(name: "groupName", value: groupName)]
    request.httpMethod = "POST"
    request.httpBody = requestBodyComponents.query?.data(using: .utf8)

    
    URLSession.shared.dataTask(with: request){ (data, response, error) in
        if let error = error {
            completion(.failure(error))
            return
        }

        if let data = data {
            do {
                // Decode response to a dictionary
                if let responseString = String(data: data, encoding: .utf8)  {
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


public func createGroup(groupName:String, completion: @escaping (String?, Error?) -> Void) {
    runCreateGroup(groupName: groupName) { result in
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

func runDeleteGroup(completion: @escaping (Result<String, Error>) -> Void) {
    
    let url = URL(string: "http://127.0.0.1:8080/groupAPI/delete")!
    //let formData = "id=\(id)&title=\(title)&priority=\(priority)"
    
    var request = URLRequest(url: url)
    
    
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

    
    request.httpMethod = "POST"
    
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

public func deleteGroup(completion: @escaping (String?, Error?) -> Void) {
    runDeleteGroup() { result in
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
