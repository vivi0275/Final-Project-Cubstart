//
//  DoctorPatientsView.swift
//  Cubstart
//
//  Created on 26/11/2025.
//

import SwiftUI
import SwiftData

struct DoctorPatientsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var patients: [Patient]
    @Query private var tasks: [NursingTask]
    
    @State private var searchText = ""
    @State private var showingAddPatient = false
    @State private var selectedPatient: Patient?
    @State private var filterStatus: PatientStatus?
    
    var filteredPatients: [Patient] {
        var filtered = patients
        
        if !searchText.isEmpty {
            filtered = filtered.filter { patient in
                patient.name.localizedCaseInsensitiveContains(searchText) ||
                patient.patientId.localizedCaseInsensitiveContains(searchText) ||
                (patient.roomNumber?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        if let status = filterStatus {
            filtered = filtered.filter { $0.status == status }
        }
        
        // Sort by status priority and then by name
        return filtered.sorted { p1, p2 in
            let taskCount1 = p1.taskCount(from: tasks)
            let taskCount2 = p2.taskCount(from: tasks)
            
            // Patients with urgent tasks first
            if taskCount1.urgent != taskCount2.urgent {
                return taskCount1.urgent > taskCount2.urgent
            }
            
            // Then by status
            let statusPriority: [PatientStatus: Int] = [
                .critical: 4,
                .serious: 3,
                .stable: 2,
                .recovering: 1,
                .discharged: 0
            ]
            
            let priority1 = statusPriority[p1.status] ?? 0
            let priority2 = statusPriority[p2.status] ?? 0
            
            if priority1 != priority2 {
                return priority1 > priority2
            }
            
            return p1.name < p2.name
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Quick stats
            if !patients.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        PatientStatCard(
                            title: "Total",
                            count: patients.count,
                            color: .blue,
                            icon: "person.2.fill"
                        )
                        
                        PatientStatCard(
                            title: "Critical",
                            count: patients.filter { $0.status == .critical }.count,
                            color: .red,
                            icon: "exclamationmark.triangle.fill"
                        )
                        
                        PatientStatCard(
                            title: "Serious",
                            count: patients.filter { $0.status == .serious }.count,
                            color: .orange,
                            icon: "exclamationmark.circle.fill"
                        )
                        
                        PatientStatCard(
                            title: "Stable",
                            count: patients.filter { $0.status == .stable }.count,
                            color: .green,
                            icon: "checkmark.circle.fill"
                        )
                        
                        let totalUrgentTasks = patients.reduce(0) { sum, patient in
                            sum + patient.taskCount(from: tasks).urgent
                        }
                        
                        PatientStatCard(
                            title: "Urgent Tasks",
                            count: totalUrgentTasks,
                            color: .purple,
                            icon: "bell.badge.fill"
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
            }
            
            // Status filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    Button(action: { filterStatus = nil }) {
                        Text("All")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(filterStatus == nil ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(filterStatus == nil ? .white : .primary)
                            .cornerRadius(16)
                    }
                    
                    ForEach(PatientStatus.allCases, id: \.self) { status in
                        Button(action: { 
                            filterStatus = filterStatus == status ? nil : status
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: status.systemImage)
                                    .font(.caption2)
                                Text(status.rawValue)
                                    .font(.caption)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(filterStatus == status ? Color(status.color) : Color.gray.opacity(0.2))
                            .foregroundColor(filterStatus == status ? .white : .primary)
                            .cornerRadius(16)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            
            Divider()
            
            // Patient list
            if filteredPatients.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: patients.isEmpty ? "person.2.slash" : "magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text(patients.isEmpty ? "No patients registered" : "No patients match filters")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    if patients.isEmpty {
                        Button(action: { showingAddPatient = true }) {
                            Label("Add Patient", systemImage: "plus.circle.fill")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredPatients) { patient in
                            PatientCard(patient: patient, tasks: tasks)
                                .onTapGesture {
                                    selectedPatient = patient
                                }
                        }
                    }
                    .padding()
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search patients...")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddPatient = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
        }
        .sheet(isPresented: $showingAddPatient) {
            AddPatientView()
        }
        .sheet(item: $selectedPatient) { patient in
            PatientDetailView(patient: patient)
        }
    }
}

struct PatientStatCard: View {
    let title: String
    let count: Int
    let color: Color
    let icon: String
    
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
        .frame(width: 90, height: 70)
    }
}

struct PatientCard: View {
    let patient: Patient
    let tasks: [NursingTask]
    
    var taskStats: (total: Int, active: Int, urgent: Int) {
        patient.taskCount(from: tasks)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(patient.name)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 8) {
                        Text(patient.patientId)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if let room = patient.roomNumber {
                            Text("•")
                                .foregroundColor(.secondary)
                            Text("Room \(room)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                // Status badge
                HStack(spacing: 4) {
                    Image(systemName: patient.status.systemImage)
                        .font(.caption)
                    Text(patient.status.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color(patient.status.color).opacity(0.2))
                .foregroundColor(Color(patient.status.color))
                .cornerRadius(12)
            }
            
            // Diagnosis if present
            if let diagnosis = patient.diagnosis {
                Text(diagnosis)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Divider()
            
            // Task summary
            HStack(spacing: 20) {
                TaskSummaryItem(
                    icon: "list.bullet",
                    count: taskStats.total,
                    label: "Total",
                    color: .blue
                )
                
                TaskSummaryItem(
                    icon: "clock.fill",
                    count: taskStats.active,
                    label: "Active",
                    color: .orange
                )
                
                if taskStats.urgent > 0 {
                    TaskSummaryItem(
                        icon: "exclamationmark.triangle.fill",
                        count: taskStats.urgent,
                        label: "Urgent",
                        color: .red
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct TaskSummaryItem: View {
    let icon: String
    let count: Int
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                Text("\(count)")
                    .font(.headline)
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
    DoctorPatientsView()
        .modelContainer(for: [NursingTask.self, Patient.self], inMemory: true)
}
