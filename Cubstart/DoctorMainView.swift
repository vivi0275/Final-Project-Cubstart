//
//  DoctorMainView.swift
//  Cubstart
//
//  Created on 26/11/2025.
//

import SwiftUI
import SwiftData

struct DoctorMainView: View {
    @Query private var tasks: [NursingTask]
    @Query private var patients: [Patient]
    
    @State private var selectedView: DoctorViewType = .patients
    
    enum DoctorViewType: String, CaseIterable {
        case timeline = "Timeline"     // NOUVEAU
        case patients = "Patients"
        case team = "Team"
        case create = "Create"
        case protocols = "Protocoles"  // NOUVEAU
        
        var systemImage: String {
            switch self {
            case .timeline: return "clock.fill"          // NOUVEAU
            case .patients: return "person.2.fill"
            case .team: return "person.3.fill"
            case .create: return "plus.circle.fill"
            case .protocols: return "list.bullet.clipboard"  // NOUVEAU
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom segment control
                HStack(spacing: 0) {
                    ForEach(DoctorViewType.allCases, id: \.self) { viewType in
                        Button(action: {
                            withAnimation(.spring(response: 0.3)) {
                                selectedView = viewType
                            }
                        }) {
                            VStack(spacing: 6) {
                                Image(systemName: viewType.systemImage)
                                    .font(.system(size: 20))
                                Text(viewType.rawValue)
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(selectedView == viewType ? .blue : .gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                selectedView == viewType ?
                                    Color.blue.opacity(0.1) : Color.clear
                            )
                        }
                    }
                }
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding()
                
                // Content area
                TabView(selection: $selectedView) {
                    DoctorTimelineDashboard()  // NOUVEAU
                        .tag(DoctorViewType.timeline)
                    
                    DoctorPatientsView()
                        .tag(DoctorViewType.patients)
                    
                    DoctorTeamView()
                        .tag(DoctorViewType.team)
                    
                    DoctorCreateTaskView()
                        .tag(DoctorViewType.create)
                    
                    ProtocolsView()  // NOUVEAU
                        .tag(DoctorViewType.protocols)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("Doctor's Dashboard")
            .navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(.stack)
    }
}

#Preview {
    DoctorMainView()
        .modelContainer(for: [NursingTask.self, Patient.self], inMemory: true)
}
