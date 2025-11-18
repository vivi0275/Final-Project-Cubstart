//
//  AddTaskView.swift
//  Cubstart
//
//  Created by victor picart on 17/11/2025.
//

import SwiftUI
import SwiftData

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var title = ""
    @State private var taskDescription = ""
    @State private var selectedPriority: TaskPriority = .normal
    @State private var selectedCategory: TaskCategory = .patientCare
    @State private var patientId = ""
    @State private var hasDueTime = false
    @State private var dueTime = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Informations générales") {
                    TextField("Titre de la tâche", text: $title)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Description (optionnel)", text: $taskDescription, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...6)
                }
                
                Section("Catégorie") {
                    Picker("Type d'activité", selection: $selectedCategory) {
                        ForEach(TaskCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.systemImage)
                                    .foregroundColor(Color(category.color))
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                }
                
                Section("Priorité") {
                    Picker("Niveau de priorité", selection: $selectedPriority) {
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                            HStack {
                                Image(systemName: priority.systemImage)
                                    .foregroundColor(Color(priority.color))
                                Text(priority.rawValue)
                            }
                            .tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Patient (optionnel)") {
                    TextField("ID ou nom du patient", text: $patientId)
                        .textFieldStyle(.roundedBorder)
                }
                
                Section("Échéance") {
                    Toggle("Définir une heure limite", isOn: $hasDueTime)
                    
                    if hasDueTime {
                        DatePicker("Heure limite", selection: $dueTime, displayedComponents: [.date, .hourAndMinute])
                    }
                }
            }
            .navigationTitle("Nouvelle tâche")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ajouter") {
                        addTask()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func addTask() {
        let newTask = NursingTask(
            title: title,
            description: taskDescription,
            priority: selectedPriority,
            category: selectedCategory,
            patientId: patientId.isEmpty ? nil : patientId,
            dueTime: hasDueTime ? dueTime : nil
        )
        
        modelContext.insert(newTask)
        
        do {
            try modelContext.save()
            print("✅ [AddTaskView] Tâche sauvegardée localement: \(newTask.title)")
            
            // Synchroniser avec Firestore
            print("🔄 [AddTaskView] Démarrage de la synchronisation avec Firestore...")
            Task {
                await TaskSyncService.shared.syncTaskToFirestore(newTask)
            }
            
            dismiss()
        } catch {
            print("❌ [AddTaskView] Erreur lors de la sauvegarde locale: \(error)")
        }
    }
}

#Preview {
    AddTaskView()
        .modelContainer(for: NursingTask.self, inMemory: true)
}
