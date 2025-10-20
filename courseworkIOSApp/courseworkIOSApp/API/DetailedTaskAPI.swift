//
//  DetailedTaskAPI.swift
//  courseworkIOSApp
//
//  Created by Caleb Saunderson on 09/12/2023.
//
/*
 In the provided code, API requests that require a response involve sending a request to a server and processing the received data or errors through completion handlers. These requests typically await a JSON or string response to decode and pass on to the calling function. Conversely, an API request that might not expect a detailed response, still involves error handling and potentially confirms the action's success with a simple string message, indicating a less complex data processing requirement. Both types of requests use URLSession for asynchronous network calls, handling responses within closures to maintain app responsiveness.
 */

//Switches are needed to allow the response data to be accessed and used

import Foundation

func runReturnTaskDetails(completion: @escaping (Result<[String: String], Error>) -> Void) {
    let url = URL(string: "http://127.0.0.1:8080/IOSSpecificTask/returnTaskDetails")!
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
    
public func returnTaskDetails( completion: @escaping ([String:String]?, Error?) -> Void) {
    runReturnTaskDetails() { result in
        switch result {
        case .success(let success):
                //print("Response: \(success)")
            
            completion(success, nil)
            
        case .failure(let error):
            //print("Response: \(error)")
            completion(nil,error)
            
        }
    }
}


func deleteTask(TaskID: String, SubtaskNumber: String, completion: @escaping (Result<String, Error>) -> Void ) {
    print("deleting")
    let url = URL(string: "http://127.0.0.1:8080/IOSSpecificTask/delete")!
    //let formData = "id=\(id)&title=\(title)&priority=\(priority)"
    
    var request = URLRequest(url: url)
    
    
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    var requestBodyComponents = URLComponents()
    requestBodyComponents.queryItems = [URLQueryItem(name: "TaskID", value: TaskID),URLQueryItem(name: "subtaskNumber", value: SubtaskNumber)]
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

public func runDeleteTask(taskID: String, SubtaskNumber: String, completion: @escaping (String?, Error?) -> Void ) {
    deleteTask(TaskID: taskID, SubtaskNumber: SubtaskNumber){ result in
        switch result {
        case .success(let success):
            //print("Response: \(success)")
            
            completion(success, nil)
            
        case .failure(let error):
            
           // print("Response: \(error)")
            completion(nil,error)
            
        }
    
    
    }
}
func runUpdateTask(TaskID: String, Title: String, Description: String, AssignedTo: String, AssignedPriority: Int, AccessLevel: Int, StartDate: String, EndDate: String,Reminder: String, SubtaskNumber: String, Complete: Bool, completion: @escaping (Result<String, Error>) -> Void ){
    
    let url = URL(string: "http://127.0.0.1:8080/IOSSpecificTask/update")!
    //let formData = "id=\(id)&title=\(title)&priority=\(priority)"
    
    var request = URLRequest(url: url)
    
    
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    var requestBodyComponents = URLComponents()
    requestBodyComponents.queryItems = [URLQueryItem(name: "TaskID", value: TaskID),URLQueryItem(name: "Title", value: Title),URLQueryItem(name: "Description", value: Description),URLQueryItem(name: "AssignedTo", value: AssignedTo),URLQueryItem(name: "AssignedPriority", value: String(AssignedPriority)),URLQueryItem(name: "AccessLevel", value: String(AccessLevel)),URLQueryItem(name: "SubtaskNumber", value: String(SubtaskNumber)),URLQueryItem(name: "StartDate", value: StartDate),URLQueryItem(name: "EndDate", value: EndDate),URLQueryItem(name: "Reminder", value: Reminder),URLQueryItem(name: "Complete", value: String(Complete))]
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
public func updateTask(TaskID: String, Title: String, Description: String, AssignedTo: String, AssignedPriority: Int, AccessLevel: Int, StartDate: String, EndDate: String,Reminder: String, SubtaskNumber: String, Complete: Bool, completion: @escaping (String?, Error?) -> Void ) {
    print(TaskID)
    runUpdateTask(TaskID: TaskID, Title: Title, Description: Description, AssignedTo: AssignedTo, AssignedPriority: AssignedPriority, AccessLevel: AccessLevel, StartDate: StartDate, EndDate: EndDate, Reminder: Reminder, SubtaskNumber: SubtaskNumber, Complete: Complete) { result in
        switch result {
        case .success(let success):
            //print("Response: \(success)")
            
            completion(success, nil)
            
        case .failure(let error):
            
            //print("Response: \(error)")
            completion(nil,error)
            
        }
    
    
    }
    
}

func runReturnUsersOfGroup(completion: @escaping (Result<[String: String], Error>) -> Void) {
    let url = URL(string: "http://127.0.0.1:8080/IOSSpecificTask/returnUsers")!
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
    
public func returnUsersOfGroup( completion: @escaping ([String:String]?, Error?) -> Void) {
    runReturnUsersOfGroup() { result in
        switch result {
        case .success(let success):
                //print("Response: \(success)")
            
            completion(success, nil)
            
        case .failure(let error):
            //print("Response: \(error)")
            completion(nil,error)
            
        }
    }
}

func runCreateSubtask(Title: String, Description: String, AssignedTo: String, AssignedPriority: Int, AccessLevel: Int, StartDate: String, EndDate: String, Reminder:String, completion: @escaping (Result<String, Error>) -> Void ){
    
    let url = URL(string: "http://127.0.0.1:8080/IOSSpecificTask/create")!
    //let formData = "id=\(id)&title=\(title)&priority=\(priority)"
    
    var request = URLRequest(url: url)
    
    
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    var requestBodyComponents = URLComponents()
    requestBodyComponents.queryItems = [URLQueryItem(name: "Title", value: Title),URLQueryItem(name: "Description", value: Description),URLQueryItem(name: "AssignedTo", value: AssignedTo),URLQueryItem(name: "AssignedPriority", value: String(AssignedPriority)),URLQueryItem(name: "AccessLevel", value: String(AccessLevel)),URLQueryItem(name: "StartDate", value: StartDate),URLQueryItem(name: "EndDate", value: EndDate),URLQueryItem(name: "Reminder", value: Reminder)]
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
public func createSubtask(Title: String, Description: String, AssignedTo: String, AssignedPriority: Int, AccessLevel: Int, StartDate: String, EndDate: String,Reminder: String, completion: @escaping (String?, Error?) -> Void ) {
    runCreateSubtask(Title: Title, Description: Description, AssignedTo: AssignedTo, AssignedPriority: AssignedPriority, AccessLevel: AccessLevel, StartDate: StartDate, EndDate: EndDate, Reminder: Reminder) { result in
        switch result {
        case .success(let success):
            //print("Response: \(success)")
            
            completion(success, nil)
            
        case .failure(let error):
            
            //print("Response: \(error)")
            completion(nil,error)
            
        }
    
    
    }
    
}

