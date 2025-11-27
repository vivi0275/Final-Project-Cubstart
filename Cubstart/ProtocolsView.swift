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
                            Text("Protocoles Médicaux")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("\(ProtocolTemplate.allProtocols.count) protocoles prédéfinis")
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
                                Text("Gain de temps")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Text("5-10 tâches/clic")
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
                        ForEach(filteredProtocols) { protocol in
                            ProtocolCard(protocol: protocol)
                                .onTapGesture {
                                    selectedProtocol = protocol
                                    showingProtocolApplication = true
                                }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Protocoles")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingProtocolApplication) {
                if let protocol = selectedProtocol {
                    ProtocolApplicationView(
                        protocol: protocol,
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
                Text("Tous")
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
    let protocol: ProtocolTemplate
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: protocol.category.systemImage)
                    .font(.title2)
                    .foregroundColor(Color(protocol.category.color))
                    .frame(width: 50, height: 50)
                    .background(Color(protocol.category.color).opacity(0.1))
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(protocol.name)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 8) {
                        Label(protocol.category.rawValue, systemImage: "tag.fill")
                            .font(.caption)
                            .foregroundColor(Color(protocol.category.color))
                        
                        Label("\(protocol.tasks.count) tâches", systemImage: "list.bullet")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            
            // Description
            Text(protocol.description)
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
                    Text("Durée estimée")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatDuration(protocol.estimatedDuration))
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    Image(systemName: "list.number")
                        .font(.caption)
                        .foregroundColor(.purple)
                    Text("\(protocol.tasks.count) étapes")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
            }
            
            // Task preview
            VStack(alignment: .leading, spacing: 6) {
                Text("Aperçu des tâches:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontWeight(.semibold)
                
                ForEach(protocol.tasks.prefix(3), id: \.title) { task in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color(task.priority.color))
                            .frame(width: 6, height: 6)
                        
                        Text(task.title)
                            .font(.caption)
                            .lineLimit(1)
                    }
                }
                
                if protocol.tasks.count > 3 {
                    Text("+ \(protocol.tasks.count - 3) autres tâches...")
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
    
    let protocol: ProtocolTemplate
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
                            Image(systemName: protocol.category.systemImage)
                                .font(.largeTitle)
                                .foregroundColor(Color(protocol.category.color))
                                .frame(width: 60, height: 60)
                                .background(Color(protocol.category.color).opacity(0.1))
                                .cornerRadius(12)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(protocol.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text(protocol.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack(spacing: 16) {
                            Label("\(protocol.tasks.count) tâches", systemImage: "list.bullet")
                                .font(.caption)
                            
                            Label(formatDuration(protocol.estimatedDuration), systemImage: "clock.fill")
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
                        Text("Patient (Optionnel)")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if patients.isEmpty {
                            Text("Aucun patient disponible")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .padding(.horizontal)
                        } else {
                            Menu {
                                Button("Aucun patient") {
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
                                        Text("Sélectionner un patient")
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
                        Text("Assigner à (Optionnel)")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Menu {
                            Button("Non assigné") {
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
                                    Text("Sélectionner un membre du personnel")
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
                            Text("Tâches du Protocole")
                                .font(.headline)
                            
                            Spacer()
                            
                            Text("Tout sélectionner")
                                .font(.caption)
                                .foregroundColor(.blue)
                                .onTapGesture {
                                    if selectedTasks.count == protocol.tasks.count {
                                        selectedTasks.removeAll()
                                    } else {
                                        selectedTasks = Set(protocol.tasks.map { $0.title })
                                    }
                                }
                        }
                        .padding(.horizontal)
                        
                        ForEach(protocol.tasks, id: \.title) { task in
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
                            Text("Créer \(selectedTasks.count) Tâche\(selectedTasks.count > 1 ? "s" : "")")
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
            .navigationTitle("Appliquer Protocole")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
            .confirmationDialog(
                "Créer les tâches ?",
                isPresented: $showingConfirmation,
                titleVisibility: .visible
            ) {
                Button("Créer \(selectedTasks.count) tâche\(selectedTasks.count > 1 ? "s" : "")") {
                    applyProtocol()
                }
                Button("Annuler", role: .cancel) {}
            } message: {
                Text("Cela va créer \(selectedTasks.count) tâche\(selectedTasks.count > 1 ? "s" : "") basée\(selectedTasks.count > 1 ? "s" : "") sur le protocole \(protocol.name).")
            }
        }
    }
    
    private func applyProtocol() {
        var createdCount = 0
        
        for protocolTask in protocol.tasks where selectedTasks.contains(protocolTask.title) {
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
