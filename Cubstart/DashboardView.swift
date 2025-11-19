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
    
    enum TimeRange: String, CaseIterable {
        case day = "Day"
        case week = "Week"
        case month = "Month"
        case year = "Year"
        
        var days: Int {
            switch self {
            case .day: return 1
            case .week: return 7
            case .month: return 30
            case .year: return 365
            }
        }
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
                    // Time range selector
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Period")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Picker("Period", selection: $selectedTimeRange) {
                            ForEach(TimeRange.allCases, id: \.self) { range in
                                Text(range.rawValue).tag(range)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.horizontal)
                    
                    // All charts displayed vertically
                    if !filteredTasks.isEmpty {
                        VStack(spacing: 32) {
                            categoryChart
                            priorityChart
                            timelineChart
                            completionChart
                        }
                        .padding(.horizontal)
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "chart.bar.doc.horizontal")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            
                            Text("No data for this period")
                                .font(.title3)
                                .foregroundColor(.secondary)
                            
                            Text("Add tasks to see statistics")
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
    
    // Category chart
    var categoryChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activities by Category")
                .font(.headline)
                .padding(.horizontal)
            
            Chart {
                ForEach(tasksByCategory, id: \.category) { item in
                    BarMark(
                        x: .value("Category", item.category.rawValue),
                        y: .value("Count", item.count)
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
            
            // Legend with details
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
    
    // Priority chart
    var priorityChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activities by Priority")
                .font(.headline)
                .padding(.horizontal)
            
            Chart {
                ForEach(tasksByPriority, id: \.priority) { item in
                    BarMark(
                        x: .value("Priority", item.priority.rawValue),
                        y: .value("Count", item.count)
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
            
            // Legend
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
    
    // Timeline chart
    var timelineChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Timeline")
                .font(.headline)
                .padding(.horizontal)
            
            Chart {
                ForEach(Array(timelineData.enumerated()), id: \.offset) { index, data in
                    LineMark(
                        x: .value("Date", data.date, unit: .day),
                        y: .value("Created", data.created)
                    )
                    .foregroundStyle(.blue)
                    .interpolationMethod(.catmullRom)
                    
                    LineMark(
                        x: .value("Date", data.date, unit: .day),
                        y: .value("Completed", data.completed)
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
            
            // Legend
            HStack(spacing: 20) {
                HStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                    Text("Created")
                        .font(.caption)
                }
                
                HStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text("Completed")
                        .font(.caption)
                }
            }
            .padding(.horizontal)
        }
    }
    
    // Completion rate chart
    var completionChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Completion Rate")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 20) {
                // Circular chart
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
                        
                        Text("completed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 200, height: 200)
                
                // Details
                VStack(spacing: 12) {
                    HStack {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 12, height: 12)
                        Text("Completed: \(filteredTasks.filter { $0.isCompleted }.count)")
                            .font(.subheadline)
                        Spacer()
                    }
                    
                    HStack {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 12, height: 12)
                        Text("In Progress: \(filteredTasks.filter { !$0.isCompleted }.count)")
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

#Preview {
    DashboardView()
        .modelContainer(for: NursingTask.self, inMemory: true)
}

