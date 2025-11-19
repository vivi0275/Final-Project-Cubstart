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
                Section("General Information") {
                    TextField("Task title", text: $title)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Description (optional)", text: $taskDescription, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...6)
                }
                
                Section("Category") {
                    Picker("Activity type", selection: $selectedCategory) {
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
                
                Section("Priority") {
                    Picker("Priority level", selection: $selectedPriority) {
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
                
                Section("Patient (optional)") {
                    TextField("Patient ID or name", text: $patientId)
                        .textFieldStyle(.roundedBorder)
                }
                
                Section("Due Date") {
                    Toggle("Set a deadline", isOn: $hasDueTime)
                    
                    if hasDueTime {
                        DatePicker("Deadline", selection: $dueTime, displayedComponents: [.date, .hourAndMinute])
                    }
                }
            }
            .navigationTitle("New Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
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
            print("✅ [AddTaskView] Task saved locally: \(newTask.title)")
            
            // Sync with Firestore
            print("🔄 [AddTaskView] Starting Firestore synchronization...")
            Task {
                await TaskSyncService.shared.syncTaskToFirestore(newTask)
            }
            
            dismiss()
        } catch {
            print("❌ [AddTaskView] Error saving locally: \(error)")
        }
    }
}

#Preview {
    AddTaskView()
        .modelContainer(for: NursingTask.self, inMemory: true)
}
