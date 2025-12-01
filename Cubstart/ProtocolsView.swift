//
//  ProtocolsView.swift
//  Cubstart
//
//  Created on 27/11/2025.
//  FEATURE 3: Interface de gestion des protocoles
//

import SwiftUI
import SwiftData

struct ProtocolsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [NursingTask]
    @Query private var patients: [Patient]
    
    @State private var selectedCategory: ProtocolCategory?
    @State private var selectedProtocol: ProtocolTemplate?
    @State private var showingProtocolApplication = false
    
    var filteredProtocols: [ProtocolTemplate] {
        if let category = selectedCategory {
            return ProtocolTemplate.allProtocols.filter { $0.category == category }
        }
        return ProtocolTemplate.allProtocols
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header info
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Medical Protocols")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("\(ProtocolTemplate.allProtocols.count) predefined protocols")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Quick stats
                        VStack(alignment: .trailing, spacing: 4) {
                            HStack(spacing: 4) {
                                Image(systemName: "clock.fill")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                Text("Time saving")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Text("5-10 tasks/click")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                
                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        CategoryFilterButton(
                            category: nil,
                            isSelected: selectedCategory == nil,
                            count: ProtocolTemplate.allProtocols.count
                        )
                        .onTapGesture {
                            withAnimation {
                                selectedCategory = nil
                            }
                        }
                        
                        ForEach(ProtocolCategory.allCases, id: \.self) { category in
                            CategoryFilterButton(
                                category: category,
                                isSelected: selectedCategory == category,
                                count: ProtocolTemplate.allProtocols.filter { $0.category == category }.count
                            )
                            .onTapGesture {
                                withAnimation {
                                    selectedCategory = selectedCategory == category ? nil : category
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 12)
                
                Divider()
                
                // Protocols list
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredProtocols) { proto in
                            ProtocolCard(proto: proto)
                                .onTapGesture {
                                    selectedProtocol = proto
                                    showingProtocolApplication = true
                                }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Protocols")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingProtocolApplication) {
                if let proto = selectedProtocol {
                    ProtocolApplicationView(
                        proto: proto,
                        patients: patients
                    )
                }
            }
        }
    }
}

struct CategoryFilterButton: View {
    let category: ProtocolCategory?
    let isSelected: Bool
    let count: Int
    
    var body: some View {
        HStack(spacing: 6) {
            if let category = category {
                Image(systemName: category.systemImage)
                    .font(.caption)
                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            } else {
                Image(systemName: "square.grid.2x2")
                    .font(.caption)
                Text("All")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            
            Text("\(count)")
                .font(.caption2)
                .fontWeight(.bold)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(isSelected ? Color.white.opacity(0.3) : Color.gray.opacity(0.2))
                .cornerRadius(8)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isSelected ? (category != nil ? Color(category!.color) : Color.blue) : Color.gray.opacity(0.2))
        .foregroundColor(isSelected ? .white : .primary)
        .cornerRadius(20)
    }
}

struct ProtocolCard: View {
    let proto: ProtocolTemplate
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: proto.category.systemImage)
                    .font(.title2)
                    .foregroundColor(Color(proto.category.color))
                    .frame(width: 50, height: 50)
                    .background(Color(proto.category.color).opacity(0.1))
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(proto.name)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 8) {
                        Label(proto.category.rawValue, systemImage: "tag.fill")
                            .font(.caption)
                            .foregroundColor(Color(proto.category.color))
                        
                        Label("\(proto.tasks.count) tasks", systemImage: "list.bullet")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            
            // Description
            Text(proto.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            Divider()
            
            // Quick info
            HStack(spacing: 20) {
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text("Estimated duration")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatDuration(proto.estimatedDuration))
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    Image(systemName: "list.number")
                        .font(.caption)
                        .foregroundColor(.purple)
                    Text("\(proto.tasks.count) steps")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
            }
            
            // Task preview
            VStack(alignment: .leading, spacing: 6) {
                Text("Task preview:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontWeight(.semibold)
                
                ForEach(proto.tasks.prefix(3), id: \.title) { task in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color(task.priority.color))
                            .frame(width: 6, height: 6)
                        
                        Text(task.title)
                            .font(.caption)
                            .lineLimit(1)
                    }
                }
                
                if proto.tasks.count > 3 {
                    Text("+ \(proto.tasks.count - 3) other tasks...")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h\(minutes > 0 ? " \(minutes)min" : "")"
        } else {
            return "\(minutes)min"
        }
    }
}

struct ProtocolApplicationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let proto: ProtocolTemplate
    let patients: [Patient]
    
    @State private var selectedPatientId: String?
    @State private var selectedStaffId: String?
    @State private var adjustPriorities = false
    @State private var selectedTasks: Set<String> = []
    @State private var showingConfirmation = false
    
    let staffMembers = StaffMember.mockStaff
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Protocol info
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: proto.category.systemImage)
                                .font(.largeTitle)
                                .foregroundColor(Color(proto.category.color))
                                .frame(width: 60, height: 60)
                                .background(Color(proto.category.color).opacity(0.1))
                                .cornerRadius(12)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(proto.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text(proto.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack(spacing: 16) {
                            Label("\(proto.tasks.count) tasks", systemImage: "list.bullet")
                                .font(.caption)
                            
                            Label(formatDuration(proto.estimatedDuration), systemImage: "clock.fill")
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Patient selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Patient (Optional)")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if patients.isEmpty {
                            Text("No patients available")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .padding(.horizontal)
                        } else {
                            Menu {
                                Button("No patient") {
                                    selectedPatientId = nil
                                }
                                
                                ForEach(patients) { patient in
                                    Button(action: {
                                        selectedPatientId = patient.patientId
                                    }) {
                                        HStack {
                                            Text("\(patient.name) (\(patient.patientId))")
                                            if selectedPatientId == patient.patientId {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    if let patientId = selectedPatientId,
                                       let patient = patients.first(where: { $0.patientId == patientId }) {
                                        Text("\(patient.name) (\(patient.patientId))")
                                            .foregroundColor(.primary)
                                    } else {
                                        Text("Select a patient")
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Staff assignment
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Assign To (Optional)")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Menu {
                            Button("Unassigned") {
                                selectedStaffId = nil
                            }
                            
                            ForEach(staffMembers.filter { $0.isActive }) { staff in
                                Button(action: {
                                    selectedStaffId = staff.staffId
                                }) {
                                    HStack {
                                        Image(systemName: staff.role.systemImage)
                                        Text("\(staff.name) (\(staff.role.abbreviation))")
                                        if selectedStaffId == staff.staffId {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                if let staffId = selectedStaffId,
                                   let staff = staffMembers.first(where: { $0.staffId == staffId }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: staff.role.systemImage)
                                            .font(.caption)
                                        Text("\(staff.name) (\(staff.role.abbreviation))")
                                    }
                                    .foregroundColor(.primary)
                                } else {
                                    Text("Select a staff member")
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Tasks list
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Protocol Tasks")
                                .font(.headline)
                            
                            Spacer()
                            
                            Text("Select All")
                                .font(.caption)
                                .foregroundColor(.blue)
                                .onTapGesture {
                                    if selectedTasks.count == proto.tasks.count {
                                        selectedTasks.removeAll()
                                    } else {
                                        selectedTasks = Set(proto.tasks.map { $0.title })
                                    }
                                }
                        }
                        .padding(.horizontal)
                        
                        ForEach(proto.tasks, id: \.title) { task in
                            ProtocolTaskRow(
                                task: task,
                                isSelected: selectedTasks.contains(task.title)
                            )
                            .onTapGesture {
                                if selectedTasks.contains(task.title) {
                                    selectedTasks.remove(task.title)
                                } else {
                                    selectedTasks.insert(task.title)
                                }
                            }
                        }
                    }
                    
                    // Apply button
                    Button(action: {
                        showingConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                            Text("Create \(selectedTasks.count) Task\(selectedTasks.count > 1 ? "s" : "")")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedTasks.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(12)
                    }
                    .disabled(selectedTasks.isEmpty)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Apply Protocol")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .confirmationDialog(
                "Create the tasks?",
                isPresented: $showingConfirmation,
                titleVisibility: .visible
            ) {
                Button("Create \(selectedTasks.count) task\(selectedTasks.count > 1 ? "s" : "")") {
                    applyProtocol()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will create \(selectedTasks.count) task\(selectedTasks.count > 1 ? "s" : "") based on the protocol \(proto.name).")
            }
        }
    }
    
    private func applyProtocol() {
        var createdCount = 0
        
        for protocolTask in proto.tasks where selectedTasks.contains(protocolTask.title) {
            let newTask = NursingTask(
                title: protocolTask.title,
                description: protocolTask.description,
                priority: protocolTask.priority,
                category: protocolTask.category,
                patientId: selectedPatientId,
                dueTime: calculateDueTime(for: protocolTask),
                assignedTo: selectedStaffId,
                assignedBy: "Dr. Current" // Will be replaced with real auth
            )
            
            modelContext.insert(newTask)
            createdCount += 1
        }
        
        do {
            try modelContext.save()
            print("✅ Protocol applied: \(createdCount) tasks created")
            
            // Sync all tasks with Firestore
            Task {
                let descriptor = FetchDescriptor<NursingTask>()
                if let allTasks = try? modelContext.fetch(descriptor) {
                    for task in allTasks.suffix(createdCount) {
                        await TaskSyncService.shared.syncTaskToFirestore(task)
                    }
                }
            }
            
            dismiss()
        } catch {
            print("❌ Error applying protocol: \(error)")
        }
    }
    
    private func calculateDueTime(for task: ProtocolTemplate.ProtocolTaskItem) -> Date {
        // Calculate due time based on task order and estimated minutes
        let calendar = Calendar.current
        let now = Date()
        let minutesToAdd = task.estimatedMinutes * task.order
        return calendar.date(byAdding: .minute, value: minutesToAdd, to: now) ?? now
    }
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h\(minutes > 0 ? " \(minutes)min" : "")"
        } else {
            return "\(minutes)min"
        }
    }
}

struct ProtocolTaskRow: View {
    let task: ProtocolTemplate.ProtocolTaskItem
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Selection indicator
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isSelected ? .blue : .gray)
                .font(.title3)
            
            // Order number
            Text("\(task.order)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Color.blue)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 6) {
                Text(task.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(task.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack(spacing: 12) {
                    Label(task.category.rawValue, systemImage: task.category.systemImage)
                        .font(.caption2)
                        .foregroundColor(Color(task.category.color))
                    
                    Label(task.priority.rawValue, systemImage: task.priority.systemImage)
                        .font(.caption2)
                        .foregroundColor(Color(task.priority.color))
                    
                    Label("~\(task.estimatedMinutes)min", systemImage: "clock")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
        .padding(.horizontal)
    }
}

#Preview {
    ProtocolsView()
        .modelContainer(for: [NursingTask.self, Patient.self, MedicalProtocol.self], inMemory: true)
}
