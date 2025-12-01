//
//  DoctorMainView.swift
//  Cubstart
//
//  Created on 26/11/2025.
//  Modified on 27/11/2025 - Renamed to Management's Dashboard, converted to page-based navigation
//

import SwiftUI
import SwiftData

struct DoctorMainView: View {
    @Environment(\.selectedProfile) private var selectedProfile
    @State private var showingSettings = false
    @State private var selectedPage: ManagementPage = .timeline
    
    enum ManagementPage: String, CaseIterable {
        case timeline = "Timeline"
        case patients = "Patients"
        case team = "Team"
        
        var systemImage: String {
            switch self {
            case .timeline: return "clock.fill"
            case .patients: return "person.2.fill"
            case .team: return "person.3.fill"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Navigation menu bar
                HStack(spacing: 0) {
                    ForEach(ManagementPage.allCases, id: \.self) { page in
                        Button(action: {
                            withAnimation(.spring(response: 0.3)) {
                                selectedPage = page
                            }
                        }) {
                            VStack(spacing: 6) {
                                Image(systemName: page.systemImage)
                                    .font(.system(size: 20))
                                Text(page.rawValue)
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(selectedPage == page ? .blue : .gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                selectedPage == page ?
                                    Color.blue.opacity(0.1) : Color.clear
                            )
                        }
                    }
                }
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding()
                
                // Content area - shows selected page
                Group {
                    switch selectedPage {
                    case .timeline:
                        DoctorTimelineDashboard()
                    case .patients:
                        DoctorPatientsView()
                    case .team:
                        DoctorTeamView()
                    }
                }
            }
            .navigationTitle("Management's Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            showingSettings = true
                        }) {
                            Label("Settings", systemImage: "gearshape.fill")
                        }
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(selectedProfile: selectedProfile)
            }
        }
    }
}

#Preview {
    DoctorMainView()
        .modelContainer(for: [NursingTask.self, Patient.self], inMemory: true)
}
