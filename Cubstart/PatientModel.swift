//
//  PatientModel.swift
//  Cubstart
//
//  Created on 26/11/2025.
//

import Foundation
import SwiftData

@Model
class Patient {
    var id: UUID
    var patientId: String // e.g., "P-001", "P-123"
    var name: String
    var roomNumber: String?
    var diagnosis: String?
    var admissionDate: Date
    var status: PatientStatus
    var notes: String
    var assignedDoctor: String?
    
    init(
        patientId: String,
        name: String,
        roomNumber: String? = nil,
        diagnosis: String? = nil,
        admissionDate: Date = Date(),
        status: PatientStatus = .stable,
        notes: String = "",
        assignedDoctor: String? = nil
    ) {
        self.id = UUID()
        self.patientId = patientId
        self.name = name
        self.roomNumber = roomNumber
        self.diagnosis = diagnosis
        self.admissionDate = admissionDate
        self.status = status
        self.notes = notes
        self.assignedDoctor = assignedDoctor
    }
    
    // Helper method to get all tasks for this patient
    func taskCount(from tasks: [NursingTask]) -> (total: Int, active: Int, urgent: Int) {
        let patientTasks = tasks.filter { $0.patientId == self.patientId }
        let activeTasks = patientTasks.filter { !$0.isCompleted }
        let urgentTasks = activeTasks.filter { $0.priority == .urgent }
        
        return (patientTasks.count, activeTasks.count, urgentTasks.count)
    }
}

enum PatientStatus: String, CaseIterable, Codable {
    case critical = "Critical"
    case serious = "Serious"
    case stable = "Stable"
    case recovering = "Recovering"
    case discharged = "Discharged"
    
    var color: String {
        switch self {
        case .critical: return "red"
        case .serious: return "orange"
        case .stable: return "green"
        case .recovering: return "blue"
        case .discharged: return "gray"
        }
    }
    
    var systemImage: String {
        switch self {
        case .critical: return "exclamationmark.triangle.fill"
        case .serious: return "exclamationmark.circle.fill"
        case .stable: return "checkmark.circle.fill"
        case .recovering: return "arrow.up.circle.fill"
        case .discharged: return "checkmark.seal.fill"
        }
    }
}
