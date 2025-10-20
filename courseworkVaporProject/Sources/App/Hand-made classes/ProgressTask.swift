//
//  File.swift
//  
//
//  Created by Caleb Saunderson on 11/01/2024.
//

import Foundation
import Vapor

class progressTask {
    // The argument tasks are all the tasks with the same taskID
    // The progress of a task will be calculated by the number of subtasks complete
    //The returned value will be a float between 0 and 1 (percentage)
    public func checkProgress(req: Request, tasks: [Task]) async throws -> Float{
        var progress: Float = 0.0
        
        var totalSubtasks: Int = tasks.count
        
        var completeSubtasks: Int = 0
        for task in tasks{
            if task.Complete==true{
                completeSubtasks += 1
            }
        }
        if totalSubtasks == 0{
            totalSubtasks = 1
        }
        progress = Float(completeSubtasks / totalSubtasks)
        return progress
    }
}
