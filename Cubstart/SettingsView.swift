//
//  SettingsView.swift
//  Cubstart
//
//  Created on 27/11/2025.
//  Settings view to change profile
//

import SwiftUI

struct SettingsView: View {
    @Binding var selectedProfile: UserProfile?
    @Environment(\.dismiss) private var dismiss
    @State private var showingProfileChange = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    if let profile = selectedProfile {
                        HStack {
                            Image(systemName: profile.icon)
                                .foregroundColor(profile.color)
                                .frame(width: 30)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Current Profile")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(profile.title)
                                    .font(.headline)
                            }
                            
                            Spacer()
                        }
                    }
                } header: {
                    Text("Profile")
                } footer: {
                    Text("Your profile determines which features you can access in the application.")
                }
                
                Section {
                    Button(action: {
                        showingProfileChange = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .foregroundColor(.blue)
                            Text("Change Profile")
                        }
                    }
                    
                    Button(role: .destructive, action: {
                        selectedProfile = nil
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                            Text("Sign Out")
                        }
                    }
                }
                
                Section {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        Text("App Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingProfileChange) {
                ProfileChangeView(selectedProfile: $selectedProfile)
            }
        }
    }
}

struct ProfileChangeView: View {
    @Binding var selectedProfile: UserProfile?
    @Environment(\.dismiss) private var dismiss
    @State private var tempSelectedProfile: UserProfile?
    
    var currentProfile: UserProfile? {
        selectedProfile
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    Text("Select Profile")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Choose the profile that matches your role")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                // Profile options
                VStack(spacing: 16) {
                    ProfileCard(
                        profile: .nurse,
                        isSelected: tempSelectedProfile == .nurse || (tempSelectedProfile == nil && currentProfile == .nurse)
                    )
                    .onTapGesture {
                        tempSelectedProfile = .nurse
                    }
                    
                    ProfileCard(
                        profile: .management,
                        isSelected: tempSelectedProfile == .management || (tempSelectedProfile == nil && currentProfile == .management)
                    )
                    .onTapGesture {
                        tempSelectedProfile = .management
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Save button
                Button(action: {
                    if let profile = tempSelectedProfile {
                        selectedProfile = profile
                        dismiss()
                    }
                }) {
                    Text("Save Changes")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(tempSelectedProfile != nil ? Color.blue : Color.gray)
                        .cornerRadius(12)
                }
                .disabled(tempSelectedProfile == nil || tempSelectedProfile == currentProfile)
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            tempSelectedProfile = currentProfile
        }
    }
}

#Preview {
    SettingsView(selectedProfile: .constant(.nurse))
}

