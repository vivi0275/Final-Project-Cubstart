//
//  ProfileSelectionView.swift
//  Cubstart
//
//  Created on 27/11/2025.
//  Profile selection screen
//

import SwiftUI

enum UserProfile: String, Codable {
    case nurse = "nurse"
    case management = "management"
    
    var title: String {
        switch self {
        case .nurse:
            return "Nurse"
        case .management:
            return "Management"
        }
    }
    
    var description: String {
        switch self {
        case .nurse:
            return "Access to Nursing Tasks, Calendar, and Dashboard"
        case .management:
            return "Full access to Doctor's Dashboard and all management features"
        }
    }
    
    var icon: String {
        switch self {
        case .nurse:
            return "person.fill"
        case .management:
            return "stethoscope"
        }
    }
    
    var color: Color {
        switch self {
        case .nurse:
            return .blue
        case .management:
            return .purple
        }
    }
}

// Environment key for sharing profile across views
struct ProfileEnvironmentKey: EnvironmentKey {
    static let defaultValue: Binding<UserProfile?> = .constant(nil)
}

extension EnvironmentValues {
    var selectedProfile: Binding<UserProfile?> {
        get { self[ProfileEnvironmentKey.self] }
        set { self[ProfileEnvironmentKey.self] = newValue }
    }
}

struct ProfileSelectionView: View {
    @Binding var selectedProfile: UserProfile?
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // App Logo/Title
            VStack(spacing: 16) {
                Image(systemName: "cross.case.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Cubstart")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Select your profile to continue")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            }
            .padding(.bottom, 60)
            
            // Profile selection cards
            VStack(spacing: 20) {
                ProfileCard(
                    profile: .nurse,
                    isSelected: false
                )
                .onTapGesture {
                    selectProfile(.nurse)
                }
                
                ProfileCard(
                    profile: .management,
                    isSelected: false
                )
                .onTapGesture {
                    selectProfile(.management)
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Footer
            Text("Select your profile to access the application")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    private func selectProfile(_ profile: UserProfile) {
        selectedProfile = profile
    }
}

struct ProfileCard: View {
    let profile: UserProfile
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 20) {
            // Icon
            ZStack {
                Circle()
                    .fill(profile.color.opacity(0.1))
                    .frame(width: 70, height: 70)
                
                Image(systemName: profile.icon)
                    .font(.system(size: 32))
                    .foregroundColor(profile.color)
            }
            
            // Text content
            VStack(alignment: .leading, spacing: 6) {
                Text(profile.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(profile.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Arrow
            Image(systemName: "chevron.right")
                .font(.title3)
                .foregroundColor(.secondary)
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? profile.color : Color.clear, lineWidth: 2)
        )
    }
}

#Preview {
    ProfileSelectionView(selectedProfile: .constant(nil))
}

