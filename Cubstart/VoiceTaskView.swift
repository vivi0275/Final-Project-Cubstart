//
//  VoiceTaskView.swift
//  Cubstart
//
//  Created on 18/11/2025.
//

import SwiftUI
import SwiftData
import Combine

struct VoiceTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var speechManager = SpeechRecognitionManager()
    
    @State private var parsedTask: ParsedTask?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Recording indicator
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(speechManager.isRecording ? Color.red.opacity(0.2) : Color.blue.opacity(0.1))
                            .frame(width: 100, height: 100)
                        
                        if speechManager.isRecording {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 70, height: 70)
                        } else {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 35))
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Text(speechManager.isRecording ? "Listening..." : "Ready to record")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 30)
                
                // Transcribed text
                if !speechManager.transcribedText.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Transcribed:")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        ScrollView {
                            Text(speechManager.transcribedText)
                                .font(.body)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                        .frame(maxHeight: 120)
                        
                        // Parsed task preview
                        if let parsed = parsedTask {
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Task Preview:")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text("Title:")
                                            .fontWeight(.semibold)
                                        Text(parsed.title)
                                    }
                                    
                                    if !parsed.description.isEmpty {
                                        HStack(alignment: .top) {
                                            Text("Description:")
                                                .fontWeight(.semibold)
                                            Text(parsed.description)
                                                .lineLimit(2)
                                        }
                                    }
                                    
                                    HStack {
                                        Text("Category:")
                                            .fontWeight(.semibold)
                                        HStack {
                                            Image(systemName: parsed.category.systemImage)
                                                .foregroundColor(Color(parsed.category.color))
                                            Text(parsed.category.rawValue)
                                        }
                                    }
                                    
                                    HStack {
                                        Text("Priority:")
                                            .fontWeight(.semibold)
                                        HStack {
                                            Image(systemName: parsed.priority.systemImage)
                                                .foregroundColor(Color(parsed.priority.color))
                                            Text(parsed.priority.rawValue)
                                        }
                                    }
                                    
                                    if let patientId = parsed.patientId {
                                        HStack {
                                            Text("Patient:")
                                                .fontWeight(.semibold)
                                            Text(patientId)
                                        }
                                    }
                                    
                                    if let dueTime = parsed.dueTime {
                                        HStack {
                                            Text("Due:")
                                                .fontWeight(.semibold)
                                            Text(dueTime, style: .time)
                                        }
                                    }
                                }
                                .font(.subheadline)
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Error message
                if let error = speechManager.errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    
                    if !speechManager.isAuthorized {
                        Button(action: {
                            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(settingsUrl)
                            }
                        }) {
                            Text("Open Settings")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 12) {
                    if speechManager.isRecording {
                        Button(action: {
                            speechManager.stopRecording()
                            parseTranscribedText()
                        }) {
                            HStack {
                                Image(systemName: "stop.circle.fill")
                                Text("Stop Recording")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.red)
                            .cornerRadius(12)
                        }
                    } else {
                        Button(action: {
                            speechManager.startRecording()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "mic.fill")
                                Text(speechManager.transcribedText.isEmpty ? "Start Recording" : "Record Again")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(speechManager.isAuthorized ? Color.blue : Color.gray)
                            .cornerRadius(12)
                        }
                        .disabled(!speechManager.isAuthorized)
                        
                        if !speechManager.transcribedText.isEmpty {
                            Button(action: {
                                createTask()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Create Task")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.green)
                                .cornerRadius(12)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle("Voice Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        speechManager.stopRecording()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func parseTranscribedText() {
        guard !speechManager.transcribedText.isEmpty else { return }
        parsedTask = TaskParser.parse(text: speechManager.transcribedText)
    }
    
    private func createTask() {
        guard let parsed = parsedTask else {
            // Create task with transcribed text as title
            let newTask = NursingTask(
                title: speechManager.transcribedText,
                description: "",
                priority: .normal,
                category: .patientCare
            )
            
            modelContext.insert(newTask)
            
            do {
                try modelContext.save()
                Task {
                    await TaskSyncService.shared.syncTaskToFirestore(newTask)
                }
                dismiss()
            } catch {
                print("❌ Error saving task: \(error)")
            }
            return
        }
        
        let newTask = NursingTask(
            title: parsed.title,
            description: parsed.description,
            priority: parsed.priority,
            category: parsed.category,
            patientId: parsed.patientId,
            dueTime: parsed.dueTime
        )
        
        modelContext.insert(newTask)
        
        do {
            try modelContext.save()
            Task {
                await TaskSyncService.shared.syncTaskToFirestore(newTask)
            }
            dismiss()
        } catch {
            print("❌ Error saving task: \(error)")
        }
    }
}

#Preview {
    VoiceTaskView()
        .modelContainer(for: NursingTask.self, inMemory: true)
}

