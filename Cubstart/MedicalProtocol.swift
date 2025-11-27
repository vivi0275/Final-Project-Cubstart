//
//  MedicalProtocol.swift
//  Cubstart
//
//  Created on 27/11/2025.
//  FEATURE 3: Protocoles Médicaux
//

import Foundation
import SwiftData

@Model
class MedicalProtocol {
    var id: UUID
    var name: String
    var protocolDescription: String
    var category: ProtocolCategory
    var estimatedDuration: TimeInterval // in seconds
    var taskTemplateIds: [String] // Will store template identifiers
    var isActive: Bool
    var createdAt: Date
    var usageCount: Int // Track how many times protocol was used
    
    init(
        name: String,
        description: String,
        category: ProtocolCategory,
        estimatedDuration: TimeInterval,
        taskTemplateIds: [String] = []
    ) {
        self.id = UUID()
        self.name = name
        self.protocolDescription = description
        self.category = category
        self.estimatedDuration = estimatedDuration
        self.taskTemplateIds = taskTemplateIds
        self.isActive = true
        self.createdAt = Date()
        self.usageCount = 0
    }
    
    // Helper to increment usage
    func recordUsage() {
        usageCount += 1
    }
    
    // Helper to get formatted duration
    var formattedDuration: String {
        let hours = Int(estimatedDuration) / 3600
        let minutes = (Int(estimatedDuration) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)min"
        } else {
            return "\(minutes)min"
        }
    }
}

enum ProtocolCategory: String, CaseIterable, Codable {
    case postOperative = "Post-Opératoire"
    case preOperative = "Pré-Opératoire"
    case emergency = "Urgence"
    case routine = "Routine"
    case specialized = "Spécialisé"
    case monitoring = "Surveillance"
    
    var systemImage: String {
        switch self {
        case .postOperative: return "bandage.fill"
        case .preOperative: return "list.clipboard.fill"
        case .emergency: return "cross.fill"
        case .routine: return "clock.fill"
        case .specialized: return "star.fill"
        case .monitoring: return "heart.text.square.fill"
        }
    }
    
    var color: String {
        switch self {
        case .postOperative: return "blue"
        case .preOperative: return "purple"
        case .emergency: return "red"
        case .routine: return "green"
        case .specialized: return "orange"
        case .monitoring: return "cyan"
        }
    }
}

// Pre-built protocol templates
struct ProtocolTemplate: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let category: ProtocolCategory
    let estimatedDuration: TimeInterval
    let tasks: [ProtocolTaskItem]
    
    struct ProtocolTaskItem {
        let title: String
        let description: String
        let category: TaskCategory
        let priority: TaskPriority
        let estimatedMinutes: Int
        let order: Int
    }
}

// Pre-defined medical protocols
extension ProtocolTemplate {
    static let allProtocols: [ProtocolTemplate] = [
        // Post-Operative Protocols
        ProtocolTemplate(
            name: "Post-Op Jour 1",
            description: "Surveillance complète premier jour post-opératoire",
            category: .postOperative,
            estimatedDuration: 8 * 3600, // 8 hours
            tasks: [
                .init(
                    title: "Contrôle signes vitaux (toutes les 2h)",
                    description: "TA, FC, température, SpO2, fréquence respiratoire",
                    category: .patientCare,
                    priority: .urgent,
                    estimatedMinutes: 10,
                    order: 1
                ),
                .init(
                    title: "Vérification perfusion et pansements",
                    description: "Contrôler site IV, surveiller écoulement, vérifier pansements chirurgicaux",
                    category: .patientCare,
                    priority: .important,
                    estimatedMinutes: 15,
                    order: 2
                ),
                .init(
                    title: "Évaluation de la douleur",
                    description: "Échelle EVA, administration analgésiques si nécessaire",
                    category: .patientCare,
                    priority: .important,
                    estimatedMinutes: 5,
                    order: 3
                ),
                .init(
                    title: "Surveillance des drainages",
                    description: "Noter aspect et quantité des drainages",
                    category: .patientCare,
                    priority: .normal,
                    estimatedMinutes: 5,
                    order: 4
                ),
                .init(
                    title: "Mobilisation précoce",
                    description: "Aide au lever si autorisé, kinésithérapie respiratoire",
                    category: .patientCare,
                    priority: .normal,
                    estimatedMinutes: 20,
                    order: 5
                ),
                .init(
                    title: "Documentation médicale",
                    description: "Mise à jour dossier patient, compte-rendu surveillance",
                    category: .documentation,
                    priority: .normal,
                    estimatedMinutes: 15,
                    order: 6
                )
            ]
        ),
        
        // Pre-Operative Protocol
        ProtocolTemplate(
            name: "Préparation Chirurgie",
            description: "Checklist complète pré-opératoire",
            category: .preOperative,
            estimatedDuration: 2 * 3600, // 2 hours
            tasks: [
                .init(
                    title: "Vérification dossier et consentement",
                    description: "Consentement signé, dossier complet, résultats examens disponibles",
                    category: .documentation,
                    priority: .urgent,
                    estimatedMinutes: 10,
                    order: 1
                ),
                .init(
                    title: "Contrôle jeûne pré-opératoire",
                    description: "Confirmer NPO depuis minuit, vérifier hydratation",
                    category: .patientCare,
                    priority: .urgent,
                    estimatedMinutes: 5,
                    order: 2
                ),
                .init(
                    title: "Prémédication",
                    description: "Administration prémédication selon prescription",
                    category: .medication,
                    priority: .important,
                    estimatedMinutes: 10,
                    order: 3
                ),
                .init(
                    title: "Préparation cutanée",
                    description: "Douche antiseptique, rasage si nécessaire",
                    category: .patientCare,
                    priority: .important,
                    estimatedMinutes: 30,
                    order: 4
                ),
                .init(
                    title: "Pose de la voie veineuse",
                    description: "Cathéter périphérique, vérification perméabilité",
                    category: .patientCare,
                    priority: .important,
                    estimatedMinutes: 15,
                    order: 5
                ),
                .init(
                    title: "Checklist pré-anesthésie",
                    description: "Retrait prothèses, bijoux, confirmation identité",
                    category: .patientCare,
                    priority: .urgent,
                    estimatedMinutes: 10,
                    order: 6
                )
            ]
        ),
        
        // Emergency Protocol
        ProtocolTemplate(
            name: "Urgence Cardiaque",
            description: "Protocole douleur thoracique / suspicion IDM",
            category: .emergency,
            estimatedDuration: 1 * 3600, // 1 hour
            tasks: [
                .init(
                    title: "Appel médecin urgence",
                    description: "Alert médecin senior immédiatement",
                    category: .emergency,
                    priority: .urgent,
                    estimatedMinutes: 1,
                    order: 1
                ),
                .init(
                    title: "ECG 12 dérivations",
                    description: "Réaliser ECG dans les 10 minutes",
                    category: .patientCare,
                    priority: .urgent,
                    estimatedMinutes: 10,
                    order: 2
                ),
                .init(
                    title: "Oxygénothérapie",
                    description: "O2 si SpO2 < 94%",
                    category: .patientCare,
                    priority: .urgent,
                    estimatedMinutes: 5,
                    order: 3
                ),
                .init(
                    title: "Voie veineuse périphérique",
                    description: "Pose VVP de gros calibre",
                    category: .patientCare,
                    priority: .urgent,
                    estimatedMinutes: 10,
                    order: 4
                ),
                .init(
                    title: "Bilan sanguin urgence",
                    description: "Troponine, bilan standard",
                    category: .patientCare,
                    priority: .urgent,
                    estimatedMinutes: 15,
                    order: 5
                ),
                .init(
                    title: "Surveillance continue",
                    description: "Scope, PA automatique toutes les 5 min",
                    category: .patientCare,
                    priority: .urgent,
                    estimatedMinutes: 30,
                    order: 6
                )
            ]
        ),
        
        // Routine Protocol
        ProtocolTemplate(
            name: "Soins Quotidiens Standard",
            description: "Routine soins patient hospitalisé",
            category: .routine,
            estimatedDuration: 4 * 3600, // 4 hours
            tasks: [
                .init(
                    title: "Toilette et hygiène",
                    description: "Toilette complète, changement linge",
                    category: .patientCare,
                    priority: .normal,
                    estimatedMinutes: 30,
                    order: 1
                ),
                .init(
                    title: "Signes vitaux matinaux",
                    description: "TA, FC, température, poids si prescrit",
                    category: .patientCare,
                    priority: .normal,
                    estimatedMinutes: 10,
                    order: 2
                ),
                .init(
                    title: "Distribution médicaments",
                    description: "Traitements per os selon prescription",
                    category: .medication,
                    priority: .important,
                    estimatedMinutes: 15,
                    order: 3
                ),
                .init(
                    title: "Évaluation plaies/drainages",
                    description: "Si applicable, soins de plaies",
                    category: .patientCare,
                    priority: .normal,
                    estimatedMinutes: 20,
                    order: 4
                ),
                .init(
                    title: "Aide aux repas",
                    description: "Assistance si nécessaire",
                    category: .patientCare,
                    priority: .normal,
                    estimatedMinutes: 30,
                    order: 5
                ),
                .init(
                    title: "Documentation quotidienne",
                    description: "Mise à jour transmissions",
                    category: .documentation,
                    priority: .normal,
                    estimatedMinutes: 15,
                    order: 6
                )
            ]
        ),
        
        // Specialized Protocol - Chemotherapy
        ProtocolTemplate(
            name: "Administration Chimiothérapie",
            description: "Protocole sécurisé administration chimio",
            category: .specialized,
            estimatedDuration: 6 * 3600, // 6 hours
            tasks: [
                .init(
                    title: "Vérification prescription et identité",
                    description: "Double vérification protocole chimio + identité patient",
                    category: .medication,
                    priority: .urgent,
                    estimatedMinutes: 15,
                    order: 1
                ),
                .init(
                    title: "Bilan pré-chimio",
                    description: "NFS, ionogramme, créatinine (< 72h)",
                    category: .patientCare,
                    priority: .important,
                    estimatedMinutes: 20,
                    order: 2
                ),
                .init(
                    title: "Prémédication anti-émétique",
                    description: "Administration selon protocole (30 min avant)",
                    category: .medication,
                    priority: .important,
                    estimatedMinutes: 10,
                    order: 3
                ),
                .init(
                    title: "Pose voie centrale ou périphérique",
                    description: "Vérification perméabilité, reflux sanguin",
                    category: .patientCare,
                    priority: .important,
                    estimatedMinutes: 20,
                    order: 4
                ),
                .init(
                    title: "Administration chimiothérapie",
                    description: "Selon protocole, avec EPI appropriés",
                    category: .medication,
                    priority: .urgent,
                    estimatedMinutes: 180,
                    order: 5
                ),
                .init(
                    title: "Surveillance post-chimio",
                    description: "Signes vitaux, surveillance effets secondaires (2h)",
                    category: .patientCare,
                    priority: .important,
                    estimatedMinutes: 120,
                    order: 6
                ),
                .init(
                    title: "Documentation et traçabilité",
                    description: "Enregistrement administration, feuille chimio",
                    category: .documentation,
                    priority: .important,
                    estimatedMinutes: 15,
                    order: 7
                )
            ]
        ),
        
        // Monitoring Protocol - ICU
        ProtocolTemplate(
            name: "Surveillance USI",
            description: "Monitoring intensif patient critique",
            category: .monitoring,
            estimatedDuration: 12 * 3600, // 12 hours
            tasks: [
                .init(
                    title: "Signes vitaux horaires",
                    description: "TA invasive, FC, FR, SpO2, température",
                    category: .patientCare,
                    priority: .urgent,
                    estimatedMinutes: 10,
                    order: 1
                ),
                .init(
                    title: "Surveillance neurologique",
                    description: "Score de Glasgow, réactivité pupilles",
                    category: .patientCare,
                    priority: .urgent,
                    estimatedMinutes: 5,
                    order: 2
                ),
                .init(
                    title: "Gestion ventilation mécanique",
                    description: "Vérification paramètres, aspiration si besoin",
                    category: .patientCare,
                    priority: .urgent,
                    estimatedMinutes: 20,
                    order: 3
                ),
                .init(
                    title: "Bilans sanguins",
                    description: "Gaz du sang, ionogramme selon prescription",
                    category: .patientCare,
                    priority: .important,
                    estimatedMinutes: 30,
                    order: 4
                ),
                .init(
                    title: "Gestion perfusions multiples",
                    description: "Vérification débit, changement selon protocole",
                    category: .medication,
                    priority: .important,
                    estimatedMinutes: 30,
                    order: 5
                ),
                .init(
                    title: "Prévention escarres",
                    description: "Changements de position réguliers",
                    category: .patientCare,
                    priority: .normal,
                    estimatedMinutes: 15,
                    order: 6
                ),
                .init(
                    title: "Documentation monitoring",
                    description: "Traçabilité complète sur feuille de surveillance",
                    category: .documentation,
                    priority: .important,
                    estimatedMinutes: 20,
                    order: 7
                )
            ]
        )
    ]
}
