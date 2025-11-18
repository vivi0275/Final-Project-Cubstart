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

/// Service qui synchronise les tâches entre SwiftData (local) et Firestore (cloud)
class TaskSyncService {
    static let shared = TaskSyncService()
    
    private let firestoreService = FirestoreService.shared
    private var listener: ListenerRegistration?
    
    private init() {}
    
    /// Configure la synchronisation avec Firestore
    func startSyncing(modelContext: ModelContext) {
        // Écouter les changements depuis Firestore
        listener = firestoreService.observeTasks { [weak self] remoteTasks in
            Task { @MainActor in
                self?.syncRemoteToLocal(remoteTasks, modelContext: modelContext)
            }
        }
        print("✅ [TaskSyncService] Écoute Firestore démarrée")
    }
    
    /// Arrête la synchronisation
    func stopSyncing() {
        listener?.remove()
        listener = nil
    }
    
    /// Synchronise les tâches distantes vers le stockage local (SwiftData)
    private func syncRemoteToLocal(_ remoteTasks: [NursingTask], modelContext: ModelContext) {
        let descriptor = FetchDescriptor<NursingTask>()
        
        do {
            let localTasks = try modelContext.fetch(descriptor)
            let localTaskIds = Set(localTasks.map { $0.id.uuidString })
            
            // Ajouter les nouvelles tâches depuis Firestore
            for remoteTask in remoteTasks {
                if !localTaskIds.contains(remoteTask.id.uuidString) {
                    // Créer une nouvelle tâche locale à partir de la tâche distante
                    let newTask = NursingTask(
                        title: remoteTask.title,
                        description: remoteTask.taskDescription,
                        priority: remoteTask.priority,
                        category: remoteTask.category,
                        patientId: remoteTask.patientId,
                        dueTime: remoteTask.dueTime
                    )
                    
                    // Restaurer les propriétés
                    newTask.id = remoteTask.id
                    newTask.isCompleted = remoteTask.isCompleted
                    newTask.createdAt = remoteTask.createdAt
                    newTask.completedAt = remoteTask.completedAt
                    
                    modelContext.insert(newTask)
                } else {
                    // Mettre à jour la tâche existante si nécessaire
                    if let localTask = localTasks.first(where: { $0.id.uuidString == remoteTask.id.uuidString }) {
                        let localModified = localTask.completedAt ?? localTask.createdAt
                        let remoteModified = remoteTask.completedAt ?? remoteTask.createdAt
                        
                        // Mettre à jour seulement si la version distante est plus récente
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
            
            // Supprimer les tâches locales qui n'existent plus dans Firestore
            for localTask in localTasks {
                if !remoteTasks.contains(where: { $0.id.uuidString == localTask.id.uuidString }) {
                    modelContext.delete(localTask)
                }
            }
            
            try? modelContext.save()
        } catch {
            print("Erreur lors de la synchronisation locale: \(error)")
        }
    }
    
    /// Synchronise une tâche locale vers Firestore
    func syncTaskToFirestore(_ task: NursingTask) async {
        print("🔄 [TaskSyncService] Début de la synchronisation de la tâche: \(task.title)")
        
        // Vérifier que Firebase est initialisé
        if FirebaseApp.app() == nil {
            print("❌ [TaskSyncService] Firebase n'est pas initialisé!")
            return
        }
        
        do {
            try await firestoreService.saveTask(task)
            print("✅ [TaskSyncService] Synchronisation réussie pour: \(task.title)")
        } catch {
            print("❌ [TaskSyncService] Erreur lors de la synchronisation vers Firestore")
            print("❌ [TaskSyncService] Type d'erreur: \(type(of: error))")
            print("❌ [TaskSyncService] Message: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("❌ [TaskSyncService] Code d'erreur: \(nsError.code)")
                print("❌ [TaskSyncService] Domaine: \(nsError.domain)")
                print("❌ [TaskSyncService] UserInfo: \(nsError.userInfo)")
            }
        }
    }
    
    /// Supprime une tâche de Firestore
    func deleteTaskFromFirestore(_ task: NursingTask) async {
        do {
            try await firestoreService.deleteTask(task)
        } catch {
            print("Erreur lors de la suppression dans Firestore: \(error)")
        }
    }
    
    /// Synchronise toutes les tâches locales vers Firestore
    func syncAllToFirestore(modelContext: ModelContext) async {
        let descriptor = FetchDescriptor<NursingTask>()
        
        do {
            let localTasks = try modelContext.fetch(descriptor)
            
            for task in localTasks {
                try await firestoreService.saveTask(task)
            }
            
            print("✅ Synchronisation complète vers Firestore terminée: \(localTasks.count) tâches")
        } catch {
            print("Erreur lors de la synchronisation complète: \(error)")
        }
    }
}

