//
//  DoctorTeamView.swift
//  Cubstart
//
//  Created on 26/11/2025.
//

import SwiftUI
import SwiftData

struct DoctorTeamView: View {
    @Query private var tasks: [NursingTask]
    
    @State private var searchText = ""
    @State private var selectedStaff: StaffMember?
    @State private var filterShift: ShiftType?
    
    // Using mock staff data for now
    let staffMembers = StaffMember.mockStaff
    
    var filteredStaff: [StaffMember] {
        var filtered = staffMembers
        
        if !searchText.isEmpty {
            filtered = filtered.filter { staff in
                staff.name.localizedCaseInsensitiveContains(searchText) ||
                staff.staffId.localizedCaseInsensitiveContains(searchText) ||
                staff.department.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let shift = filterShift {
            filtered = filtered.filter { $0.shift == shift }
        }
        
        // Sort by workload (most urgent tasks first)
        return filtered.sorted { staff1, staff2 in
            let stats1 = staff1.workloadStats(from: tasks)
            let stats2 = staff2.workloadStats(from: tasks)
            
            if stats1.urgent != stats2.urgent {
                return stats1.urgent > stats2.urgent
            }
            
            if stats1.overdue != stats2.overdue {
                return stats1.overdue > stats2.overdue
            }
            
            return stats1.active > stats2.active
        }
    }
    
    var teamStats: (totalTasks: Int, activeStaff: Int, avgWorkload: Double) {
        let activeStaff = staffMembers.filter { $0.isActive }.count
        let totalTasks = tasks.filter { $0.assignedTo != nil && !$0.isCompleted }.count
        let avgWorkload = activeStaff > 0 ? Double(totalTasks) / Double(activeStaff) : 0
        
        return (totalTasks, activeStaff, avgWorkload)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Team overview stats
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    TeamStatCard(
                        title: "Active Staff",
                        value: "\(teamStats.activeStaff)",
                        color: .blue,
                        icon: "person.3.fill"
                    )
                    
                    TeamStatCard(
                        title: "Assigned Tasks",
                        value: "\(teamStats.totalTasks)",
                        color: .orange,
                        icon: "list.bullet"
                    )
                    
                    TeamStatCard(
                        title: "Avg. Workload",
                        value: String(format: "%.1f", teamStats.avgWorkload),
                        color: .purple,
                        icon: "chart.bar.fill"
                    )
                    
                    let urgentCount = tasks.filter { $0.priority == .urgent && !$0.isCompleted && $0.assignedTo != nil }.count
                    TeamStatCard(
                        title: "Urgent Tasks",
                        value: "\(urgentCount)",
                        color: .red,
                        icon: "exclamationmark.triangle.fill"
                    )
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 12)
            
            // Shift filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    Button(action: { filterShift = nil }) {
                        Text("All Shifts")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(filterShift == nil ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(filterShift == nil ? .white : .primary)
                            .cornerRadius(16)
                    }
                    
                    ForEach(ShiftType.allCases, id: \.self) { shift in
                        Button(action: {
                            filterShift = filterShift == shift ? nil : shift
                        }) {
                            Text(shift.shortName)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(filterShift == shift ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(filterShift == shift ? .white : .primary)
                                .cornerRadius(16)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 8)
            
            Divider()
            
            // Staff list
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredStaff) { staff in
                        StaffCard(staff: staff, tasks: tasks)
                            .onTapGesture {
                                selectedStaff = staff
                            }
                    }
                }
                .padding()
            }
        }
        .searchable(text: $searchText, prompt: "Search staff...")
        .sheet(item: $selectedStaff) { staff in
            StaffDetailView(staff: staff)
        }
    }
}

struct TeamStatCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.caption)
                
                Spacer()
                
                Text(value)
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
        .frame(width: 110, height: 70)
    }
}

struct StaffCard: View {
    let staff: StaffMember
    let tasks: [NursingTask]
    
    var workloadStats: WorkloadStats {
        staff.workloadStats(from: tasks)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(staff.name)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: staff.role.systemImage)
                                .font(.caption2)
                            Text(staff.role.abbreviation)
                                .font(.caption)
                        }
                        .foregroundColor(.blue)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(staff.staffId)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Workload indicator
                VStack(spacing: 4) {
                    Circle()
                        .fill(Color(workloadStats.workloadLevel.color))
                        .frame(width: 12, height: 12)
                    
                    Text(workloadStats.workloadLevel.description)
                        .font(.caption2)
                        .foregroundColor(Color(workloadStats.workloadLevel.color))
                }
            }
            
            // Department and shift
            HStack(spacing: 12) {
                Label(staff.department, systemImage: "building.2.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Label(staff.shift.shortName, systemImage: "clock.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            // Task statistics
            HStack(spacing: 16) {
                StaffStatItem(
                    icon: "list.bullet",
                    count: workloadStats.totalAssigned,
                    label: "Total",
                    color: .blue
                )
                
                StaffStatItem(
                    icon: "clock.fill",
                    count: workloadStats.active,
                    label: "Active",
                    color: .orange
                )
                
                StaffStatItem(
                    icon: "checkmark.circle.fill",
                    count: workloadStats.completed,
                    label: "Done",
                    color: .green
                )
                
                if workloadStats.urgent > 0 {
                    StaffStatItem(
                        icon: "exclamationmark.triangle.fill",
                        count: workloadStats.urgent,
                        label: "Urgent",
                        color: .red
                    )
                }
                
                if workloadStats.overdue > 0 {
                    StaffStatItem(
                        icon: "clock.badge.exclamationmark.fill",
                        count: workloadStats.overdue,
                        label: "Overdue",
                        color: .red
                    )
                }
            }
            
            // Completion rate bar
            if workloadStats.totalAssigned > 0 {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Completion Rate")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int(workloadStats.completionRate * 100))%")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 6)
                                .cornerRadius(3)
                            
                            Rectangle()
                                .fill(Color.green)
                                .frame(width: geometry.size.width * workloadStats.completionRate, height: 6)
                                .cornerRadius(3)
                        }
                    }
                    .frame(height: 6)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct StaffStatItem: View {
    let icon: String
    let count: Int
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.caption2)
                Text("\(count)")
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
            .foregroundColor(color)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    DoctorTeamView()
        .modelContainer(for: NursingTask.self, inMemory: true)
}
