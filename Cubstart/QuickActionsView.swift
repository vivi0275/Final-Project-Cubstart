//
//  QuickActionsView.swift
//  Cubstart
//
//  Created by victor picart on 17/11/2025.
//

import SwiftUI
import SwiftData

struct QuickActionsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let quickTasks = [
        QuickTask(title: "Blood pressure check", category: .patientCare, priority: .normal),
        QuickTask(title: "Medication distribution", category: .medication, priority: .important),
        QuickTask(title: "Room rounds", category: .rounds, priority: .normal),
        QuickTask(title: "Update records", category: .documentation, priority: .normal),
        QuickTask(title: "Team meeting", category: .teamMeeting, priority: .normal),
        QuickTask(title: "Continuing education", category: .training, priority: .normal)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Quickly add common tasks")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding(.top)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                        ], spacing: 16) {
                        ForEach(quickTasks, id: \.title) { quickTask in
                            QuickTaskCard(quickTask: quickTask) {
                                addQuickTask(quickTask)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Quick Actions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addQuickTask(_ quickTask: QuickTask) {
        let task = NursingTask(
            title: quickTask.title,
            priority: quickTask.priority,
            category: quickTask.category
        )
        
        modelContext.insert(task)
        
        do {
            try modelContext.save()
            
            // Sync with Firestore
            Task {
                await TaskSyncService.shared.syncTaskToFirestore(task)
            }
        } catch {
            print("Error saving: \(error)")
        }
    }
}

struct QuickTask {
    let title: String
    let category: TaskCategory
    let priority: TaskPriority
}

struct QuickTaskCard: View {
    let quickTask: QuickTask
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: quickTask.category.systemImage)
                    .font(.system(size: 32))
                    .foregroundColor(Color(quickTask.category.color))
                
                Text(quickTask.title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                
                HStack {
                    Image(systemName: quickTask.priority.systemImage)
                        .foregroundColor(Color(quickTask.priority.color))
                        .font(.caption)
                    
                    Text(quickTask.priority.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(quickTask.category.color).opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(quickTask.category.color).opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    QuickActionsView()
        .modelContainer(for: NursingTask.self, inMemory: true)
}
