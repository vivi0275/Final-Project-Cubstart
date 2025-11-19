//
//  FirebaseManager.swift
//  Cubstart
//
//  Created on 18/11/2025.
//

import Foundation
import FirebaseCore

class FirebaseManager {
    static let shared = FirebaseManager()
    
    private init() {}
    
    func configure() {
        // Firebase will be configured automatically via GoogleService-Info.plist
        // This method can be used for additional configurations
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }
}

