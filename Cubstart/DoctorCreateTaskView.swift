//
//  DoctorCreateTaskView.swift
//  Cubstart
//
//  Created on 26/11/2025.
//

import SwiftUI
import SwiftData

struct DoctorCreateTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var patients: [Patient]
    
    @State private var selectedTemplate: TaskTemplate?
    @State private var title = ""
    @State private var taskDescription = ""
    @State private var selectedPriority: TaskPriority = .normal
    @State private var selectedCategory: TaskCategory = .patientCare
    @State private var selectedPatientId: String?
    @State private var selectedStaffId: String?
    @State private var hasDueTime = false
    @State private var dueTime = Date()
    @State private var showingSuccess = false
    
    let preselectedPatientId: String?
    let staffMembers = StaffMember.mockStaff
    
    init(preselectedPatientId: String? = nil) {
        self.preselectedPatientId = preselectedPatientId
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Templates section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick Templates")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(TaskTemplate.allTemplates) { template in
                                TemplateCard(template: template, isSelected: selectedTemplate?.id == template.id)
                                    .onTapGesture {
                                        applyTemplate(template)
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Divider()
                
                // Task form
                VStack(spacing: 20) {
                    // Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Task Title")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        TextField("Enter task title", text: $title)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(.horizontal)
                    
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description (Optional)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        TextEditor(text: $taskDescription)
                            .frame(height: 100)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    
                    // Patient selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Patient")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        if patients.isEmpty {
                            Text("No patients available")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
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
                                        Text("Select patient")
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
                        }
                    }
                    .padding(.horizontal)
                    
                    // Staff assignment
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Assign To")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
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
                                    Text("Select staff member")
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
                    }
                    .padding(.horizontal)
                    
                    // Category
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(TaskCategory.allCases, id: \.self) { category in
                                    CategoryButton(
                                        category: category,
                                        isSelected: selectedCategory == category
                                    )
                                    .onTapGesture {
                                        selectedCategory = category
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Priority
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Priority")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Picker("Priority", selection: $selectedPriority) {
                            ForEach(TaskPriority.allCases, id: \.self) { priority in
                                HStack {
                                    Image(systemName: priority.systemImage)
                                    Text(priority.rawValue)
                                }
                                .tag(priority)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.horizontal)
                    
                    // Due time
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("Set Due Date & Time", isOn: $hasDueTime)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        if hasDueTime {
                            DatePicker("Due Date", selection: $dueTime, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.compact)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Create button
                    Button(action: createTask) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                            Text("Create & Assign Task")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(title.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(12)
                    }
                    .disabled(title.isEmpty)
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            }
            .padding(.vertical)
        }
        .onAppear {
            if let preselected = preselectedPatientId {
                selectedPatientId = preselected
            }
        }
        .alert("Task Created!", isPresented: $showingSuccess) {
            Button("OK") {
                resetForm()
            }
        } message: {
            Text("The task has been successfully created and assigned.")
        }
    }
    
    private func applyTemplate(_ template: TaskTemplate) {
        selectedTemplate = template
        title = template.title
        taskDescription = template.description
        selectedPriority = template.priority
        selectedCategory = template.category
        
        // Keep patient and staff selection as is
        withAnimation {
            // Visual feedback
        }
    }
    
    private func createTask() {
        let newTask = NursingTask(
            title: title,
            description: taskDescription,
            priority: selectedPriority,
            category: selectedCategory,
            patientId: selectedPatientId,
            dueTime: hasDueTime ? dueTime : nil,
            assignedTo: selectedStaffId,
            assignedBy: "Dr. Current" // Will be replaced with actual doctor ID after authentication
        )
        
        modelContext.insert(newTask)
        
        do {
            try modelContext.save()
            print("✅ Task created and assigned successfully")
            
            // Sync with Firestore
            Task {
                await TaskSyncService.shared.syncTaskToFirestore(newTask)
            }
            
            showingSuccess = true
        } catch {
            print("❌ Error creating task: \(error)")
        }
    }
    
    private func resetForm() {
        title = ""
        taskDescription = ""
        selectedPriority = .normal
        selectedCategory = .patientCare
        selectedPatientId = preselectedPatientId
        selectedStaffId = nil
        hasDueTime = false
        dueTime = Date()
        selectedTemplate = nil
    }
}

struct TemplateCard: View {
    let template: TaskTemplate
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: template.category.systemImage)
                    .font(.title3)
                    .foregroundColor(Color(template.category.color))
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            
            Text(template.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(2)
            
            HStack(spacing: 4) {
                Image(systemName: template.priority.systemImage)
                    .font(.caption2)
                Text(template.priority.rawValue)
                    .font(.caption2)
            }
            .foregroundColor(Color(template.priority.color))
        }
        .padding()
        .frame(width: 140, height: 120)
        .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
}

struct CategoryButton: View {
    let category: TaskCategory
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: category.systemImage)
                .font(.title3)
                .foregroundColor(isSelected ? .white : Color(category.color))
            
            Text(category.rawValue)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(isSelected ? Color(category.color) : Color(.systemGray6))
        .cornerRadius(12)
    }
}

// Task templates for quick creation
struct TaskTemplate: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let category: TaskCategory
    let priority: TaskPriority
    
    static let allTemplates: [TaskTemplate] = [
        TaskTemplate(
            title: "Vital Signs Check",
            description: "Check and record blood pressure, heart rate, temperature, and oxygen saturation",
            category: .patientCare,
            priority: .normal
        ),
        TaskTemplate(
            title: "Medication Administration",
            description: "Administer prescribed medication according to schedule",
            category: .medication,
            priority: .important
        ),
        TaskTemplate(
            title: "IV Check & Change",
            description: "Check IV site for complications and change if necessary",
            category: .patientCare,
            priority: .important
        ),
        TaskTemplate(
            title: "Wound Dressing Change",
            description: "Clean and redress surgical/wound site maintaining sterile technique",
            category: .patientCare,
            priority: .normal
        ),
        TaskTemplate(
            title: "Patient Mobility Assessment",
            description: "Assess patient's ability to move and assist with ambulation if needed",
            category: .rounds,
            priority: .normal
        ),
        TaskTemplate(
            title: "Pre-Op Preparation",
            description: "Prepare patient for scheduled surgery - NPO status, pre-op checklist",
            category: .patientCare,
            priority: .urgent
        ),
        TaskTemplate(
            title: "Post-Op Monitoring",
            description: "Monitor vital signs and recovery progress post-surgery",
            category: .patientCare,
            priority: .urgent
        ),
        TaskTemplate(
            title: "Lab Work Collection",
            description: "Collect blood samples for scheduled lab tests",
            category: .patientCare,
            priority: .important
        ),
        TaskTemplate(
            title: "Patient Education",
            description: "Educate patient on treatment plan and discharge instructions",
            category: .documentation,
            priority: .normal
        ),
        TaskTemplate(
            title: "Discharge Planning",
            description: "Complete discharge paperwork and coordinate follow-up care",
            category: .documentation,
            priority: .important
        )
    ]
}

#Preview {
    DoctorCreateTaskView()
        .modelContainer(for: [NursingTask.self, Patient.self], inMemory: true)
}
