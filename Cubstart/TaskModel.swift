//
//  TaskModel.swift
//  Cubstart
//
//  Created by victor picart on 17/11/2025.
//  Modified on 27/11/2025 - Added validation & comments fields
//

import Foundation
import SwiftData

@Model
class NursingTask {
    var id: UUID
    var title: String
    var taskDescription: String
    var isCompleted: Bool
    var priority: TaskPriority
    var category: TaskCategory
    var patientId: String?
    var dueTime: Date?
    var createdAt: Date
    var completedAt: Date?
    
    // Assignment fields
    var assignedTo: String? // Staff ID (e.g., "N-001")
    var assignedBy: String? // Doctor ID (for future use)
    var assignedAt: Date?
    
    // NEW: Validation & Comments fields
    var completedByStaffId: String? // Who completed the task
    var completedNotes: String? // Nurse's notes/comments
    var validatedByDoctor: Bool // Doctor validation status
    var validatedAt: Date? // When doctor validated
    var doctorNotes: String? // Doctor's feedback on completion
    
    init(
        title: String,
        description: String = "",
        priority: TaskPriority = .normal,
        category: TaskCategory,
        patientId: String? = nil,
        dueTime: Date? = nil,
        assignedTo: String? = nil,
        assignedBy: String? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.taskDescription = description
        self.isCompleted = false
        self.priority = priority
        self.category = category
        self.patientId = patientId
        self.dueTime = dueTime
        self.createdAt = Date()
        self.completedAt = nil
        self.assignedTo = assignedTo
        self.assignedBy = assignedBy
        self.assignedAt = assignedTo != nil ? Date() : nil
        
        // Initialize new fields
        self.completedByStaffId = nil
        self.completedNotes = nil
        self.validatedByDoctor = false
        self.validatedAt = nil
        self.doctorNotes = nil
    }
    
    func toggleCompletion() {
        isCompleted.toggle()
        completedAt = isCompleted ? Date() : nil
    }
    
    // Helper method to assign task to staff member
    func assignTo(staffId: String, doctorId: String? = nil) {
        self.assignedTo = staffId
        self.assignedBy = doctorId
        self.assignedAt = Date()
    }
    
    // NEW: Complete task with notes
    func completeWithNotes(staffId: String, notes: String) {
        self.isCompleted = true
        self.completedAt = Date()
        self.completedByStaffId = staffId
        self.completedNotes = notes
    }
    
    // NEW: Doctor validates task
    func validateByDoctor(notes: String? = nil) {
        self.validatedByDoctor = true
        self.validatedAt = Date()
        self.doctorNotes = notes
    }
    
    // Helper method to check if task is overdue
    var isOverdue: Bool {
        guard let dueTime = dueTime, !isCompleted else { return false }
        return dueTime < Date()
    }
    
    // NEW: Check if task needs doctor validation
    var needsValidation: Bool {
        return isCompleted && !validatedByDoctor
    }
    
    // NEW: Status for timeline
    var timelineStatus: TaskTimelineStatus {
        if !isCompleted && !isStarted {
            return .pending
        } else if !isCompleted && isStarted {
            return .inProgress
        } else if isCompleted && !validatedByDoctor {
            return .completed
        } else {
            return .validated
        }
    }
    
    // Helper to check if task is started
    private var isStarted: Bool {
        return assignedTo != nil
    }
}

// NEW: Timeline status enum
enum TaskTimelineStatus: String {
    case pending = "À Faire"
    case inProgress = "En Cours"
    case completed = "Terminée"
    case validated = "Validée"
    
    var color: String {
        switch self {
        case .pending: return "red"
        case .inProgress: return "orange"
        case .completed: return "blue"
        case .validated: return "green"
        }
    }
    
    var systemImage: String {
        switch self {
        case .pending: return "clock.badge.exclamationmark"
        case .inProgress: return "hourglass"
        case .completed: return "checkmark.circle"
        case .validated: return "checkmark.seal.fill"
        }
    }
}

enum TaskPriority: String, CaseIterable, Codable {
    case urgent = "Urgent"
    case important = "Important"
    case normal = "Normal"
    
    var color: String {
        switch self {
        case .urgent: return "red"
        case .important: return "orange"
        case .normal: return "blue"
        }
    }
    
    var systemImage: String {
        switch self {
        case .urgent: return "exclamationmark.triangle.fill"
        case .important: return "exclamationmark.circle.fill"
        case .normal: return "circle.fill"
        }
    }
}

enum TaskCategory: String, CaseIterable, Codable {
    case patientCare = "Patient Care"
    case medication = "Medication"
    case documentation = "Documentation"
    case rounds = "Rounds"
    case emergency = "Emergency"
    case training = "Training"
    case administrative = "Administrative"
    case teamMeeting = "Team Meeting"
    
    var systemImage: String {
        switch self {
        case .patientCare: return "heart.fill"
        case .medication: return "pills.fill"
        case .documentation: return "doc.text.fill"
        case .rounds: return "figure.walk"
        case .emergency: return "cross.fill"
        case .training: return "graduationcap.fill"
        case .administrative: return "folder.fill"
        case .teamMeeting: return "person.3.fill"
        }
    }
    
    var color: String {
        switch self {
        case .patientCare: return "pink"
        case .medication: return "green"
        case .documentation: return "blue"
        case .rounds: return "purple"
        case .emergency: return "red"
        case .training: return "orange"
        case .administrative: return "gray"
        case .teamMeeting: return "cyan"
        }
    }
}
