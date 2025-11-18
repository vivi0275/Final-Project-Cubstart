//
//  FirestoreService.swift
//  Cubstart
//
//  Created on 18/11/2025.
//

import Foundation
import FirebaseFirestore

class FirestoreService {
    static let shared = FirestoreService()
    
    private let db = Firestore.firestore()
    private let collectionName = "tasks"
    
    private init() {}
    
    // MARK: - Conversion entre NursingTask et Firestore
    
    /// Convertit un NursingTask en dictionnaire pour Firestore
    func taskToDictionary(_ task: NursingTask) -> [String: Any] {
        var dict: [String: Any] = [
            "id": task.id.uuidString,
            "title": task.title,
            "taskDescription": task.taskDescription,
            "isCompleted": task.isCompleted,
            "priority": task.priority.rawValue,
            "category": task.category.rawValue,
            "createdAt": Timestamp(date: task.createdAt)
        ]
        
        if let patientId = task.patientId {
            dict["patientId"] = patientId
        }
        
        if let dueTime = task.dueTime {
            dict["dueTime"] = Timestamp(date: dueTime)
        }
        
        if let completedAt = task.completedAt {
            dict["completedAt"] = Timestamp(date: completedAt)
        }
        
        return dict
    }
    
    /// Crée un NursingTask à partir d'un document Firestore
    func taskFromDictionary(_ dict: [String: Any]) -> NursingTask? {
        guard let idString = dict["id"] as? String,
              let id = UUID(uuidString: idString),
              let title = dict["title"] as? String,
              let taskDescription = dict["taskDescription"] as? String,
              let isCompleted = dict["isCompleted"] as? Bool,
              let priorityString = dict["priority"] as? String,
              let priority = TaskPriority(rawValue: priorityString),
              let categoryString = dict["category"] as? String,
              let category = TaskCategory(rawValue: categoryString),
              let createdAtTimestamp = dict["createdAt"] as? Timestamp else {
            return nil
        }
        
        let task = NursingTask(
            title: title,
            description: taskDescription,
            priority: priority,
            category: category,
            patientId: dict["patientId"] as? String,
            dueTime: (dict["dueTime"] as? Timestamp)?.dateValue()
        )
        
        // Restaurer les propriétés spécifiques
        task.id = id
        task.isCompleted = isCompleted
        task.createdAt = createdAtTimestamp.dateValue()
        task.completedAt = (dict["completedAt"] as? Timestamp)?.dateValue()
        
        return task
    }
    
    // MARK: - Opérations CRUD
    
    /// Ajoute ou met à jour une tâche dans Firestore
    func saveTask(_ task: NursingTask) async throws {
        print("🔥 [FirestoreService] Tentative de sauvegarde de la tâche: \(task.id.uuidString)")
        print("🔥 [FirestoreService] Titre: \(task.title)")
        
        let taskDict = taskToDictionary(task)
        print("🔥 [FirestoreService] Dictionnaire créé: \(taskDict)")
        print("🔥 [FirestoreService] Collection: \(collectionName)")
        print("🔥 [FirestoreService] Document ID: \(task.id.uuidString)")
        
        do {
            try await db.collection(collectionName).document(task.id.uuidString).setData(taskDict, merge: true)
            print("✅ [FirestoreService] Tâche sauvegardée avec succès dans Firestore!")
        } catch {
            print("❌ [FirestoreService] Erreur lors de la sauvegarde: \(error)")
            print("❌ [FirestoreService] Détails: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Supprime une tâche de Firestore
    func deleteTask(_ task: NursingTask) async throws {
        try await db.collection(collectionName).document(task.id.uuidString).delete()
    }
    
    /// Récupère toutes les tâches depuis Firestore
    func fetchAllTasks() async throws -> [NursingTask] {
        let snapshot = try await db.collection(collectionName).getDocuments()
        
        var tasks: [NursingTask] = []
        for document in snapshot.documents {
            let data = document.data()
            if let task = taskFromDictionary(data) {
                tasks.append(task)
            }
        }
        
        return tasks
    }
    
    /// Écoute les changements en temps réel dans Firestore
    func observeTasks(completion: @escaping ([NursingTask]) -> Void) -> ListenerRegistration {
        return db.collection(collectionName).addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Erreur lors de l'écoute Firestore: \(error?.localizedDescription ?? "Erreur inconnue")")
                return
            }
            
            var tasks: [NursingTask] = []
            for document in documents {
                let data = document.data()
                if let task = self.taskFromDictionary(data) {
                    tasks.append(task)
                }
            }
            
            completion(tasks)
        }
    }
    
    /// Synchronise toutes les tâches locales avec Firestore
    func syncTasks(_ localTasks: [NursingTask]) async throws {
        // Récupérer les tâches depuis Firestore
        let remoteTasks = try await fetchAllTasks()
        let remoteTaskIds = Set(remoteTasks.map { $0.id.uuidString })
        
        // Ajouter les tâches locales qui n'existent pas dans Firestore
        for localTask in localTasks {
            if !remoteTaskIds.contains(localTask.id.uuidString) {
                try await saveTask(localTask)
            }
        }
        
        // Mettre à jour les tâches qui existent dans les deux
        for localTask in localTasks {
            if let remoteTask = remoteTasks.first(where: { $0.id.uuidString == localTask.id.uuidString }) {
                // Comparer les dates de modification pour déterminer quelle version est la plus récente
                let localModified = localTask.completedAt ?? localTask.createdAt
                let remoteModified = remoteTask.completedAt ?? remoteTask.createdAt
                
                if localModified > remoteModified {
                    try await saveTask(localTask)
                }
            }
        }
    }
}

