//
//  DoctorValidationView.swift
//  Cubstart
//
//  Created on 27/11/2025.
//  FEATURE 2: Vue de validation médecin
//

import SwiftUI
import SwiftData

struct DoctorValidationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var patients: [Patient]
    
    let task: NursingTask
    
    @State private var doctorNotes = ""
    @State private var showingValidationConfirm = false
    
    var patient: Patient? {
        patients.first { $0.patientId == task.patientId }
    }
    
    var staffMember: StaffMember? {
        StaffMember.mockStaff.first { $0.staffId == task.completedByStaffId }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Validation alert header
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.purple)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Validation Required")
                                .font(.headline)
                                .fontWeight(.bold)
                            Text("This task has been completed by the nurse")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Task details
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Task Details")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 12) {
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
                            
                            Divider()
                            
                            // Task metadata
                            VStack(alignment: .leading, spacing: 8) {
                                if let patient = patient {
                                    HStack {
                                        Image(systemName: "person.fill")
                                            .foregroundColor(.blue)
                                            .frame(width: 20)
                                        Text("Patient:")
                                            .foregroundColor(.secondary)
                                        Text("\(patient.name) (\(patient.patientId))")
                                            .fontWeight(.medium)
                                    }
                                    .font(.subheadline)
                                }
                                
                                HStack {
                                    Image(systemName: task.priority.systemImage)
                                        .foregroundColor(Color(task.priority.color))
                                        .frame(width: 20)
                                    Text("Priority:")
                                        .foregroundColor(.secondary)
                                    Text(task.priority.rawValue)
                                        .fontWeight(.medium)
                                }
                                .font(.subheadline)
                                
                                HStack {
                                    Image(systemName: task.category.systemImage)
                                        .foregroundColor(Color(task.category.color))
                                        .frame(width: 20)
                                    Text("Category:")
                                        .foregroundColor(.secondary)
                                    Text(task.category.rawValue)
                                        .fontWeight(.medium)
                                }
                                .font(.subheadline)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // Completion info
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Completion Information")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            // Who completed
                            if let staff = staffMember {
                                HStack(spacing: 12) {
                                    Image(systemName: staff.role.systemImage)
                                        .font(.title3)
                                        .foregroundColor(.blue)
                                        .frame(width: 40, height: 40)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(8)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(staff.name)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        Text("\(staff.role.rawValue) • \(staff.department)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                            }
                            
                            // When completed
                            if let completedAt = task.completedAt {
                                HStack {
                                    Image(systemName: "clock.fill")
                                        .foregroundColor(.green)
                                        .frame(width: 20)
                                    Text("Completed on:")
                                        .foregroundColor(.secondary)
                                    Text(completedAt, style: .date)
                                        .fontWeight(.medium)
                                    Text("at")
                                        .foregroundColor(.secondary)
                                    Text(completedAt, style: .time)
                                        .fontWeight(.medium)
                                }
                                .font(.subheadline)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // Nurse's notes
                    if let notes = task.completedNotes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Nurse's Notes", systemImage: "note.text")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(notes)
                                    .font(.body)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                HStack {
                                    Spacer()
                                    Text("— \(staffMember?.name ?? "Nurse")")
                                        .font(.caption)
                                        .italic()
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .background(Color.blue.opacity(0.05))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                            )
                            .padding(.horizontal)
                        }
                    }
                    
                    // Doctor's notes input
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Your Comments (Optional)", systemImage: "stethoscope")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $doctorNotes)
                                .frame(height: 120)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                )
                            
                            if doctorNotes.isEmpty {
                                Text("Add your remarks, congratulations or recommendations...\n\nExamples:\n• \"Well done, continue\"\n• \"Pay attention to dosage next time\"\n• \"Monitor side effects\"")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 16)
                                    .allowsHitTesting(false)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Validate button
                    Button(action: {
                        showingValidationConfirm = true
                    }) {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.title3)
                            Text("Validate Task")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.green, .green.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: .green.opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .padding(.vertical)
            }
            .navigationTitle("Task Validation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .confirmationDialog(
                "Validate this task?",
                isPresented: $showingValidationConfirm,
                titleVisibility: .visible
            ) {
                Button("Validate") {
                    validateTask()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Confirm that this task has been correctly completed by the nurse.")
            }
        }
    }
    
    private func validateTask() {
        // Validate with optional notes
        task.validateByDoctor(notes: doctorNotes.isEmpty ? nil : doctorNotes)
        
        // Save to SwiftData
        do {
            try modelContext.save()
            print("✅ Task validated by doctor")
            
            // Sync with Firestore
            Task {
                await TaskSyncService.shared.syncTaskToFirestore(task)
            }
            
            dismiss()
        } catch {
            print("❌ Error validating task: \(error)")
        }
    }
}

#Preview {
    let task = NursingTask(
        title: "Administrer médication",
        description: "Paracétamol 1g, voie orale",
        priority: .important,
        category: .medication,
        patientId: "P-001"
    )
    task.completeWithNotes(staffId: "N-001", notes: "Médicament administré à 14h00. Patient n'a signalé aucune douleur résiduelle. Surveillance continue pour les 2 prochaines heures.")
    
    return DoctorValidationView(task: task)
        .modelContainer(for: [NursingTask.self, Patient.self], inMemory: true)
}
