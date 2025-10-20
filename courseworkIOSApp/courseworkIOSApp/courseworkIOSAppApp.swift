//
//  courseworkIOSAppApp.swift
//  courseworkIOSApp
//
//  Created by Caleb Saunderson on 06/12/2023.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct courseworkIOSAppApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Settings.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            LoginView().onAppear {
                
            }
        }
        .modelContainer(sharedModelContainer)
    }
    
  
}
