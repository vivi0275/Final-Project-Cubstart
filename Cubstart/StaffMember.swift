//
//  StaffMember.swift
//  Cubstart
//
//  Created on 26/11/2025.
//

import Foundation

struct StaffMember: Identifiable, Codable {
    let id: UUID
    let staffId: String // e.g., "N-001", "N-123"
    let name: String
    let role: StaffRole
    let department: String
    let shift: ShiftType
    let isActive: Bool
    
    init(
        staffId: String,
        name: String,
        role: StaffRole,
        department: String = "General",
        shift: ShiftType = .day,
        isActive: Bool = true
    ) {
        self.id = UUID()
        self.staffId = staffId
        self.name = name
        self.role = role
        self.department = department
        self.shift = shift
        self.isActive = isActive
    }
    
    // Helper method to get workload statistics
    func workloadStats(from tasks: [NursingTask]) -> WorkloadStats {
        let assignedTasks = tasks.filter { $0.assignedTo == self.staffId }
        let activeTasks = assignedTasks.filter { !$0.isCompleted }
        let completedTasks = assignedTasks.filter { $0.isCompleted }
        let urgentTasks = activeTasks.filter { $0.priority == .urgent }
        let overdueTasks = activeTasks.filter { 
            if let dueTime = $0.dueTime {
                return dueTime < Date()
            }
            return false
        }
        
        return WorkloadStats(
            totalAssigned: assignedTasks.count,
            active: activeTasks.count,
            completed: completedTasks.count,
            urgent: urgentTasks.count,
            overdue: overdueTasks.count
        )
    }
}

struct WorkloadStats {
    let totalAssigned: Int
    let active: Int
    let completed: Int
    let urgent: Int
    let overdue: Int
    
    var completionRate: Double {
        guard totalAssigned > 0 else { return 0 }
        return Double(completed) / Double(totalAssigned)
    }
    
    var workloadLevel: WorkloadLevel {
        if overdue > 3 || urgent > 5 {
            return .overloaded
        } else if active > 10 {
            return .heavy
        } else if active > 5 {
            return .moderate
        } else {
            return .light
        }
    }
}

enum WorkloadLevel {
    case light
    case moderate
    case heavy
    case overloaded
    
    var color: String {
        switch self {
        case .light: return "green"
        case .moderate: return "blue"
        case .heavy: return "orange"
        case .overloaded: return "red"
        }
    }
    
    var description: String {
        switch self {
        case .light: return "Light"
        case .moderate: return "Moderate"
        case .heavy: return "Heavy"
        case .overloaded: return "Overloaded"
        }
    }
}

enum StaffRole: String, Codable, CaseIterable {
    case registeredNurse = "Registered Nurse"
    case practicalNurse = "Practical Nurse"
    case nurseAssistant = "Nurse Assistant"
    case headNurse = "Head Nurse"
    
    var abbreviation: String {
        switch self {
        case .registeredNurse: return "RN"
        case .practicalNurse: return "LPN"
        case .nurseAssistant: return "NA"
        case .headNurse: return "HN"
        }
    }
    
    var systemImage: String {
        switch self {
        case .registeredNurse: return "stethoscope"
        case .practicalNurse: return "cross.case.fill"
        case .nurseAssistant: return "person.fill.checkmark"
        case .headNurse: return "star.fill"
        }
    }
}

enum ShiftType: String, Codable, CaseIterable {
    case day = "Day (7AM-3PM)"
    case evening = "Evening (3PM-11PM)"
    case night = "Night (11PM-7AM)"
    
    var shortName: String {
        switch self {
        case .day: return "Day"
        case .evening: return "Evening"
        case .night: return "Night"
        }
    }
}

// Mock data for development (will be replaced with real data after authentication)
extension StaffMember {
    static let mockStaff: [StaffMember] = [
        StaffMember(staffId: "N-001", name: "Sarah Johnson", role: .registeredNurse, department: "ICU", shift: .day),
        StaffMember(staffId: "N-002", name: "Michael Chen", role: .registeredNurse, department: "Emergency", shift: .evening),
        StaffMember(staffId: "N-003", name: "Emily Rodriguez", role: .practicalNurse, department: "General", shift: .day),
        StaffMember(staffId: "N-004", name: "James Wilson", role: .headNurse, department: "ICU", shift: .day),
        StaffMember(staffId: "N-005", name: "Lisa Anderson", role: .nurseAssistant, department: "Pediatrics", shift: .night),
        StaffMember(staffId: "N-006", name: "David Martinez", role: .registeredNurse, department: "Surgery", shift: .evening),
        StaffMember(staffId: "N-007", name: "Jennifer Lee", role: .practicalNurse, department: "General", shift: .night),
        StaffMember(staffId: "N-008", name: "Robert Taylor", role: .registeredNurse, department: "Emergency", shift: .day)
    ]
}
