//
//  TaskAPICalls.swift
//  courseworkIOSApp
//
//  Created by Caleb Saunderson on 08/12/2023.
//
/*
 In the provided code, API requests that require a response involve sending a request to a server and processing the received data or errors through completion handlers. These requests typically await a JSON or string response to decode and pass on to the calling function. Conversely, an API request that might not expect a detailed response, still involves error handling and potentially confirms the action's success with a simple string message, indicating a less complex data processing requirement. Both types of requests use URLSession for asynchronous network calls, handling responses within closures to maintain app responsiveness.
 */

//Switches are needed to allow the response data to be accessed and used
import Foundation

func runReturnTasks(completion: @escaping (Result<[String: String], Error>) -> Void) {
    let url = URL(string: "http://127.0.0.1:8080/taskAPI/returnTasks")!
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
    
public func returnTasks( completion: @escaping ([String:String]?, Error?) -> Void) {
    runReturnTasks() { result in
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

func runSelectTask(taskID: String, completion: @escaping (Result<String, Error>) -> Void ){
    
    let url = URL(string: "http://127.0.0.1:8080/taskAPI/selectTask")!
    //let formData = "id=\(id)&title=\(title)&priority=\(priority)"
    
    var request = URLRequest(url: url)
    
    
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    var requestBodyComponents = URLComponents()
    requestBodyComponents.queryItems = [URLQueryItem(name: "TaskID", value: taskID)]
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


public func selectTask(taskID:String, completion: @escaping (String?, Error?) -> Void) {
    runSelectTask(taskID: taskID) { result in
        switch result {
        case .success(let success):
            //print("Response: \(success)")
            
            completion(success, nil)
            
        case .failure(let error):
            //print("select Task")
            //print("Response: \(error)")
            completion(nil,error)
            
        }
    }
    
}


func runCreateTask(Title: String, Description: String, AssignedTo: String, AssignedPriority: Int, AccessLevel: Int, StartDate: String, EndDate: String, Reminder: String, SubtaskNumber: Int, completion: @escaping (Result<String, Error>) -> Void ){
    
    let url = URL(string: "http://127.0.0.1:8080/taskAPI/create")!
    //let formData = "id=\(id)&title=\(title)&priority=\(priority)"
    
    var request = URLRequest(url: url)
    
    
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    var requestBodyComponents = URLComponents()
    requestBodyComponents.queryItems = [URLQueryItem(name: "Title", value: Title),URLQueryItem(name: "Description", value: Description),URLQueryItem(name: "AssignedTo", value: AssignedTo),URLQueryItem(name: "AssignedPriority", value: String(AssignedPriority)),URLQueryItem(name: "AccessLevel", value: String(AccessLevel)),URLQueryItem(name: "SubtaskNumber", value: String(SubtaskNumber)),URLQueryItem(name: "StartDate", value: StartDate),URLQueryItem(name: "EndDate", value: EndDate),URLQueryItem(name: "Reminder", value: Reminder)]
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
public func createTask(Title: String, Description: String, AssignedTo: String, AssignedPriority: Int, AccessLevel: Int, StartDate: String, EndDate: String, Reminder: String,SubtaskNumber: Int, completion: @escaping (String?, Error?) -> Void ) {
    runCreateTask(Title: Title, Description: Description, AssignedTo: AssignedTo, AssignedPriority: AssignedPriority, AccessLevel: AccessLevel, StartDate: StartDate, EndDate: EndDate,Reminder: Reminder, SubtaskNumber: SubtaskNumber) { result in
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
func runReturnAllNonGroupUsers(completion: @escaping (Result<[String: String], Error>) -> Void) {
    let url = URL(string: "http://127.0.0.1:8080/taskAPI/returnAllNonGroupUsers")!
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
    
public func returnAllNonGroupUsers( completion: @escaping ([String:String]?, Error?) -> Void) {
    runReturnAllNonGroupUsers() { result in
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

func runAddUserToGroup(userID: String, AccessLevel: Int, completion: @escaping (Result<String, Error>) -> Void ){
    
    let url = URL(string: "http://127.0.0.1:8080/taskAPI/addUser")!
    //let formData = "id=\(id)&title=\(title)&priority=\(priority)"
    
    var request = URLRequest(url: url)
    
    
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    var requestBodyComponents = URLComponents()
    requestBodyComponents.queryItems = [URLQueryItem(name: "userID", value: userID),URLQueryItem(name: "accessLevel", value: String(AccessLevel))]
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


public func addUserToGroup(userID:String, AccessLevel: Int, completion: @escaping (String?, Error?) -> Void) {
    runAddUserToGroup(userID: userID, AccessLevel: AccessLevel) { result in
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

func runChangeFactors(factors: [String], completion: @escaping (Result<String, Error>) -> Void ){
    
    let url = URL(string: "http://127.0.0.1:8080/taskAPI/changeFactors")!
    //let formData = "id=\(id)&title=\(title)&priority=\(priority)"
    
    var request = URLRequest(url: url)
    
    var factorString: String = ""
    var x: Int = 0
    for factor in factors {
        if x==4{
            factorString+=factor
        }
        else{
            factorString+=factor+"-"
        }
        x+=1
    }
    
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    var requestBodyComponents = URLComponents()
    requestBodyComponents.queryItems = [URLQueryItem(name: "factors", value: factorString)]
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


public func changeFactors(factors: [String], completion: @escaping (String?, Error?) -> Void) {
    runChangeFactors(factors: factors) { result in
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

func runReturnTaskIDs(completion: @escaping (Result<[String], Error>) -> Void) {
    let url = URL(string: "http://127.0.0.1:8080/taskAPI/returnTaskIDs")!
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
                if let responseDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String] {
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
    
public func returnTaskIDs( completion: @escaping ([String]?, Error?) -> Void) {
    runReturnTaskIDs() { result in
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






func runReturnAllTasks(completion: @escaping (Result<[String: String], Error>) -> Void) {
    let url = URL(string: "http://127.0.0.1:8080/taskAPI/returnAllTasks")!
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
    
public func returnAllTasks( completion: @escaping ([String:String]?, Error?) -> Void) {
    runReturnAllTasks() { result in
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


func runReturnAllTaskIDs(completion: @escaping (Result<[String], Error>) -> Void) {
    let url = URL(string: "http://127.0.0.1:8080/taskAPI/returnAllTaskIDs")!
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
                if let responseDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String] {
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
    
public func returnAllTaskIDs( completion: @escaping ([String]?, Error?) -> Void) {
    runReturnAllTaskIDs() { result in
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


func runReturnSubTasks(completion: @escaping (Result<[String: String], Error>) -> Void) {
    let url = URL(string: "http://127.0.0.1:8080/taskAPI/returnSubtasks")!
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
    
public func returnSubTasks( completion: @escaping ([String:String]?, Error?) -> Void) {
    runReturnSubTasks() { result in
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
