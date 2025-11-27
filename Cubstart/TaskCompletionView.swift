//
//  TaskCompletionView.swift
//  Cubstart
//
//  Created on 27/11/2025.
//  FEATURE 2: Validation + Commentaires Infirmière
//

import SwiftUI
import SwiftData

struct TaskCompletionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let task: NursingTask
    
    @State private var staffId = "N-001" // Mock - will be replaced with real auth
    @State private var completionNotes = ""
    @State private var showingSuccess = false
    
    // Predefined quick notes
    let quickNotes = [
        "Tâche accomplie sans problème",
        "Patient coopératif",
        "Patient agité - à surveiller",
        "Dosage ajusté selon protocole",
        "Besoin suivi médecin",
        "RAS - Tout s'est bien passé"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Task Info Header
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Compléter la tâche")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        // Task details
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: task.category.systemImage)
                                    .foregroundColor(Color(task.category.color))
                                Text(task.title)
                                    .font(.headline)
                            }
                            
                            if !task.taskDescription.isEmpty {
                                Text(task.taskDescription)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            if let patientId = task.patientId {
                                HStack {
                                    Image(systemName: "person.fill")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                    Text("Patient: \(patientId)")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Quick notes buttons
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Notes Rapides")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(quickNotes, id: \.self) { note in
                                    Button(action: {
                                        if completionNotes.isEmpty {
                                            completionNotes = note
                                        } else {
                                            completionNotes += "\n• \(note)"
                                        }
                                    }) {
                                        Text(note)
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color.blue.opacity(0.1))
                                            .foregroundColor(.blue)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Notes text editor
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Commentaires & Observations")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $completionNotes)
                                .frame(height: 150)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                )
                            
                            if completionNotes.isEmpty {
                                Text("Entrez vos observations sur cette tâche...\n\nExemples:\n• État du patient\n• Difficultés rencontrées\n• Points d'attention\n• Recommandations")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 16)
                                    .allowsHitTesting(false)
                            }
                        }
                        .padding(.horizontal)
                        
                        Text("\(completionNotes.count) caractères")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                    
                    // Info box
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Vos notes seront visibles par le médecin")
                                .font(.caption)
                                .fontWeight(.semibold)
                            Text("Soyez précis et professionnel")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Complete button
                    Button(action: completeTask) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                            Text("Marquer comme Terminée")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(completionNotes.isEmpty ? Color.gray : Color.green)
                        .cornerRadius(12)
                    }
                    .disabled(completionNotes.isEmpty)
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .padding(.vertical)
            }
            .navigationTitle("Validation Tâche")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
            .alert("Tâche Complétée !", isPresented: $showingSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("La tâche a été marquée comme terminée. Le médecin verra vos commentaires.")
            }
        }
    }
    
    private func completeTask() {
        // Complete with notes
        task.completeWithNotes(staffId: staffId, notes: completionNotes)
        
        // Save to SwiftData
        do {
            try modelContext.save()
            print("✅ Task completed with notes by \(staffId)")
            
            // Sync with Firestore
            Task {
                await TaskSyncService.shared.syncTaskToFirestore(task)
            }
            
            showingSuccess = true
        } catch {
            print("❌ Error completing task: \(error)")
        }
    }
}

// Preview with mock task
#Preview {
    let task = NursingTask(
        title: "Vérifier les signes vitaux",
        description: "Mesurer TA, FC, température et SpO2",
        priority: .important,
        category: .patientCare,
        patientId: "P-001"
    )
    
    return TaskCompletionView(task: task)
        .modelContainer(for: NursingTask.self, inMemory: true)
}
