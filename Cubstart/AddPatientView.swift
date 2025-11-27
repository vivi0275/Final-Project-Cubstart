//
//  AddPatientView.swift
//  Cubstart
//
//  Created on 26/11/2025.
//

import SwiftUI
import SwiftData

struct AddPatientView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var patientId = ""
    @State private var name = ""
    @State private var roomNumber = ""
    @State private var diagnosis = ""
    @State private var selectedStatus: PatientStatus = .stable
    @State private var notes = ""
    @State private var assignedDoctor = ""
    @State private var admissionDate = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Patient Information") {
                    TextField("Patient ID (e.g., P-001)", text: $patientId)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.allCharacters)
                    
                    TextField("Full Name", text: $name)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Room Number (optional)", text: $roomNumber)
                        .textFieldStyle(.roundedBorder)
                }
                
                Section("Medical Information") {
                    TextField("Diagnosis (optional)", text: $diagnosis, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...5)
                    
                    Picker("Status", selection: $selectedStatus) {
                        ForEach(PatientStatus.allCases.filter { $0 != .discharged }, id: \.self) { status in
                            HStack {
                                Image(systemName: status.systemImage)
                                    .foregroundColor(Color(status.color))
                                Text(status.rawValue)
                            }
                            .tag(status)
                        }
                    }
                }
                
                Section("Admission Details") {
                    DatePicker("Admission Date", selection: $admissionDate, displayedComponents: [.date])
                    
                    TextField("Attending Physician (optional)", text: $assignedDoctor)
                        .textFieldStyle(.roundedBorder)
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("New Patient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addPatient()
                    }
                    .disabled(patientId.isEmpty || name.isEmpty)
                }
            }
        }
    }
    
    private func addPatient() {
        let newPatient = Patient(
            patientId: patientId.uppercased(),
            name: name,
            roomNumber: roomNumber.isEmpty ? nil : roomNumber,
            diagnosis: diagnosis.isEmpty ? nil : diagnosis,
            admissionDate: admissionDate,
            status: selectedStatus,
            notes: notes,
            assignedDoctor: assignedDoctor.isEmpty ? nil : assignedDoctor
        )
        
        modelContext.insert(newPatient)
        
        do {
            try modelContext.save()
            print("✅ Patient added successfully: \(newPatient.name)")
            dismiss()
        } catch {
            print("❌ Error adding patient: \(error)")
        }
    }
}

struct EditPatientView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let patient: Patient
    
    @State private var name: String
    @State private var roomNumber: String
    @State private var diagnosis: String
    @State private var selectedStatus: PatientStatus
    @State private var notes: String
    @State private var assignedDoctor: String
    
    init(patient: Patient) {
        self.patient = patient
        _name = State(initialValue: patient.name)
        _roomNumber = State(initialValue: patient.roomNumber ?? "")
        _diagnosis = State(initialValue: patient.diagnosis ?? "")
        _selectedStatus = State(initialValue: patient.status)
        _notes = State(initialValue: patient.notes)
        _assignedDoctor = State(initialValue: patient.assignedDoctor ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Patient Information") {
                    HStack {
                        Text("Patient ID")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(patient.patientId)
                            .fontWeight(.medium)
                    }
                    
                    TextField("Full Name", text: $name)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Room Number", text: $roomNumber)
                        .textFieldStyle(.roundedBorder)
                }
                
                Section("Medical Information") {
                    TextField("Diagnosis", text: $diagnosis, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...5)
                    
                    Picker("Status", selection: $selectedStatus) {
                        ForEach(PatientStatus.allCases, id: \.self) { status in
                            HStack {
                                Image(systemName: status.systemImage)
                                    .foregroundColor(Color(status.color))
                                Text(status.rawValue)
                            }
                            .tag(status)
                        }
                    }
                }
                
                Section("Admission Details") {
                    HStack {
                        Text("Admitted")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(patient.admissionDate, style: .date)
                    }
                    
                    TextField("Attending Physician", text: $assignedDoctor)
                        .textFieldStyle(.roundedBorder)
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Edit Patient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveChanges() {
        patient.name = name
        patient.roomNumber = roomNumber.isEmpty ? nil : roomNumber
        patient.diagnosis = diagnosis.isEmpty ? nil : diagnosis
        patient.status = selectedStatus
        patient.notes = notes
        patient.assignedDoctor = assignedDoctor.isEmpty ? nil : assignedDoctor
        
        do {
            try modelContext.save()
            print("✅ Patient updated successfully")
            dismiss()
        } catch {
            print("❌ Error updating patient: \(error)")
        }
    }
}

#Preview {
    AddPatientView()
        .modelContainer(for: Patient.self, inMemory: true)
}
