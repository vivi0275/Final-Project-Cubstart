//
//  VoiceTaskView.swift
//  Cubstart
//
//  Created on 18/11/2025.
//

import SwiftUI
import SwiftData

struct VoiceTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var speechManager = SpeechRecognitionManager()
    
    @State private var parsedTask: ParsedTask?
    @State private var showingConfirmation = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Recording indicator
                    VStack(spacing: 16) {
                        Button(action: {
                            if !speechManager.isRecording {
                                speechManager.startRecording()
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(speechManager.isRecording ? Color.red.opacity(0.2) : Color.blue.opacity(0.1))
                                    .frame(width: 120, height: 120)
                                
                                if speechManager.isRecording {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 80, height: 80)
                                        .scaleEffect(speechManager.isRecording ? 1.1 : 1.0)
                                        .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: speechManager.isRecording)
                                } else {
                                    Image(systemName: "mic.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(speechManager.isRecording)
                        
                        Text(speechManager.isRecording ? "Listening..." : "Tap microphone or button to start")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                
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
                        .frame(maxHeight: 150)
                        .onChange(of: speechManager.transcribedText) { oldValue, newValue in
                            if !speechManager.isRecording && !newValue.isEmpty {
                                parseTranscribedText()
                            }
                        }
                        
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
                                                .lineLimit(3)
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
                                            Text(dueTime, style: .date)
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
                        VStack(spacing: 8) {
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
                        .padding(.horizontal)
                    }
                    
                    // Action buttons - Fixed at bottom
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
                                .padding(.vertical, 16)
                                .background(Color.red)
                                .cornerRadius(12)
                            }
                            .buttonStyle(.plain)
                        } else {
                            Button(action: {
                                print("🎤 [VoiceTaskView] Start Recording button tapped")
                                speechManager.startRecording()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "mic.fill")
                                        .font(.title3)
                                    Text(speechManager.transcribedText.isEmpty ? "Start Recording" : "Record Again")
                                        .fontWeight(.semibold)
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(speechManager.isAuthorized ? Color.blue : Color.gray)
                                .cornerRadius(12)
                                .shadow(color: speechManager.isAuthorized ? Color.blue.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
                            }
                            .buttonStyle(.plain)
                            .disabled(!speechManager.isAuthorized)
                            
                            if !speechManager.transcribedText.isEmpty {
                                Button(action: {
                                    createTask()
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.title3)
                                        Text("Create Task")
                                            .fontWeight(.semibold)
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.green)
                                    .cornerRadius(12)
                                    .shadow(color: Color.green.opacity(0.3), radius: 8, x: 0, y: 4)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                    .padding(.top, 20)
                }
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
            // If parsing failed, create task with transcribed text as title
            let newTask = NursingTask(
                title: speechManager.transcribedText,
                description: "",
                priority: .normal,
                category: .patientCare
            )
            
            modelContext.insert(newTask)
            
            do {
                try modelContext.save()
                print("✅ [VoiceTaskView] Task created from voice: \(newTask.title)")
                
                Task {
                    await TaskSyncService.shared.syncTaskToFirestore(newTask)
                }
                
                dismiss()
            } catch {
                print("❌ [VoiceTaskView] Error saving task: \(error)")
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
            print("✅ [VoiceTaskView] Task created from voice: \(newTask.title)")
            
            // Sync with Firestore
            Task {
                await TaskSyncService.shared.syncTaskToFirestore(newTask)
            }
            
            dismiss()
        } catch {
            print("❌ [VoiceTaskView] Error saving task: \(error)")
        }
    }
}

#Preview {
    VoiceTaskView()
        .modelContainer(for: NursingTask.self, inMemory: true)
}

