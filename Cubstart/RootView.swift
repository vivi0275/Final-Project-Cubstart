//
//  RootView.swift
//  Cubstart
//
//  Created on 27/11/2025.
//  Root view that handles profile selection and navigation
//

import SwiftUI

struct RootView: View {
    @State private var selectedProfile: UserProfile? = nil
    
    var body: some View {
        Group {
            if let profile = selectedProfile {
                MainTabView(selectedProfile: $selectedProfile)
                    .id(profile.rawValue) // Force view refresh when profile changes
            } else {
                ProfileSelectionView(selectedProfile: $selectedProfile)
            }
        }
    }
}

