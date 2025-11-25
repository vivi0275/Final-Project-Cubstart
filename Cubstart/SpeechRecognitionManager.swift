//
//  SpeechRecognitionManager.swift
//  Cubstart
//
//  Created on 18/11/2025.
//

import Foundation
import Speech
import AVFoundation
import SwiftUI
internal import Combine

class SpeechRecognitionManager: ObservableObject {
    @Published var isRecording = false
    @Published var transcribedText = ""
    @Published var errorMessage: String?
    @Published var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    init() {
        // Initialize authorization status
        authorizationStatus = SFSpeechRecognizer.authorizationStatus()
        
        // Request authorization if needed
        if authorizationStatus == .notDetermined {
            DispatchQueue.main.async { [weak self] in
                self?.requestAuthorization()
            }
        }
    }
    
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            DispatchQueue.main.async {
                self?.authorizationStatus = authStatus
                switch authStatus {
                case .authorized:
                    print("✅ Speech recognition authorized")
                    self?.errorMessage = nil
                case .denied:
                    self?.errorMessage = "Speech recognition denied. Please enable it in Settings."
                case .restricted:
                    self?.errorMessage = "Speech recognition is restricted on this device."
                case .notDetermined:
                    self?.errorMessage = "Speech recognition authorization pending."
                @unknown default:
                    self?.errorMessage = "Unknown authorization status"
                }
            }
        }
    }
    
    var isAuthorized: Bool {
        return authorizationStatus == .authorized
    }
    
    func startRecording() {
        // Check authorization first
        guard authorizationStatus == .authorized else {
            if authorizationStatus == .notDetermined {
                requestAuthorization()
                errorMessage = "Please authorize speech recognition first."
            } else {
                errorMessage = "Speech recognition not authorized. Please enable it in Settings."
            }
            return
        }
        
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            errorMessage = "Speech recognizer not available"
            return
        }
        
        // Request microphone permission
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                if !granted {
                    self?.errorMessage = "Microphone permission denied. Please enable it in Settings."
                    return
                }
                self?.performStartRecording()
            }
        }
    }
    
    private func performStartRecording() {
        // Ensure we're on main thread for UI updates
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.performStartRecording()
            }
            return
        }
        
        // Stop previous session if any
        stopRecording()
        
        transcribedText = ""
        errorMessage = nil
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            errorMessage = "Audio session setup failed: \(error.localizedDescription)"
            print("❌ [SpeechRecognitionManager] Audio session error: \(error)")
            return
        }
        
        // Create recognition request
        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        self.recognitionRequest = recognitionRequest
        recognitionRequest.shouldReportPartialResults = true
        
        // Get input node - must be done before preparing engine
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        // Ensure audio engine is stopped before modifying taps
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        
        // Remove any existing tap safely (must be done when engine is stopped)
        // Note: removeTap doesn't throw, but will crash if engine is running
        inputNode.removeTap(onBus: 0)
        
        // Install tap - must be done before starting engine
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            guard let self = self, let request = self.recognitionRequest else { return }
            // Append buffer to recognition request
            request.append(buffer)
        }
        
        // Prepare audio engine
        audioEngine.prepare()
        
        // Start audio engine
        do {
            try audioEngine.start()
            isRecording = true
            print("✅ [SpeechRecognitionManager] Audio engine started")
        } catch {
            errorMessage = "Audio engine failed to start: \(error.localizedDescription)"
            print("❌ [SpeechRecognitionManager] Audio engine error: \(error)")
            stopRecording()
            return
        }
        
        // Start recognition task
        guard let speechRecognizer = speechRecognizer else {
            errorMessage = "Speech recognizer not available"
            stopRecording()
            return
        }
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                DispatchQueue.main.async {
                    self.transcribedText = result.bestTranscription.formattedString
                }
                
                // Check if recognition is finished
                if result.isFinal {
                    DispatchQueue.main.async {
                        self.stopRecording()
                    }
                }
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    let nsError = error as NSError
                    if nsError.code != 216 { // Ignore cancellation errors
                        self.errorMessage = error.localizedDescription
                        print("❌ [SpeechRecognitionManager] Recognition error: \(error)")
                    }
                    self.stopRecording()
                }
            }
        }
    }
    
    func stopRecording() {
        // Ensure we're on main thread
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.stopRecording()
            }
            return
        }
        
        // Stop audio engine first
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        
        // Remove tap safely (must be done after stopping engine)
        // Note: removeTap doesn't throw, but will crash if called incorrectly
        audioEngine.inputNode.removeTap(onBus: 0)
        
        // End recognition request
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        // Cancel recognition task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Deactivate audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("⚠️ [SpeechRecognitionManager] Audio session deactivation warning: \(error.localizedDescription)")
        }
        
        isRecording = false
        print("✅ [SpeechRecognitionManager] Recording stopped")
    }
}

