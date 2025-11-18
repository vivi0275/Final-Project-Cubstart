//
//  CubstartApp.swift
//  Cubstart
//
//  Created by victor picart on 17/11/2025.
//

import SwiftUI
import SwiftData
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("🔥 [AppDelegate] Configuration de Firebase...")
        FirebaseApp.configure()
        
        if FirebaseApp.app() != nil {
            print("✅ [AppDelegate] Firebase configuré avec succès!")
        } else {
            print("❌ [AppDelegate] Erreur: Firebase n'a pas pu être configuré!")
        }
        
        return true
    }
}

@main
struct CubstartApp: App {
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            NursingTask.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.modelContext, sharedModelContainer.mainContext)
                .onAppear {
                    print("🚀 [CubstartApp] Application démarrée, initialisation de la synchronisation Firestore...")
                    
                    // Vérifier que Firebase est initialisé
                    if FirebaseApp.app() == nil {
                        print("❌ [CubstartApp] Firebase n'est pas initialisé! La synchronisation ne fonctionnera pas.")
                        return
                    }
                    
                    print("✅ [CubstartApp] Firebase est initialisé")
                    
                    // Démarrer la synchronisation Firestore au démarrage de l'app
                    let modelContext = sharedModelContainer.mainContext
                    print("🔄 [CubstartApp] Démarrage de l'écoute Firestore...")
                    TaskSyncService.shared.startSyncing(modelContext: modelContext)
                    
                    // Synchroniser toutes les tâches locales vers Firestore au démarrage
                    Task {
                        print("🔄 [CubstartApp] Synchronisation initiale des tâches...")
                        await TaskSyncService.shared.syncAllToFirestore(modelContext: modelContext)
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
