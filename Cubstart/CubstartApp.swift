//
//  CubstartApp.swift
//  Cubstart
//
//  Created by victor picart on 17/11/2025.
//  Modified on 26/11/2025 - Added Patient model
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
            NursingTask.self,
            Patient.self,
            MedicalProtocol.self  // NOUVEAU
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
                    
                    // Add some sample patients for testing (only in development)
                    #if DEBUG
                    addSamplePatientsIfNeeded(modelContext: modelContext)
                    #endif
                }
        }
        .modelContainer(sharedModelContainer)
    }
    
    #if DEBUG
    private func addSamplePatientsIfNeeded(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<Patient>()
        
        do {
            let existingPatients = try modelContext.fetch(descriptor)
            
            if existingPatients.isEmpty {
                print("📝 [CubstartApp] Adding sample patients for testing...")
                
                let samplePatients = [
                    Patient(
                        patientId: "P-001",
                        name: "John Smith",
                        roomNumber: "302",
                        diagnosis: "Post-operative recovery following appendectomy",
                        status: .stable,
                        notes: "Patient recovering well, pain managed with medication",
                        assignedDoctor: "Dr. Anderson"
                    ),
                    Patient(
                        patientId: "P-002",
                        name: "Maria Garcia",
                        roomNumber: "215",
                        diagnosis: "Pneumonia",
                        status: .serious,
                        notes: "Requires frequent vital signs monitoring",
                        assignedDoctor: "Dr. Chen"
                    ),
                    Patient(
                        patientId: "P-003",
                        name: "Robert Johnson",
                        roomNumber: "401",
                        diagnosis: "Cardiac monitoring following MI",
                        status: .critical,
                        notes: "ICU patient, continuous cardiac monitoring required",
                        assignedDoctor: "Dr. Williams"
                    ),
                    Patient(
                        patientId: "P-004",
                        name: "Emily Davis",
                        roomNumber: "118",
                        diagnosis: "Diabetes management",
                        status: .stable,
                        notes: "Blood sugar levels stabilizing, patient education ongoing",
                        assignedDoctor: "Dr. Martinez"
                    ),
                    Patient(
                        patientId: "P-005",
                        name: "Michael Brown",
                        roomNumber: "309",
                        diagnosis: "Fracture repair - femur",
                        status: .recovering,
                        notes: "Physical therapy started, mobility improving",
                        assignedDoctor: "Dr. Anderson"
                    )
                ]
                
                for patient in samplePatients {
                    modelContext.insert(patient)
                }
                
                try modelContext.save()
                print("✅ [CubstartApp] Sample patients added successfully")
            }
        } catch {
            print("❌ [CubstartApp] Error checking/adding sample patients: \(error)")
        }
    }
    #endif
}
