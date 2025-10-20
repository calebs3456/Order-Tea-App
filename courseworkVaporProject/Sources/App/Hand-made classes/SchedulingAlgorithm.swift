//
//  schedulingAlgorithm.swift
//
//
//  Created by Caleb Saunderson on 24/08/2023.
//

import Foundation
import Vapor
import FluentMySQLDriver
import Fluent
class schedulingAlgorithm{
    
    //First scheduling algorithm that will take the factors of each task and calculate a priority for them
    func schedulingAlgorithmA(req: Request, tasks: [Task], factors: [String]) async throws -> [Task]{
        var calculatedPriorities = [String: Float]() //TaskID : CalculatedPriority
        var longestTimeTill = 0.0
        var longestTimeSince = 0.0
        var listOfFactors: [String] = ["EndDate", "AssignedPriority","Progress", "StartDate", "AccessLevel"]
        var weights: [String: Float] = ["EndDate":1.0, "AssignedPriority":0.0,"Progress":0.0, "StartDate": 0.0, "AccessLevel":0.0] //The starting weights for all the factors
        
        if (factors != nil){
            weights = [:]
            let totalFactors = 5
            var x: Int = 1
            for factor in factors{
                if listOfFactors.contains(factor){
                    weights[factor] = 0.5*(pow(0.47463,Float(x-1))) //Using formula a*r^n-1 where a=0.5 r is dependent on total number of factors
                    x+=1
                }
            }
        }
        for factor in listOfFactors{
            if !factors.contains(factor){
                weights[factor] = 0.0
            }
        }
        //print(weights)
        
        for task in tasks{
            //print("task title: schedule ", task.title)
            guard let deadline = task.$EndDate.value else { return tasks }
            guard let startDate = task.$StartDate.value else { return tasks }
            let currentTime = Date()
            let timeTillEndDate = hoursBetween(dateA: currentTime, dateB: deadline)
            let timeSinceStartDate = hoursBetween(dateA: startDate, dateB: currentTime)
            /*
            print("Start Date: ", startDate, " Deadline ", deadline, " currentTime ", currentTime)
            print("Time Since start date ",timeSinceStartDate, " longestTimeSince ", longestTimeSince)
            print("Time Till End date ",timeTillEndDate, " longestTimeTill ", longestTimeTill)
             */
            if longestTimeTill<=timeTillEndDate{
                longestTimeTill = timeTillEndDate
            }
            if longestTimeSince<=timeSinceStartDate{
                longestTimeSince = timeSinceStartDate
            }
            
        }


        //Find all the factors and normalise them onto a scale of 0 to 1, with 1 being a high priority
        
        //If a check is failed then calculated priority should be -1 because even with certain factors it should be bottom
        for task in tasks{
            
            if task.Complete==true{
                let id = (task.id ?? "error") + String(task.SubtaskNumber)
                let calculatedPriority = -1
                try calculatedPriorities[id] = Float(calculatedPriority)
                
                //Complete makes task lowest priority
                continue
                
            }
            print(hasDatePassed(date: task.StartDate), hasDatePassed(date: task.EndDate))
            
            
            if hasDatePassed(date: task.StartDate)==false{
                let calculatedPriority = -1
                let id = (task.id ?? "error") + String(task.SubtaskNumber)
    
                try calculatedPriorities[id] = Float(calculatedPriority)
                continue
            }
            if hasDatePassed(date: task.EndDate)==true{
                let calculatedPriority = -1
                let id = (task.id ?? "error") + String(task.SubtaskNumber)

                try calculatedPriorities[id] = Float(calculatedPriority)
                
                continue
            }
            
            //To find the progress of a task find all the tasks with the same taskID, which includes subtasks
            // Call progress complete with the argument of all the tasks found
            // Returns a decimal between 0 and 1 representing the percentage complete
            // To normalise it do 1 - the returned decimal because the higher the percentage complete the lower the priority and therefore should be closer to 0
            // Ensure you import the relevant SQL database package
            
            var normalisedDecimalComplete: Float = 0.0
            if task.SubtaskNumber==0{
                let prefix = task.id?.prefix(72) ?? "error"
                let tasksOfSameTaskID = try await Task.query(on: req.db)
                    .group(.or) { or in
                        or.filter(\.$id, .custom("LIKE"), "\(prefix)%")
                    }
                    .all()
                

                
                let progressOfTask = progressTask()
                let decimalComplete = try await progressOfTask.checkProgress(req: req, tasks: tasksOfSameTaskID)

                normalisedDecimalComplete = (1-decimalComplete) * Float(weights["Progress"] ?? 0.0)
            }
            normalisedDecimalComplete = 0
            let assignedFrom = task.$AssignedFrom.value
            
    
            let assignedFromAccessLevel = try await Group.find(assignedFrom, on: req.db)?.accessLevel ?? 1
            
         
            let normalisedFromAccess = Float(assignedFromAccessLevel / 5)  * Float(weights["AccessLevel"] ?? 0.0)
 
            
            let assignedPriority = task.$AssignedPriority.value!
            
            let normalisedAssignedPriority = (Float(assignedPriority ?? 1  / 10)) * Float(weights["AssignedPriority"] ?? 0.0)
  
            guard let deadline = task.$EndDate.value else { return tasks }
            guard let startDate = task.$StartDate.value else { return tasks }
            let currentTime = Date()
           
            let timeTillEndDate = hoursBetween(dateA: currentTime, dateB: deadline)
            let timeSinceStartDate =  hoursBetween(dateA: startDate, dateB: currentTime)
            
            
            let subtaskNumber = task.$SubtaskNumber.value
            
             
     
             
            
            var normalisedSinceStartDate = Float((timeSinceStartDate / longestTimeSince)) * Float(weights["StartDate"] ?? 0.0)
            
            var normalisedTillEndDate = (1-Float((timeTillEndDate / longestTimeTill))) * Float(weights["EndDate"] ?? 0.0)
            
            //If the either of the start or end dates are within an hour of current time, it will return as 0.0, so it is important to ensure errors are dealt with
 
            if longestTimeSince==0.0 {
                 normalisedSinceStartDate = 0
            }
            if longestTimeTill == 0.0{
                 normalisedTillEndDate = 0
            }
            if timeSinceStartDate==0.0 {
                 normalisedSinceStartDate = 0
            }
            if timeTillEndDate == 0.0{
                 normalisedTillEndDate = 0
            }
            
    
            
            
            if abs(normalisedTillEndDate).isNaN{
                 normalisedTillEndDate = 0
            }
            if abs(normalisedSinceStartDate).isNaN{
                 normalisedSinceStartDate = 0
            }
            
            let id = (task.id ?? "error") + String(task.SubtaskNumber)
           
          
             
            let calculatedPriority = normalisedTillEndDate + normalisedSinceStartDate + normalisedFromAccess  + normalisedDecimalComplete + normalisedAssignedPriority
            
            
             
             
            try calculatedPriorities[id] = Float(calculatedPriority)
            
            
        }
         
        
        
        let orderedArray = sortDict(dict: calculatedPriorities)
        for x in calculatedPriorities{
            if !x.value.isNaN{
                calculatedPriorities.removeValue(forKey: x.key)
            }
        }
        
        
       
        var orderedTasks = [Task]()
        for id in orderedArray{
            do{
                
                let taskA = tasks.first(where: {(($0.id ?? "error")+String($0.SubtaskNumber)) == id})
                
                if taskA != nil{
                    orderedTasks.append(taskA!)
                }
                
            }
            catch{
                continue
            }
            
            
          
            
        }
        
        
        
   
        //Get factors and normalise them
        
        for y in calculatedPriorities{
            //Find any 0 priority tasks and add them to the orderTasks
            do {
                let taskA = tasks.first(where: {(($0.id ?? "error")+String($0.SubtaskNumber)) == y.key})
                if taskA != nil{
                    orderedTasks.append(taskA!)
                }
                
            }
            
            
        }
        
        return orderedTasks.reversed()
        // Needs to be reversed as merge sort orders calculated priorities from 0 to 1, so reverse it because 1 is highest
    }
    
    func hoursBetween(dateA: Date,  dateB: Date ) -> Double {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour], from: dateA, to: dateB)
        
        if let hours = components.hour {
            return Double(hours)
        } else {
            return 0
        }
    }
    
 
    func sortDict(dict: [String:Float]) -> [String]{
        var dict = dict
        var orderedArray: [String] = []
        var orderedDict:[String:Float] = [:]
        var sortedValues = mergeSort(Array(dict.values))
      
        for x in sortedValues{
            for (key,value) in dict{
                
                if x==value{
                  
                    orderedArray.append(key)
                  
                    dict.removeValue(forKey: key)
                    break
                }
            }
        }

        return orderedArray
                
    }
    
    //followed: https://medium.com/@notestomyself/merge-sort-in-swift-ae33679251e7 for this
    func mergeSort(_ array: [Float]) -> [Float] {
        // Base case: A single element array is already sorted.
        guard array.count > 1 else { return array }

        // Split the array into two halves.
        let middleIndex = array.count / 2
        let leftArray = mergeSort(Array(array[..<middleIndex]))
        let rightArray = mergeSort(Array(array[middleIndex...]))

        // Merge the two halves.
        return merge(leftArray, rightArray)
    }

    func merge(_ left: [Float], _ right: [Float]) -> [Float] {
        var leftIndex = 0
        var rightIndex = 0
        var mergedArray: [Float] = []

        // Merge elements one by one  from each side,
        // until one side is empty.
        while leftIndex < left.count && rightIndex < right.count {
            if left[leftIndex] < right[rightIndex] {
                mergedArray.append(left[leftIndex])
                leftIndex += 1
            } else {
                mergedArray.append(right[rightIndex])
                rightIndex += 1
            }
        }

        // add remaining elements from the left side.
        while leftIndex < left.count {
            mergedArray.append(left[leftIndex])
            leftIndex += 1
        }

        // add remaining elements from the right side.
        while rightIndex < right.count {
            mergedArray.append(right[rightIndex])
            rightIndex += 1
        }

        return mergedArray
    }
    func hasDatePassed(date: Date) -> Bool{
        return date < Date()
    }
}
