//
//  MainTabView.swift
//  Cubstart
//
//  Created on 17/11/2025.
//  Modified on 26/11/2025 - Added Doctor tab
//  Modified on 27/11/2025 - Added profile-based navigation
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @Binding var selectedProfile: UserProfile?
    @State private var selectedTab = 0
    
    var body: some View {
        if let profile = selectedProfile {
            switch profile {
            case .nurse:
                NurseTabView(selectedTab: $selectedTab, selectedProfile: $selectedProfile)
            case .management:
                ManagementTabView(selectedTab: $selectedTab, selectedProfile: $selectedProfile)
            }
        } else {
            // Fallback - should not happen if ProfileSelectionView works correctly
            ProfileSelectionView(selectedProfile: $selectedProfile)
        }
    }
}

// Nurse profile - Access to Tasks, Calendar, and Dashboard
struct NurseTabView: View {
    @Binding var selectedTab: Int
    @Binding var selectedProfile: UserProfile?
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ContentView()
                .environment(\.selectedProfile, $selectedProfile)
                .tabItem {
                    Label("Tasks", systemImage: "list.bullet")
                }
                .tag(0)
            
            CalendarView()
                .environment(\.selectedProfile, $selectedProfile)
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .tag(1)
            
            DashboardView()
                .environment(\.selectedProfile, $selectedProfile)
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }
                .tag(2)
        }
    }
}

// Management profile - Full access to Management's Dashboard
struct ManagementTabView: View {
    @Binding var selectedTab: Int
    @Binding var selectedProfile: UserProfile?
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DoctorTimelineDashboard()
                .environment(\.selectedProfile, $selectedProfile)
                .tabItem {
                    Label("Timeline", systemImage: "clock.fill")
                }
                .tag(0)
            
            DoctorPatientsView()
                .environment(\.selectedProfile, $selectedProfile)
                .tabItem {
                    Label("Patients", systemImage: "person.2.fill")
                }
                .tag(1)
            
            DoctorTeamView()
                .environment(\.selectedProfile, $selectedProfile)
                .tabItem {
                    Label("Team", systemImage: "person.3.fill")
                }
                .tag(2)
        }
    }
}

#Preview {
    MainTabView(selectedProfile: .constant(.nurse))
        .modelContainer(for: [NursingTask.self, Patient.self], inMemory: true)
}
