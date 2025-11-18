//
//  ContentView.swift
//  Cubstart
//
//  Created by victor picart on 17/11/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [NursingTask]
    
    @State private var showingAddTask = false
    @State private var showingQuickActions = false
    @State private var selectedTask: NursingTask?
    @State private var searchText = ""
    @State private var filterCategory: TaskCategory?
    @State private var filterPriority: TaskPriority?
    @State private var showCompletedTasks = true
    
    var filteredTasks: [NursingTask] {
        let filtered = tasks.filter { task in
            let matchesSearch = searchText.isEmpty || 
                task.title.localizedCaseInsensitiveContains(searchText) ||
                task.taskDescription.localizedCaseInsensitiveContains(searchText) ||
                (task.patientId?.localizedCaseInsensitiveContains(searchText) ?? false)
            
            let matchesCategory = filterCategory == nil || task.category == filterCategory
            let matchesPriority = filterPriority == nil || task.priority == filterPriority
            let matchesCompletion = showCompletedTasks || !task.isCompleted
            
            return matchesSearch && matchesCategory && matchesPriority && matchesCompletion
        }
        
        return filtered.sorted { task1, task2 in
            // Tâches non complétées en premier
            if task1.isCompleted != task2.isCompleted {
                return !task1.isCompleted
            }
            
            // Puis par priorité (urgent > important > normal)
            let priority1Value = task1.priority == .urgent ? 3 : task1.priority == .important ? 2 : 1
            let priority2Value = task2.priority == .urgent ? 3 : task2.priority == .important ? 2 : 1
            
            if priority1Value != priority2Value {
                return priority1Value > priority2Value
            }
            
            // Puis par échéance si présente
            if let due1 = task1.dueTime, let due2 = task2.dueTime {
                return due1 < due2
            }
            
            if task1.dueTime != nil && task2.dueTime == nil {
                return true
            }
            
            if task1.dueTime == nil && task2.dueTime != nil {
                return false
            }
            
            // Finalement par date de création
            return task1.createdAt > task2.createdAt
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Statistiques rapides
                if !tasks.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            StatCard(
                                title: "Total",
                                count: tasks.count,
                                color: .blue,
                                systemImage: "list.bullet"
                            )
                            
                            StatCard(
                                title: "En cours",
                                count: tasks.filter { !$0.isCompleted }.count,
                                color: .orange,
                                systemImage: "clock"
                            )
                            
                            StatCard(
                                title: "Terminées",
                                count: tasks.filter { $0.isCompleted }.count,
                                color: .green,
                                systemImage: "checkmark.circle"
                            )
                            
                            StatCard(
                                title: "Urgentes",
                                count: tasks.filter { $0.priority == .urgent && !$0.isCompleted }.count,
                                color: .red,
                                systemImage: "exclamationmark.triangle"
                            )
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
                }
                
                // Filtres
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        // Filtre par catégorie
                        Menu {
                            Button("Toutes les catégories") {
                                filterCategory = nil
                            }
                            
                            ForEach(TaskCategory.allCases, id: \.self) { category in
                                Button(action: {
                                    filterCategory = filterCategory == category ? nil : category
                                }) {
                                    HStack {
                                        Image(systemName: category.systemImage)
                                        Text(category.rawValue)
                                        if filterCategory == category {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                Text(filterCategory?.rawValue ?? "Catégorie")
                            }
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(filterCategory != nil ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                            .cornerRadius(8)
                        }
                        
                        // Filtre par priorité
                        Menu {
                            Button("Toutes les priorités") {
                                filterPriority = nil
                            }
                            
                            ForEach(TaskPriority.allCases, id: \.self) { priority in
                                Button(action: {
                                    filterPriority = filterPriority == priority ? nil : priority
                                }) {
                                    HStack {
                                        Image(systemName: priority.systemImage)
                                        Text(priority.rawValue)
                                        if filterPriority == priority {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "exclamationmark.circle")
                                Text(filterPriority?.rawValue ?? "Priorité")
                            }
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(filterPriority != nil ? Color.orange.opacity(0.2) : Color.gray.opacity(0.2))
                            .cornerRadius(8)
                        }
                        
                        // Toggle tâches complétées
                        Button(action: {
                            showCompletedTasks.toggle()
                        }) {
                            HStack {
                                Image(systemName: showCompletedTasks ? "eye" : "eye.slash")
                                Text("Terminées")
                            }
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(showCompletedTasks ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                            .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                // Liste des tâches
                if filteredTasks.isEmpty {
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Image(systemName: tasks.isEmpty ? "list.bullet.clipboard" : "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text(tasks.isEmpty ? "Aucune tâche pour le moment" : "Aucune tâche ne correspond aux filtres")
                            .font(.title2)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        if tasks.isEmpty {
                            Text("Appuyez sur + pour ajouter votre première tâche")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding()
                    
                    Spacer()
                } else {
                    List {
                        ForEach(filteredTasks, id: \.id) { task in
                            TaskRowView(task: task)
                                .onTapGesture {
                                    selectedTask = task
                                }
                                .swipeActions(edge: .trailing) {
                                    Button("Supprimer", role: .destructive) {
                                        deleteTask(task)
                                    }
                                }
                                .swipeActions(edge: .leading) {
                                    Button(task.isCompleted ? "Réactiver" : "Terminer") {
                                        task.toggleCompletion()
                                        try? modelContext.save()
                                    }
                                    .tint(task.isCompleted ? .orange : .green)
                                }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Tâches Infirmière")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Rechercher une tâche...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            showingAddTask = true
                        }) {
                            Label("Nouvelle tâche", systemImage: "plus.circle")
                        }
                        
                        Button(action: {
                            showingQuickActions = true
                        }) {
                            Label("Actions rapides", systemImage: "bolt.circle")
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button("Marquer toutes comme terminées") {
                            markAllAsCompleted()
                        }
                        
                        Button("Supprimer les tâches terminées", role: .destructive) {
                            deleteCompletedTasks()
                        }
                        
                        Divider()
                        
                        Button("Statistiques") {
                            // TODO: Afficher les statistiques
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView()
            }
            .sheet(isPresented: $showingQuickActions) {
                QuickActionsView()
            }
            .sheet(item: $selectedTask) { task in
                TaskDetailView(task: task)
            }
        }
        .navigationViewStyle(.stack) // Force le style stack pour iOS
    }
    
    private func deleteTask(_ task: NursingTask) {
        withAnimation {
            modelContext.delete(task)
            try? modelContext.save()
        }
    }
    
    private func markAllAsCompleted() {
        withAnimation {
            for task in tasks where !task.isCompleted {
                task.toggleCompletion()
            }
            try? modelContext.save()
        }
    }
    
    private func deleteCompletedTasks() {
        withAnimation {
            let completedTasks = tasks.filter { $0.isCompleted }
            for task in completedTasks {
                modelContext.delete(task)
            }
            try? modelContext.save()
        }
    }
}

struct StatCard: View {
    let title: String
    let count: Int
    let color: Color
    let systemImage: String
    
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Image(systemName: systemImage)
                    .foregroundColor(color)
                    .font(.caption)
                
                Spacer()
                
                Text("\(count)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .padding(12)
        .background(color.opacity(0.1))
        .cornerRadius(12)
        .frame(width: 90, height: 70)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: NursingTask.self, inMemory: true)
}
