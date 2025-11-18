//
//  DashboardView.swift
//  Cubstart
//
//  Created on 17/11/2025.
//

import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    @Query private var tasks: [NursingTask]
    @State private var selectedTimeRange: TimeRange = .week
    @State private var selectedChartType: ChartType = .byCategory
    
    enum TimeRange: String, CaseIterable {
        case day = "Jour"
        case week = "Semaine"
        case month = "Mois"
        case year = "Année"
        
        var days: Int {
            switch self {
            case .day: return 1
            case .week: return 7
            case .month: return 30
            case .year: return 365
            }
        }
    }
    
    enum ChartType: String, CaseIterable {
        case byCategory = "Par catégorie"
        case byPriority = "Par priorité"
        case timeline = "Évolution temporelle"
        case completion = "Taux de complétion"
    }
    
    var filteredTasks: [NursingTask] {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -selectedTimeRange.days, to: endDate) ?? endDate
        
        return tasks.filter { task in
            task.createdAt >= startDate
        }
    }
    
    var tasksByCategory: [(category: TaskCategory, count: Int, completed: Int)] {
        let grouped = Dictionary(grouping: filteredTasks) { $0.category }
        return TaskCategory.allCases.map { category in
            let categoryTasks = grouped[category] ?? []
            return (
                category: category,
                count: categoryTasks.count,
                completed: categoryTasks.filter { $0.isCompleted }.count
            )
        }.filter { $0.count > 0 }
    }
    
    var tasksByPriority: [(priority: TaskPriority, count: Int, completed: Int)] {
        let grouped = Dictionary(grouping: filteredTasks) { $0.priority }
        return TaskPriority.allCases.map { priority in
            let priorityTasks = grouped[priority] ?? []
            return (
                priority: priority,
                count: priorityTasks.count,
                completed: priorityTasks.filter { $0.isCompleted }.count
            )
        }.filter { $0.count > 0 }
    }
    
    var timelineData: [(date: Date, created: Int, completed: Int)] {
        let calendar = Calendar.current
        var data: [Date: (created: Int, completed: Int)] = [:]
        
        for task in filteredTasks {
            let day = calendar.startOfDay(for: task.createdAt)
            data[day, default: (0, 0)].created += 1
            
            if let completedAt = task.completedAt {
                let completedDay = calendar.startOfDay(for: completedAt)
                data[completedDay, default: (0, 0)].completed += 1
            }
        }
        
        return data.sorted { $0.key < $1.key }.map { (date: $0.key, created: $0.value.created, completed: $0.value.completed) }
    }
    
    var completionRate: Double {
        guard !filteredTasks.isEmpty else { return 0 }
        let completed = filteredTasks.filter { $0.isCompleted }.count
        return Double(completed) / Double(filteredTasks.count)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Sélecteurs
                    VStack(spacing: 16) {
                        // Sélecteur de période
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Période")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Picker("Période", selection: $selectedTimeRange) {
                                ForEach(TimeRange.allCases, id: \.self) { range in
                                    Text(range.rawValue).tag(range)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        
                        // Sélecteur de type de graphique
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Type de graphique")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Picker("Type", selection: $selectedChartType) {
                                ForEach(ChartType.allCases, id: \.self) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Statistiques rapides
                    if !filteredTasks.isEmpty {
                        HStack(spacing: 12) {
                            DashboardStatCard(
                                title: "Total",
                                value: "\(filteredTasks.count)",
                                color: .blue,
                                icon: "list.bullet"
                            )
                            
                            DashboardStatCard(
                                title: "Terminées",
                                value: "\(filteredTasks.filter { $0.isCompleted }.count)",
                                color: .green,
                                icon: "checkmark.circle.fill"
                            )
                            
                            DashboardStatCard(
                                title: "En cours",
                                value: "\(filteredTasks.filter { !$0.isCompleted }.count)",
                                color: .orange,
                                icon: "clock.fill"
                            )
                            
                            DashboardStatCard(
                                title: "Taux",
                                value: "\(Int(completionRate * 100))%",
                                color: .purple,
                                icon: "chart.bar.fill"
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Graphiques
                    if !filteredTasks.isEmpty {
                        VStack(spacing: 20) {
                            switch selectedChartType {
                            case .byCategory:
                                categoryChart
                            case .byPriority:
                                priorityChart
                            case .timeline:
                                timelineChart
                            case .completion:
                                completionChart
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "chart.bar.doc.horizontal")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            
                            Text("Aucune donnée pour cette période")
                                .font(.title3)
                                .foregroundColor(.secondary)
                            
                            Text("Ajoutez des tâches pour voir les statistiques")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 40)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // Graphique par catégorie
    var categoryChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activités par catégorie")
                .font(.headline)
                .padding(.horizontal)
            
            Chart {
                ForEach(tasksByCategory, id: \.category) { item in
                    BarMark(
                        x: .value("Catégorie", item.category.rawValue),
                        y: .value("Nombre", item.count)
                    )
                    .foregroundStyle(Color(item.category.color).opacity(0.7))
                    .annotation(position: .top) {
                        Text("\(item.count)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(height: 250)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            // Légende avec détails
            VStack(alignment: .leading, spacing: 8) {
                ForEach(tasksByCategory, id: \.category) { item in
                    HStack {
                        Image(systemName: item.category.systemImage)
                            .foregroundColor(Color(item.category.color))
                            .frame(width: 20)
                        
                        Text(item.category.rawValue)
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text("\(item.completed)/\(item.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    // Graphique par priorité
    var priorityChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activités par priorité")
                .font(.headline)
                .padding(.horizontal)
            
            Chart {
                ForEach(tasksByPriority, id: \.priority) { item in
                    BarMark(
                        x: .value("Priorité", item.priority.rawValue),
                        y: .value("Nombre", item.count)
                    )
                    .foregroundStyle(Color(item.priority.color).opacity(0.7))
                    .annotation(position: .top) {
                        Text("\(item.count)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(height: 250)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            // Légende
            VStack(alignment: .leading, spacing: 8) {
                ForEach(tasksByPriority, id: \.priority) { item in
                    HStack {
                        Image(systemName: item.priority.systemImage)
                            .foregroundColor(Color(item.priority.color))
                            .frame(width: 20)
                        
                        Text(item.priority.rawValue)
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text("\(item.completed)/\(item.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    // Graphique d'évolution temporelle
    var timelineChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Évolution temporelle")
                .font(.headline)
                .padding(.horizontal)
            
            Chart {
                ForEach(Array(timelineData.enumerated()), id: \.offset) { index, data in
                    LineMark(
                        x: .value("Date", data.date, unit: .day),
                        y: .value("Créées", data.created)
                    )
                    .foregroundStyle(.blue)
                    .interpolationMethod(.catmullRom)
                    
                    LineMark(
                        x: .value("Date", data.date, unit: .day),
                        y: .value("Terminées", data.completed)
                    )
                    .foregroundStyle(.green)
                    .interpolationMethod(.catmullRom)
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: max(1, selectedTimeRange.days / 5))) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month().day(), centered: true)
                }
            }
            .frame(height: 250)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            // Légende
            HStack(spacing: 20) {
                HStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                    Text("Créées")
                        .font(.caption)
                }
                
                HStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text("Terminées")
                        .font(.caption)
                }
            }
            .padding(.horizontal)
        }
    }
    
    // Graphique de taux de complétion
    var completionChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Taux de complétion")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 20) {
                // Graphique circulaire
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                    
                    Circle()
                        .trim(from: 0, to: completionRate)
                        .stroke(
                            Color.green,
                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 1.0), value: completionRate)
                    
                    VStack {
                        Text("\(Int(completionRate * 100))%")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.green)
                        
                        Text("complétées")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 200, height: 200)
                
                // Détails
                VStack(spacing: 12) {
                    HStack {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 12, height: 12)
                        Text("Terminées: \(filteredTasks.filter { $0.isCompleted }.count)")
                            .font(.subheadline)
                        Spacer()
                    }
                    
                    HStack {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 12, height: 12)
                        Text("En cours: \(filteredTasks.filter { !$0.isCompleted }.count)")
                            .font(.subheadline)
                        Spacer()
                    }
                }
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
}

struct DashboardStatCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: NursingTask.self, inMemory: true)
}

