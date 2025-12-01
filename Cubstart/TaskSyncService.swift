//
//  TaskSyncService.swift
//  Cubstart
//
//  Created on 18/11/2025.
//

import Foundation
import SwiftData
import FirebaseFirestore
import FirebaseCore

/// Service that synchronizes tasks between SwiftData (local) and Firestore (cloud)
class TaskSyncService {
    static let shared = TaskSyncService()
    
    private let firestoreService = FirestoreService.shared
    private var listener: ListenerRegistration?
    
    private init() {}
    
    /// Configures synchronization with Firestore
    func startSyncing(modelContext: ModelContext) {
        // Check that Firebase is initialized
        guard FirebaseApp.app() != nil else {
            print("⚠️ [TaskSyncService] Firebase is not initialized. Synchronization disabled.")
            return
        }
        
        // Listen to changes from Firestore
        if let newListener = firestoreService.observeTasks(completion: { [weak self] remoteTasks in
            Task { @MainActor in
                self?.syncRemoteToLocal(remoteTasks, modelContext: modelContext)
            }
        }) {
            listener = newListener
            print("✅ [TaskSyncService] Firestore listener started")
        } else {
            print("⚠️ [TaskSyncService] Could not start Firestore listener")
        }
    }
    
    /// Stops synchronization
    func stopSyncing() {
        listener?.remove()
        listener = nil
    }
    
    /// Synchronizes remote tasks to local storage (SwiftData)
    private func syncRemoteToLocal(_ remoteTasks: [NursingTask], modelContext: ModelContext) {
        let descriptor = FetchDescriptor<NursingTask>()
        
        do {
            let localTasks = try modelContext.fetch(descriptor)
            let localTaskIds = Set(localTasks.map { $0.id.uuidString })
            
            // Add new tasks from Firestore
            for remoteTask in remoteTasks {
                if !localTaskIds.contains(remoteTask.id.uuidString) {
                    // Create a new local task from the remote task
                    let newTask = NursingTask(
                        title: remoteTask.title,
                        description: remoteTask.taskDescription,
                        priority: remoteTask.priority,
                        category: remoteTask.category,
                        patientId: remoteTask.patientId,
                        dueTime: remoteTask.dueTime
                    )
                    
                    // Restore properties
                    newTask.id = remoteTask.id
                    newTask.isCompleted = remoteTask.isCompleted
                    newTask.createdAt = remoteTask.createdAt
                    newTask.completedAt = remoteTask.completedAt
                    
                    modelContext.insert(newTask)
                } else {
                    // Update existing task if necessary
                    if let localTask = localTasks.first(where: { $0.id.uuidString == remoteTask.id.uuidString }) {
                        let localModified = localTask.completedAt ?? localTask.createdAt
                        let remoteModified = remoteTask.completedAt ?? remoteTask.createdAt
                        
                        // Update only if remote version is more recent
                        if remoteModified > localModified {
                            localTask.title = remoteTask.title
                            localTask.taskDescription = remoteTask.taskDescription
                            localTask.isCompleted = remoteTask.isCompleted
                            localTask.priority = remoteTask.priority
                            localTask.category = remoteTask.category
                            localTask.patientId = remoteTask.patientId
                            localTask.dueTime = remoteTask.dueTime
                            localTask.completedAt = remoteTask.completedAt
                        }
                    }
                }
            }
            
            // Delete local tasks that no longer exist in Firestore
            for localTask in localTasks {
                if !remoteTasks.contains(where: { $0.id.uuidString == localTask.id.uuidString }) {
                    modelContext.delete(localTask)
                }
            }
            
            try? modelContext.save()
        } catch {
            print("Error during local synchronization: \(error)")
        }
    }
    
    /// Synchronizes a local task to Firestore
    func syncTaskToFirestore(_ task: NursingTask) async {
        print("🔄 [TaskSyncService] Starting task synchronization: \(task.title)")
        
        // Check that Firebase is initialized
        if FirebaseApp.app() == nil {
            print("❌ [TaskSyncService] Firebase is not initialized!")
            return
        }
        
        do {
            try await firestoreService.saveTask(task)
            print("✅ [TaskSyncService] Synchronization successful for: \(task.title)")
        } catch {
            print("❌ [TaskSyncService] Error synchronizing to Firestore")
            print("❌ [TaskSyncService] Error type: \(type(of: error))")
            print("❌ [TaskSyncService] Message: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("❌ [TaskSyncService] Error code: \(nsError.code)")
                print("❌ [TaskSyncService] Domain: \(nsError.domain)")
                print("❌ [TaskSyncService] UserInfo: \(nsError.userInfo)")
            }
        }
    }
    
    /// Deletes a task from Firestore
    func deleteTaskFromFirestore(_ task: NursingTask) async {
        // Check that Firebase is initialized
        guard FirebaseApp.app() != nil else {
            print("⚠️ [TaskSyncService] Firebase is not initialized. Cannot delete from Firestore.")
            return
        }
        
        do {
            try await firestoreService.deleteTask(task)
        } catch {
            print("Error deleting from Firestore: \(error)")
        }
    }
    
    /// Synchronizes all local tasks to Firestore
    func syncAllToFirestore(modelContext: ModelContext) async {
        // Check that Firebase is initialized
        guard FirebaseApp.app() != nil else {
            print("⚠️ [TaskSyncService] Firebase is not initialized. Cannot sync to Firestore.")
            return
        }
        
        let descriptor = FetchDescriptor<NursingTask>()
        
        do {
            let localTasks = try modelContext.fetch(descriptor)
            
            for task in localTasks {
                try await firestoreService.saveTask(task)
            }
            
            print("✅ Complete synchronization to Firestore finished: \(localTasks.count) tasks")
        } catch {
            print("Error during complete synchronization: \(error)")
        }
    }
}

