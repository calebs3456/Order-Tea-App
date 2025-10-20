//
//  File.swift
//  
//
//  Created by Caleb Saunderson on 25/01/2024.
//

import Foundation
import Vapor


class NotificationPayloadDeveloper{
    let app: Application
    
    init(app: Application) {
        self.app = app
    }
  
    func performScheduledNotification(app: Application) {
        app.logger.info("Performing scheduled notification check at \(Date())")

        // Fetch tasks from the database
        Task.query(on: app.db).all().whenComplete { result in
            switch result {
            case .success(let tasks):
                // Iterate over fetched tasks and check if notifications need to be sent
                tasks.forEach { task in
                    
                    self.checkAndSendNotification(for: task, app: app)
                }
            case .failure(let error):
                // Handle any errors
                app.logger.error("Failed to fetch tasks: \(error)")
            }
        }
    }
    
    func checkAndSendNotification(for task: Task, app: Application) {
        let now = Date()
        let calendar = Calendar.current

        // Get components for now and the task's reminder date
        let nowComponents = calendar.dateComponents([.year, .month, .day, .hour], from: now)
        let reminderComponents = calendar.dateComponents([.year, .month, .day, .hour], from: task.Reminder)

        // Check if the current date and hour match the task's reminder date and hour
        if nowComponents.year == reminderComponents.year,
           nowComponents.month == reminderComponents.month,
           nowComponents.day == reminderComponents.day,
           nowComponents.hour == reminderComponents.hour {
            // If it's the same hour, prepare and send the notification
            prepareAndSendNotification(for: task, app: app)
        }
    }
    
    func prepareAndSendNotification(for task: Task, app: Application) {
        let notificationData = ["aps": ["alert": "Remember to do task: \(task.title)", "badge": 1, "sound": "default"]]

        app.logger.info("Preparing to send notification for task: \(task.title)")

        writeJSON(jsonData: notificationData, app: app)
    }
    //This function writes a JSON file with the data above into the path stated
    func writeJSON(jsonData: [String: Any], app: Application) {
        app.eventLoopGroup.next().execute {
            do {
                let jsonOutput = try JSONSerialization.data(withJSONObject: jsonData, options: .prettyPrinted)
                let fileManager = FileManager.default

                let fileURL = URL(fileURLWithPath: "/Users/calebsaunderson/Coursework/Notifications/notificationPayload.json")

                try jsonOutput.write(to: fileURL, options: [])

                app.logger.info("Successfully wrote notification payload to file.")
            } catch {
                app.logger.error("Failed to write JSON data: \(error.localizedDescription)")
            }
        }
    }
    
    
}
