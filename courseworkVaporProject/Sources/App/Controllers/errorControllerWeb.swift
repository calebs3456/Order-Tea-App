//
//  File.swift
//  
//
//  Created by Caleb Saunderson on 22/01/2024.
//

import Foundation
import Vapor
struct errorControllerWeb: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let route = routes.grouped("error")
        route.get(use: webErrorView)
    }
    //Template for error data
    struct errorContext: Encodable {
        var message: String
        var urlReturn: String
        var pageName: String
        
    }
    //Uses template errorContext to send data to error.leaf
    //Accesses the session data which holds the error message and the page to return to then formats it into the errorContext template
    func webErrorView(req: Request) async throws -> View {
        
        if let errorString = req.session.data["errorMessage"] as? String{
            let errorArray = errorString.components(separatedBy: "-")
            let context = errorContext(message: errorArray[0], urlReturn: errorArray[1], pageName: errorArray[2])
            return try await req.view.render("Build/error", context)
        }
        let context = errorContext(message: "Failed", urlReturn: "Failed", pageName: "Failed")
        return try await req.view.render("Build/Error", context)
    }
    
    
    
}
    
