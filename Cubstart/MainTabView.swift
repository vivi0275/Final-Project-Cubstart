//
//  MainTabView.swift
//  Cubstart
//
//  Created on 17/11/2025.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ContentView()
                .tabItem {
                    Label("Tâches", systemImage: "list.bullet")
                }
                .tag(0)
            
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }
                .tag(1)
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: NursingTask.self, inMemory: true)
}

