//
//  DoctorTimelineDashboard.swift
//  Cubstart
//
//  Created on 27/11/2025.
//  FEATURE 1: Timeline/Dashboard Temps Réel
//

import SwiftUI
import SwiftData

struct DoctorTimelineDashboard: View {
    @Query private var tasks: [NursingTask]
    @Query private var patients: [Patient]
    
    @State private var selectedFilter: TimelineFilter = .all
    @State private var selectedPatientId: String?
    @State private var selectedTask: NursingTask?
    
    enum TimelineFilter: String, CaseIterable {
        case all = "All"
        case pending = "Pending"
        case inProgress = "In Progress"
        case completed = "Completed"
        case needsValidation = "Needs Validation"
        
        var icon: String {
            switch self {
            case .all: return "list.bullet"
            case .pending: return "clock.badge.exclamationmark"
            case .inProgress: return "hourglass"
            case .completed: return "checkmark.circle"
            case .needsValidation: return "exclamationmark.circle"
            }
        }
        
        var color: Color {
            switch self {
            case .all: return .blue
            case .pending: return .red
            case .inProgress: return .orange
            case .completed: return .blue
            case .needsValidation: return .purple
            }
        }
    }
    
    var filteredTasks: [NursingTask] {
        var filtered = tasks
        
        // Filter by patient if selected
        if let patientId = selectedPatientId {
            filtered = filtered.filter { $0.patientId == patientId }
        }
        
        // Filter by status
        switch selectedFilter {
        case .all:
            break
        case .pending:
            filtered = filtered.filter { !$0.isCompleted && $0.assignedTo == nil }
        case .inProgress:
            filtered = filtered.filter { !$0.isCompleted && $0.assignedTo != nil }
        case .completed:
            filtered = filtered.filter { $0.isCompleted && $0.validatedByDoctor }
        case .needsValidation:
            filtered = filtered.filter { $0.needsValidation }
        }
        
        // Sort by priority and due date
        return filtered.sorted { task1, task2 in
            if task1.needsValidation != task2.needsValidation {
                return task1.needsValidation
            }
            
            let priority1Value = task1.priority == .urgent ? 3 : task1.priority == .important ? 2 : 1
            let priority2Value = task2.priority == .urgent ? 3 : task2.priority == .important ? 2 : 1
            
            if priority1Value != priority2Value {
                return priority1Value > priority2Value
            }
            
            if let due1 = task1.dueTime, let due2 = task2.dueTime {
                return due1 < due2
            }
            
            return task1.createdAt > task2.createdAt
        }
    }
    
    // Statistics
    var stats: TimelineStats {
        let pending = tasks.filter { !$0.isCompleted && $0.assignedTo == nil }.count
        let inProgress = tasks.filter { !$0.isCompleted && $0.assignedTo != nil }.count
        let completed = tasks.filter { $0.isCompleted }.count
        let needsValidation = tasks.filter { $0.needsValidation }.count
        let urgent = tasks.filter { $0.priority == .urgent && !$0.isCompleted }.count
        let overdue = tasks.filter { $0.isOverdue }.count
        
        return TimelineStats(
            pending: pending,
            inProgress: inProgress,
            completed: completed,
            needsValidation: needsValidation,
            urgent: urgent,
            overdue: overdue
        )
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
            // Quick stats header
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    TimelineStatCard(
                        title: "Pending",
                        count: stats.pending,
                        icon: "clock.badge.exclamationmark",
                        color: .red
                    )
                    
                    TimelineStatCard(
                        title: "In Progress",
                        count: stats.inProgress,
                        icon: "hourglass",
                        color: .orange
                    )
                    
                    TimelineStatCard(
                        title: "Completed",
                        count: stats.completed,
                        icon: "checkmark.circle.fill",
                        color: .green
                    )
                    
                    if stats.needsValidation > 0 {
                        TimelineStatCard(
                            title: "Needs Validation",
                            count: stats.needsValidation,
                            icon: "exclamationmark.circle.fill",
                            color: .purple
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.purple, lineWidth: 2)
                        )
                    }
                    
                    if stats.urgent > 0 {
                        TimelineStatCard(
                            title: "Urgent",
                            count: stats.urgent,
                            icon: "exclamationmark.triangle.fill",
                            color: .red
                        )
                    }
                    
                    if stats.overdue > 0 {
                        TimelineStatCard(
                            title: "Overdue",
                            count: stats.overdue,
                            icon: "clock.badge.xmark",
                            color: .red
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 12)
            
            // Filter tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(TimelineFilter.allCases, id: \.self) { filter in
                        FilterButton(
                            filter: filter,
                            isSelected: selectedFilter == filter,
                            count: getCount(for: filter)
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) {
                                selectedFilter = filter
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            
            // Patient filter
            if !patients.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        Button(action: { selectedPatientId = nil }) {
                            Text("All Patients")
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedPatientId == nil ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(selectedPatientId == nil ? .white : .primary)
                                .cornerRadius(16)
                        }
                        
                        ForEach(patients) { patient in
                            Button(action: { 
                                selectedPatientId = selectedPatientId == patient.patientId ? nil : patient.patientId
                            }) {
                                HStack(spacing: 4) {
                                    Text(patient.name)
                                        .font(.caption)
                                    Text("(\(patient.patientId))")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(selectedPatientId == patient.patientId ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(selectedPatientId == patient.patientId ? .white : .primary)
                                .cornerRadius(16)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
            }
            
            Divider()
            
            // Timeline list
            if filteredTasks.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: getEmptyIcon())
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text(getEmptyMessage())
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredTasks) { task in
                            TimelineTaskCard(task: task)
                                .onTapGesture {
                                    selectedTask = task
                                }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Timeline")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $selectedTask) { task in
            if task.needsValidation {
                DoctorValidationView(task: task)
            } else {
                TaskDetailView(task: task)
            }
        }
        }
        .navigationViewStyle(.stack)
    }
    
    private func getCount(for filter: TimelineFilter) -> Int {
        switch filter {
        case .all:
            return tasks.count
        case .pending:
            return stats.pending
        case .inProgress:
            return stats.inProgress
        case .completed:
            return stats.completed
        case .needsValidation:
            return stats.needsValidation
        }
    }
    
    private func getEmptyIcon() -> String {
        switch selectedFilter {
        case .all:
            return "list.bullet.clipboard"
        case .pending:
            return "checkmark.circle"
        case .inProgress:
            return "hourglass"
        case .completed:
            return "sparkles"
        case .needsValidation:
            return "checkmark.seal"
        }
    }
    
    private func getEmptyMessage() -> String {
        switch selectedFilter {
        case .all:
            return "No tasks at the moment"
        case .pending:
            return "No pending tasks\nAll tasks are assigned!"
        case .inProgress:
            return "No tasks in progress\nEverything is quiet for now"
        case .completed:
            return "No tasks completed today"
        case .needsValidation:
            return "No tasks to validate\nEverything is validated! 🎉"
        }
    }
}

// Supporting structures
struct TimelineStats {
    let pending: Int
    let inProgress: Int
    let completed: Int
    let needsValidation: Int
    let urgent: Int
    let overdue: Int
}

struct TimelineStatCard: View {
    let title: String
    let count: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.caption)
                
                Spacer()
                
                Text("\(count)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(color.opacity(0.1))
        .cornerRadius(12)
        .frame(width: 100, height: 70)
    }
}

struct FilterButton: View {
    let filter: DoctorTimelineDashboard.TimelineFilter
    let isSelected: Bool
    let count: Int
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: filter.icon)
                .font(.caption)
            
            Text(filter.rawValue)
                .font(.caption)
                .fontWeight(.medium)
            
            if count > 0 {
                Text("\(count)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(isSelected ? Color.white.opacity(0.3) : filter.color.opacity(0.2))
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isSelected ? filter.color : Color.gray.opacity(0.2))
        .foregroundColor(isSelected ? .white : .primary)
        .cornerRadius(20)
    }
}

struct TimelineTaskCard: View {
    @Environment(\.modelContext) private var modelContext
    let task: NursingTask
    
    var statusColor: Color {
        Color(task.timelineStatus.color)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Status indicator
            VStack {
                Circle()
                    .fill(statusColor)
                    .frame(width: 12, height: 12)
                
                if !task.isCompleted {
                    Rectangle()
                        .fill(statusColor.opacity(0.3))
                        .frame(width: 2)
                }
            }
            .frame(width: 12)
            
            VStack(alignment: .leading, spacing: 8) {
                // Header
                HStack {
                    Image(systemName: task.category.systemImage)
                        .font(.caption)
                        .foregroundColor(Color(task.category.color))
                    
                    Text(task.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    // Status badge
                    HStack(spacing: 4) {
                        Image(systemName: task.timelineStatus.systemImage)
                            .font(.caption2)
                        Text(task.timelineStatus.rawValue)
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .cornerRadius(8)
                }
                
                // Info row
                HStack(spacing: 12) {
                    if let patientId = task.patientId {
                        Label(patientId, systemImage: "person.fill")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                    
                    if let staffId = task.assignedTo {
                        Label(staffId, systemImage: "stethoscope")
                            .font(.caption2)
                            .foregroundColor(.purple)
                    }
                    
                    if let dueTime = task.dueTime {
                        Label {
                            Text(dueTime, style: .relative)
                        } icon: {
                            Image(systemName: "clock")
                        }
                        .font(.caption2)
                        .foregroundColor(task.isOverdue ? .red : .secondary)
                    }
                    
                    Image(systemName: task.priority.systemImage)
                        .font(.caption2)
                        .foregroundColor(Color(task.priority.color))
                }
                
                // Validation alert if needed
                if task.needsValidation {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.caption)
                        Text("Requires your validation")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.purple)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(6)
                }
                
                // Completion notes preview
                if let notes = task.completedNotes, !notes.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "note.text")
                            .font(.caption2)
                        Text(notes.prefix(50) + (notes.count > 50 ? "..." : ""))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray6))
                    .cornerRadius(6)
                }
            }
            .padding(.vertical, 4)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(task.needsValidation ? Color.purple : Color.clear, lineWidth: 2)
        )
    }
}

#Preview {
    DoctorTimelineDashboard()
        .modelContainer(for: [NursingTask.self, Patient.self], inMemory: true)
}

