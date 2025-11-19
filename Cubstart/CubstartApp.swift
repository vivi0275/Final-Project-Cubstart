//
//  CubstartApp.swift
//  Cubstart
//
//  Created by victor picart on 17/11/2025.
//

import SwiftUI
import SwiftData
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("🔥 [AppDelegate] Configuring Firebase...")
        FirebaseApp.configure()
        
        if FirebaseApp.app() != nil {
            print("✅ [AppDelegate] Firebase configured successfully!")
        } else {
            print("❌ [AppDelegate] Error: Firebase could not be configured!")
        }
        
        return true
    }
}

@main
struct CubstartApp: App {
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            NursingTask.self
        ])
        
        // Use a specific URL for the database to allow reset if needed
        let url = URL.applicationSupportDirectory.appending(path: "Cubstart.sqlite")
        let modelConfiguration = ModelConfiguration(schema: schema, url: url)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // If there's an error, try to delete the old database and recreate
            print("⚠️ [CubstartApp] Error creating ModelContainer: \(error)")
            print("⚠️ [CubstartApp] Attempting to reset database...")
            
            // Delete the old database files
            let fileManager = FileManager.default
            let dbURL = url
            let shmURL = url.appendingPathExtension("sqlite-shm")
            let walURL = url.appendingPathExtension("sqlite-wal")
            
            try? fileManager.removeItem(at: dbURL)
            try? fileManager.removeItem(at: shmURL)
            try? fileManager.removeItem(at: walURL)
            
            // Try again with a fresh database
            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.modelContext, sharedModelContainer.mainContext)
                .onAppear {
                    print("🚀 [CubstartApp] Application started, initializing Firestore synchronization...")
                    
                    // Check that Firebase is initialized
                    if FirebaseApp.app() == nil {
                        print("❌ [CubstartApp] Firebase is not initialized! Synchronization will not work.")
                        return
                    }
                    
                    print("✅ [CubstartApp] Firebase is initialized")
                    
                    // Start Firestore synchronization at app startup
                    let modelContext = sharedModelContainer.mainContext
                    print("🔄 [CubstartApp] Starting Firestore listener...")
                    TaskSyncService.shared.startSyncing(modelContext: modelContext)
                    
                    // Sync all local tasks to Firestore at startup
                    Task {
                        print("🔄 [CubstartApp] Initial task synchronization...")
                        await TaskSyncService.shared.syncAllToFirestore(modelContext: modelContext)
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
