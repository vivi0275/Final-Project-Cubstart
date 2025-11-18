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
        // Firebase sera configuré automatiquement via GoogleService-Info.plist
        // Cette méthode peut être utilisée pour des configurations supplémentaires
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }
}

