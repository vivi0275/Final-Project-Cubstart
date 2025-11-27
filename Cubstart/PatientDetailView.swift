//
//  PatientDetailView.swift
//  Cubstart
//
//  Created on 26/11/2025.
//

import SwiftUI
import SwiftData

struct PatientDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [NursingTask]
    
    let patient: Patient
    
    @State private var showingAddTask = false
    @State private var showingEditPatient = false
    
    var patientTasks: [NursingTask] {
        tasks.filter { $0.patientId == patient.patientId }
            .sorted { task1, task2 in
                // Incomplete tasks first
                if task1.isCompleted != task2.isCompleted {
                    return !task1.isCompleted
                }
                
                // Then by priority
                let priority1Value = task1.priority == .urgent ? 3 : task1.priority == .important ? 2 : 1
                let priority2Value = task2.priority == .urgent ? 3 : task2.priority == .important ? 2 : 1
                
                if priority1Value != priority2Value {
                    return priority1Value > priority2Value
                }
                
                // Then by due date
                if let due1 = task1.dueTime, let due2 = task2.dueTime {
                    return due1 < due2
                }
                
                return task1.createdAt > task2.createdAt
            }
    }
    
    var activeTasks: [NursingTask] {
        patientTasks.filter { !$0.isCompleted }
    }
    
    var completedTasks: [NursingTask] {
        patientTasks.filter { $0.isCompleted }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Patient header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(patient.name)
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                HStack(spacing: 12) {
                                    Label(patient.patientId, systemImage: "person.text.rectangle")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    if let room = patient.roomNumber {
                                        Label("Room \(room)", systemImage: "bed.double.fill")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            // Status badge
                            VStack(spacing: 4) {
                                Image(systemName: patient.status.systemImage)
                                    .font(.title2)
                                    .foregroundColor(Color(patient.status.color))
                                
                                Text(patient.status.rawValue)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(patient.status.color))
                            }
                            .padding()
                            .background(Color(patient.status.color).opacity(0.1))
                            .cornerRadius(12)
                        }
                        
                        // Diagnosis
                        if let diagnosis = patient.diagnosis {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Diagnosis")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .textCase(.uppercase)
                                
                                Text(diagnosis)
                                    .font(.body)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        
                        // Admission info
                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Admitted")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .textCase(.uppercase)
                                
                                Text(patient.admissionDate, style: .date)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            
                            if let doctor = patient.assignedDoctor {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Attending")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .textCase(.uppercase)
                                    
                                    Text(doctor)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    // Task statistics
                    HStack(spacing: 12) {
                        StatBox(
                            title: "Total Tasks",
                            value: "\(patientTasks.count)",
                            color: .blue,
                            icon: "list.bullet"
                        )
                        
                        StatBox(
                            title: "Active",
                            value: "\(activeTasks.count)",
                            color: .orange,
                            icon: "clock.fill"
                        )
                        
                        StatBox(
                            title: "Completed",
                            value: "\(completedTasks.count)",
                            color: .green,
                            icon: "checkmark.circle.fill"
                        )
                        
                        let urgentCount = activeTasks.filter { $0.priority == .urgent }.count
                        if urgentCount > 0 {
                            StatBox(
                                title: "Urgent",
                                value: "\(urgentCount)",
                                color: .red,
                                icon: "exclamationmark.triangle.fill"
                            )
                        }
                    }
                    
                    // Quick add task button
                    Button(action: { showingAddTask = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                            Text("Assign New Task")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    
                    // Tasks timeline
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tasks Timeline")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if patientTasks.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "list.bullet.clipboard")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                
                                Text("No tasks assigned yet")
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 30)
                        } else {
                            // Active tasks
                            if !activeTasks.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("ACTIVE TASKS")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.orange)
                                        .padding(.horizontal)
                                    
                                    ForEach(activeTasks) { task in
                                        TaskTimelineRow(task: task)
                                    }
                                }
                            }
                            
                            // Completed tasks
                            if !completedTasks.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("COMPLETED TASKS")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.green)
                                        .padding(.horizontal)
                                        .padding(.top, activeTasks.isEmpty ? 0 : 16)
                                    
                                    ForEach(completedTasks.prefix(10)) { task in
                                        TaskTimelineRow(task: task)
                                    }
                                    
                                    if completedTasks.count > 10 {
                                        Text("+ \(completedTasks.count - 10) more completed")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .padding(.horizontal)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Notes section
                    if !patient.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.headline)
                            
                            Text(patient.notes)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
            }
            .navigationTitle("Patient Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingEditPatient = true }) {
                            Label("Edit Patient Info", systemImage: "pencil")
                        }
                        
                        Button(action: { showingAddTask = true }) {
                            Label("Assign Task", systemImage: "plus.circle")
                        }
                        
                        Divider()
                        
                        Button(role: .destructive, action: deletePatient) {
                            Label("Delete Patient", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                DoctorCreateTaskView(preselectedPatientId: patient.patientId)
            }
            .sheet(isPresented: $showingEditPatient) {
                EditPatientView(patient: patient)
            }
        }
    }
    
    private func deletePatient() {
        // Delete all associated tasks first
        for task in patientTasks {
            modelContext.delete(task)
        }
        
        modelContext.delete(patient)
        try? modelContext.save()
        dismiss()
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct TaskTimelineRow: View {
    @Environment(\.modelContext) private var modelContext
    let task: NursingTask
    
    var body: some View {
        HStack(spacing: 12) {
            // Timeline indicator
            VStack {
                Circle()
                    .fill(task.isCompleted ? Color.green : Color(task.priority.color))
                    .frame(width: 12, height: 12)
                
                if !task.isCompleted {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 2)
                }
            }
            .frame(width: 12)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: task.category.systemImage)
                        .font(.caption)
                        .foregroundColor(Color(task.category.color))
                    
                    Text(task.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .strikethrough(task.isCompleted)
                    
                    Spacer()
                    
                    if !task.isCompleted {
                        Image(systemName: task.priority.systemImage)
                            .font(.caption)
                            .foregroundColor(Color(task.priority.color))
                    }
                }
                
                HStack(spacing: 8) {
                    Text(task.createdAt, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    if let dueTime = task.dueTime {
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(dueTime, style: .relative)
                            .font(.caption2)
                            .foregroundColor(task.isOverdue ? .red : .secondary)
                    }
                    
                    if let assignedTo = task.assignedTo {
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text("Assigned to \(assignedTo)")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                }
                
                if task.isCompleted, let completedAt = task.completedAt {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption2)
                        Text("Completed \(completedAt, style: .relative)")
                            .font(.caption2)
                    }
                    .foregroundColor(.green)
                }
            }
            .padding(.vertical, 8)
        }
        .padding(.horizontal)
        .background(task.isCompleted ? Color.clear : Color(.systemBackground))
        .cornerRadius(8)
    }
}

#Preview {
    let patient = Patient(
        patientId: "P-001",
        name: "John Doe",
        roomNumber: "302",
        diagnosis: "Post-operative recovery",
        status: .stable
    )
    
    return PatientDetailView(patient: patient)
        .modelContainer(for: [NursingTask.self, Patient.self], inMemory: true)
}
