//
//  TaskRowView.swift
//  Cubstart
//
//  Created by victor picart on 17/11/2025.
//

import SwiftUI
import SwiftData

struct TaskRowView: View {
    @Environment(\.modelContext) private var modelContext
    let task: NursingTask
    
    var body: some View {
        HStack(spacing: 12) {
            // Bouton de completion
            Button(action: {
                task.toggleCompletion()
                try? modelContext.save()
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .gray)
                    .font(.title2)
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: 4) {
                // Titre et catégorie
                HStack {
                    Image(systemName: task.category.systemImage)
                        .foregroundColor(Color(task.category.color))
                        .font(.caption)
                    
                    Text(task.title)
                        .font(.headline)
                        .strikethrough(task.isCompleted)
                        .opacity(task.isCompleted ? 0.6 : 1.0)
                    
                    Spacer()
                    
                    // Indicateur de priorité
                    Image(systemName: task.priority.systemImage)
                        .foregroundColor(Color(task.priority.color))
                        .font(.caption)
                }
                
                // Description si présente
                if !task.taskDescription.isEmpty {
                    Text(task.taskDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                // Informations additionnelles
                HStack(spacing: 8) {
                    Text(task.category.rawValue)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(task.category.color).opacity(0.2))
                        .cornerRadius(4)
                    
                    if let patientId = task.patientId {
                        Text("Patient: \(patientId)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if let dueTime = task.dueTime {
                        HStack(spacing: 2) {
                            Image(systemName: "clock")
                                .font(.caption2)
                            Text(dueTime, style: .time)
                                .font(.caption2)
                        }
                        .foregroundColor(dueTime < Date() && !task.isCompleted ? .red : .secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .background(task.isCompleted ? Color.clear : Color(UIColor.systemBackground))
    }
}

struct TaskDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let task: NursingTask
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // En-tête avec statut
                    HStack {
                        VStack(alignment: .leading) {
                            Text(task.title)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            HStack {
                                Image(systemName: task.category.systemImage)
                                    .foregroundColor(Color(task.category.color))
                                Text(task.category.rawValue)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            task.toggleCompletion()
                            try? modelContext.save()
                        }) {
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                .font(.largeTitle)
                                .foregroundColor(task.isCompleted ? .green : .gray)
                        }
                    }
                    
                    Divider()
                    
                    // Détails
                    VStack(alignment: .leading, spacing: 16) {
                        if !task.taskDescription.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Description")
                                    .font(.headline)
                                Text(task.taskDescription)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Priorité")
                                    .font(.headline)
                                HStack {
                                    Image(systemName: task.priority.systemImage)
                                        .foregroundColor(Color(task.priority.color))
                                    Text(task.priority.rawValue)
                                }
                            }
                            
                            Spacer()
                            
                            if let patientId = task.patientId {
                                VStack(alignment: .trailing) {
                                    Text("Patient")
                                        .font(.headline)
                                    Text(patientId)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        if let dueTime = task.dueTime {
                            VStack(alignment: .leading) {
                                Text("Échéance")
                                    .font(.headline)
                                Text(dueTime, style: .date)
                                    .foregroundColor(dueTime < Date() && !task.isCompleted ? .red : .secondary)
                                Text(dueTime, style: .time)
                                    .foregroundColor(dueTime < Date() && !task.isCompleted ? .red : .secondary)
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Créée le")
                                .font(.headline)
                            Text(task.createdAt, style: .date)
                                .foregroundColor(.secondary)
                        }
                        
                        if let completedAt = task.completedAt {
                            VStack(alignment: .leading) {
                                Text("Terminée le")
                                    .font(.headline)
                                Text(completedAt, style: .date)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Détails")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    let sampleTask = NursingTask(
        title: "Administrer médicament",
        description: "Donner les médicaments du matin au patient de la chambre 12",
        priority: .important,
        category: .medication,
        patientId: "P-001",
        dueTime: Date().addingTimeInterval(3600)
    )
    
    TaskRowView(task: sampleTask)
        .modelContainer(for: NursingTask.self, inMemory: true)
}
