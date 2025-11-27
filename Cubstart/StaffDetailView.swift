//
//  StaffDetailView.swift
//  Cubstart
//
//  Created on 26/11/2025.
//

import SwiftUI
import SwiftData

struct StaffDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [NursingTask]
    
    let staff: StaffMember
    
    var staffTasks: [NursingTask] {
        tasks.filter { $0.assignedTo == staff.staffId }
            .sorted { task1, task2 in
                if task1.isCompleted != task2.isCompleted {
                    return !task1.isCompleted
                }
                
                let priority1Value = task1.priority == .urgent ? 3 : task1.priority == .important ? 2 : 1
                let priority2Value = task2.priority == .urgent ? 3 : task2.priority == .important ? 2 : 1
                
                if priority1Value != priority2Value {
                    return priority1Value > priority2Value
                }
                
                return task1.createdAt > task2.createdAt
            }
    }
    
    var activeTasks: [NursingTask] {
        staffTasks.filter { !$0.isCompleted }
    }
    
    var completedTasks: [NursingTask] {
        staffTasks.filter { $0.isCompleted }
    }
    
    var workloadStats: WorkloadStats {
        staff.workloadStats(from: tasks)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Staff header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(staff.name)
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                HStack(spacing: 12) {
                                    HStack(spacing: 4) {
                                        Image(systemName: staff.role.systemImage)
                                            .font(.caption)
                                        Text(staff.role.rawValue)
                                            .font(.subheadline)
                                    }
                                    .foregroundColor(.blue)
                                    
                                    Text("•")
                                        .foregroundColor(.secondary)
                                    
                                    Text(staff.staffId)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            // Status indicator
                            VStack(spacing: 4) {
                                Circle()
                                    .fill(staff.isActive ? Color.green : Color.gray)
                                    .frame(width: 16, height: 16)
                                
                                Text(staff.isActive ? "Active" : "Inactive")
                                    .font(.caption2)
                                    .foregroundColor(staff.isActive ? .green : .gray)
                            }
                        }
                        
                        // Department and shift info
                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Department")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .textCase(.uppercase)
                                
                                Label(staff.department, systemImage: "building.2.fill")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Shift")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .textCase(.uppercase)
                                
                                Label(staff.shift.shortName, systemImage: "clock.fill")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    // Workload statistics
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Workload Status")
                                .font(.headline)
                            
                            Spacer()
                            
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color(workloadStats.workloadLevel.color))
                                    .frame(width: 10, height: 10)
                                
                                Text(workloadStats.workloadLevel.description)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(Color(workloadStats.workloadLevel.color))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(workloadStats.workloadLevel.color).opacity(0.1))
                            .cornerRadius(12)
                        }
                        
                        HStack(spacing: 12) {
                            WorkloadStatBox(
                                title: "Assigned",
                                value: "\(workloadStats.totalAssigned)",
                                color: .blue,
                                icon: "list.bullet"
                            )
                            
                            WorkloadStatBox(
                                title: "Active",
                                value: "\(workloadStats.active)",
                                color: .orange,
                                icon: "clock.fill"
                            )
                            
                            WorkloadStatBox(
                                title: "Done",
                                value: "\(workloadStats.completed)",
                                color: .green,
                                icon: "checkmark.circle.fill"
                            )
                        }
                        
                        if workloadStats.urgent > 0 || workloadStats.overdue > 0 {
                            HStack(spacing: 12) {
                                if workloadStats.urgent > 0 {
                                    WorkloadStatBox(
                                        title: "Urgent",
                                        value: "\(workloadStats.urgent)",
                                        color: .red,
                                        icon: "exclamationmark.triangle.fill"
                                    )
                                }
                                
                                if workloadStats.overdue > 0 {
                                    WorkloadStatBox(
                                        title: "Overdue",
                                        value: "\(workloadStats.overdue)",
                                        color: .red,
                                        icon: "clock.badge.exclamationmark.fill"
                                    )
                                }
                                
                                Spacer()
                            }
                        }
                        
                        // Completion rate
                        if workloadStats.totalAssigned > 0 {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Completion Rate")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    Text("\(Int(workloadStats.completionRate * 100))%")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                }
                                
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(height: 12)
                                            .cornerRadius(6)
                                        
                                        Rectangle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [.green.opacity(0.7), .green],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .frame(width: geometry.size.width * workloadStats.completionRate, height: 12)
                                            .cornerRadius(6)
                                    }
                                }
                                .frame(height: 12)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    // Tasks list
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Assigned Tasks")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if staffTasks.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "list.bullet.clipboard")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                
                                Text("No tasks assigned")
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 30)
                        } else {
                            // Active tasks
                            if !activeTasks.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("ACTIVE (\(activeTasks.count))")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.orange)
                                        .padding(.horizontal)
                                    
                                    ForEach(activeTasks) { task in
                                        StaffTaskRow(task: task)
                                    }
                                }
                            }
                            
                            // Completed tasks
                            if !completedTasks.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("COMPLETED (\(completedTasks.count))")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.green)
                                        .padding(.horizontal)
                                        .padding(.top, activeTasks.isEmpty ? 0 : 16)
                                    
                                    ForEach(completedTasks.prefix(5)) { task in
                                        StaffTaskRow(task: task)
                                    }
                                    
                                    if completedTasks.count > 5 {
                                        Text("+ \(completedTasks.count - 5) more completed")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .padding(.horizontal)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Staff Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct WorkloadStatBox: View {
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

struct StaffTaskRow: View {
    let task: NursingTask
    
    var body: some View {
        HStack(spacing: 12) {
            // Category icon
            Image(systemName: task.category.systemImage)
                .font(.body)
                .foregroundColor(Color(task.category.color))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .strikethrough(task.isCompleted)
                
                HStack(spacing: 8) {
                    if let patientId = task.patientId {
                        Text(patientId)
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                    
                    if let dueTime = task.dueTime {
                        Text("•")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text(dueTime, style: .relative)
                            .font(.caption2)
                            .foregroundColor(task.isOverdue ? .red : .secondary)
                    }
                }
            }
            
            Spacer()
            
            if !task.isCompleted {
                Image(systemName: task.priority.systemImage)
                    .font(.caption)
                    .foregroundColor(Color(task.priority.color))
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .font(.body)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    let staff = StaffMember.mockStaff[0]
    
    return StaffDetailView(staff: staff)
        .modelContainer(for: NursingTask.self, inMemory: true)
}
