//
//  CalendarView.swift
//  Cubstart
//
//  Created on 18/11/2025.
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.selectedProfile) private var selectedProfile
    @Query private var tasks: [NursingTask]
    
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var selectedTask: NursingTask?
    @State private var showingSettings = false
    
    private let calendar = Calendar.current
    
    // Tâches pour la date sélectionnée
    var tasksForSelectedDate: [NursingTask] {
        tasks.filter { task in
            let taskDate = task.dueTime ?? task.createdAt
            return calendar.isDate(taskDate, inSameDayAs: selectedDate)
        }
        .sorted { task1, task2 in
            // Tâches non complétées en premier
            if task1.isCompleted != task2.isCompleted {
                return !task1.isCompleted
            }
            // Puis par priorité
            let priority1Value = task1.priority == .urgent ? 3 : task1.priority == .important ? 2 : 1
            let priority2Value = task2.priority == .urgent ? 3 : task2.priority == .important ? 2 : 1
            if priority1Value != priority2Value {
                return priority1Value > priority2Value
            }
            // Puis par heure si dueTime existe
            if let due1 = task1.dueTime, let due2 = task2.dueTime {
                return due1 < due2
            }
            return task1.createdAt < task2.createdAt
        }
    }
    
    // Tâches groupées par date pour le mois actuel
    var tasksByDate: [Date: [NursingTask]] {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) ?? currentMonth
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) ?? currentMonth
        
        var grouped: [Date: [NursingTask]] = [:]
        
        for task in tasks {
            let taskDate = task.dueTime ?? task.createdAt
            if taskDate >= startOfMonth && taskDate <= endOfMonth {
                let dayStart = calendar.startOfDay(for: taskDate)
                grouped[dayStart, default: []].append(task)
            }
        }
        
        return grouped
    }
    
    // Nombre de tâches pour une date donnée
    func taskCount(for date: Date) -> Int {
        let dayStart = calendar.startOfDay(for: date)
        return tasksByDate[dayStart]?.count ?? 0
    }
    
    // Nombre de tâches non complétées pour une date donnée
    func incompleteTaskCount(for date: Date) -> Int {
        let dayStart = calendar.startOfDay(for: date)
        return tasksByDate[dayStart]?.filter { !$0.isCompleted }.count ?? 0
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // En-tête du calendrier avec navigation
                VStack(spacing: 16) {
                    // Mois et année avec boutons de navigation
                    HStack {
                        Button(action: {
                            withAnimation {
                                currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title3)
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        Text(currentMonth, style: .date)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .textCase(.uppercase)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                            }
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.title3)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Days of the week
                    HStack(spacing: 0) {
                        ForEach(["M", "T", "W", "T", "F", "S", "S"], id: \.self) { day in
                            Text(day)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Grille du calendrier
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                        ForEach(daysInMonth, id: \.self) { date in
                            if let date = date {
                                DayView(
                                    date: date,
                                    isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                                    isToday: calendar.isDateInToday(date),
                                    taskCount: taskCount(for: date),
                                    incompleteTaskCount: incompleteTaskCount(for: date)
                                )
                                .onTapGesture {
                                    withAnimation {
                                        selectedDate = date
                                    }
                                }
                            } else {
                                Color.clear
                                    .frame(height: 44)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
                .background(Color(.systemBackground))
                
                Divider()
                
                // Liste des tâches pour la date sélectionnée
                if tasksForSelectedDate.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No tasks for this date")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        Text("Tasks with a due date or created on this day will appear here")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    Spacer()
                } else {
                    List {
                        Section {
                            ForEach(tasksForSelectedDate, id: \.id) { task in
                                TaskRowView(task: task)
                                    .onTapGesture {
                                        selectedTask = task
                                    }
                                    .swipeActions(edge: .trailing) {
                                        Button("Delete", role: .destructive) {
                                            deleteTask(task)
                                        }
                                    }
                                    .swipeActions(edge: .leading) {
                                        Button(task.isCompleted ? "Reactivate" : "Complete") {
                                            task.toggleCompletion()
                                            try? modelContext.save()
                                            
                                            // Sync with Firestore
                                            Task {
                                                await TaskSyncService.shared.syncTaskToFirestore(task)
                                            }
                                        }
                                        .tint(task.isCompleted ? .orange : .green)
                                    }
                            }
                        } header: {
                            HStack {
                                Image(systemName: "list.bullet")
                                Text("\(tasksForSelectedDate.count) task\(tasksForSelectedDate.count != 1 ? "s" : "")")
                            }
                            .font(.headline)
                            .foregroundColor(.primary)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            .sheet(item: $selectedTask) { task in
                TaskDetailView(task: task)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(selectedProfile: selectedProfile)
            }
        }
        .navigationViewStyle(.stack)
    }
    
    // Jours du mois avec les jours vides au début
    var daysInMonth: [Date?] {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) ?? currentMonth
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        // Ajuster pour que lundi soit le premier jour (weekday 2)
        let offset = (firstWeekday + 5) % 7
        
        let daysInMonth = calendar.range(of: .day, in: .month, for: currentMonth)?.count ?? 0
        
        var days: [Date?] = Array(repeating: nil, count: offset)
        
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func deleteTask(_ task: NursingTask) {
        withAnimation {
            // Delete from Firestore
            Task {
                await TaskSyncService.shared.deleteTaskFromFirestore(task)
            }
            
            modelContext.delete(task)
            try? modelContext.save()
        }
    }
}

// Vue pour un jour du calendrier
struct DayView: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let taskCount: Int
    let incompleteTaskCount: Int
    
    private let calendar = Calendar.current
    
    var dayNumber: Int {
        calendar.component(.day, from: date)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(dayNumber)")
                .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                .foregroundColor(
                    isSelected ? .white :
                    isToday ? .blue :
                    incompleteTaskCount > 0 ? .red :
                    .primary
                )
            
            if taskCount > 0 {
                HStack(spacing: 2) {
                    if incompleteTaskCount > 0 {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 6, height: 6)
                    }
                    if taskCount - incompleteTaskCount > 0 {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 6, height: 6)
                    }
                }
            }
        }
        .frame(width: 44, height: 44)
        .background(
            Group {
                if isSelected {
                    Circle()
                        .fill(Color.blue)
                } else if isToday {
                    Circle()
                        .stroke(Color.blue, lineWidth: 2)
                }
            }
        )
    }
}

#Preview {
    CalendarView()
        .modelContainer(for: NursingTask.self, inMemory: true)
}

