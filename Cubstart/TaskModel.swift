//
//  TaskModel.swift
//  Cubstart
//
//  Created by victor picart on 17/11/2025.
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
    
    init(
        title: String,
        description: String = "",
        priority: TaskPriority = .normal,
        category: TaskCategory,
        patientId: String? = nil,
        dueTime: Date? = nil
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
    }
    
    func toggleCompletion() {
        isCompleted.toggle()
        completedAt = isCompleted ? Date() : nil
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