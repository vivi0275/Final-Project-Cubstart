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
                    Label("Tasks", systemImage: "list.bullet")
                }
                .tag(0)
            
            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .tag(1)
            
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }
                .tag(2)
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: NursingTask.self, inMemory: true)
}

