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
import Combine

class SpeechRecognitionManager: ObservableObject {
    @Published var isRecording = false
    @Published var transcribedText = ""
    @Published var errorMessage: String?
    @Published var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine: AVAudioEngine?
    
    init() {
        authorizationStatus = SFSpeechRecognizer.authorizationStatus()
        
        if authorizationStatus == .notDetermined {
            requestAuthorization()
        }
    }
    
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            DispatchQueue.main.async {
                self?.authorizationStatus = authStatus
                switch authStatus {
                case .authorized:
                    print("✅ Speech recognition authorized")
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
        // Check authorization
        guard authorizationStatus == .authorized else {
            if authorizationStatus == .notDetermined {
                requestAuthorization()
            }
            errorMessage = "Speech recognition not authorized. Please enable it in Settings."
            return
        }
        
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            errorMessage = "Speech recognizer not available"
            return
        }
        
        // Request microphone permission
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { [weak self] granted in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    if !granted {
                        self.errorMessage = "Microphone permission denied. Please enable it in Settings."
                        return
                    }
                    self.performStartRecording()
                }
            }
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    if !granted {
                        self.errorMessage = "Microphone permission denied. Please enable it in Settings."
                        return
                    }
                    self.performStartRecording()
                }
            }
        }
    }
    
    private func performStartRecording() {
        // Stop any existing recording first
        stopRecording()
        
        transcribedText = ""
        errorMessage = nil
        
        // Configure audio session first
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            errorMessage = "Audio session setup failed: \(error.localizedDescription)"
            return
        }
        
        // Create a fresh audio engine instance
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else {
            errorMessage = "Unable to create audio engine"
            return
        }
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            errorMessage = "Unable to create recognition request"
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Get input node
        let inputNode = audioEngine.inputNode
        
        // Get format from input node (must be done before installing tap)
        let nodeFormat = inputNode.outputFormat(forBus: 0)
        
        // Use node format if valid, otherwise create a compatible format
        let recordingFormat: AVAudioFormat
        if nodeFormat.sampleRate > 0 && nodeFormat.channelCount > 0 {
            recordingFormat = nodeFormat
        } else {
            // Fallback to standard format
            guard let fallbackFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 16000, channels: 1, interleaved: false) else {
                errorMessage = "Unable to configure audio format"
                return
            }
            recordingFormat = fallbackFormat
        }
        
        // Install tap with the format
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }
        
        // Start audio engine (prepare is called automatically)
        do {
            try audioEngine.start()
            isRecording = true
        } catch {
            errorMessage = "Audio engine failed to start: \(error.localizedDescription)"
            stopRecording()
            return
        }
        
        // Start recognition
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                DispatchQueue.main.async {
                    self.transcribedText = result.bestTranscription.formattedString
                }
                
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
                    }
                    self.stopRecording()
                }
            }
        }
    }
    
    func stopRecording() {
        // Stop audio engine if running
        if let audioEngine = audioEngine, audioEngine.isRunning {
            audioEngine.stop()
        }
        
        // Remove tap safely
        audioEngine?.inputNode.removeTap(onBus: 0)
        
        // End recognition request
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        // Cancel recognition task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Clean up audio engine - create fresh instance for next use
        audioEngine = nil
        
        // Deactivate audio session
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        
        isRecording = false
    }
}
