//
//  PriorityView.swift
//  Flocus
//
//  Created by Yuhaya Lissera on 02/07/26.
//

import SwiftUI
import SwiftData

struct PriorityView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let tasks: [Task]
    
    @State private var selectedCategory: CategoryFilter = .all
    @State private var selectedProgress: ProgressFilter = .active
    
    private var taskFilter: PriorityTaskFilter {
        PriorityTaskFilter(
            tasks: tasks,
            selectedCategory: selectedCategory,
            selectedProgress: selectedProgress
        )
    }

    var body: some View {
        List {
            PriorityFilterSection(
                selectedCategory: $selectedCategory,
                selectedProgress: $selectedProgress
            )

            if taskFilter.filteredTasks.isEmpty {
                ContentUnavailableView(
                    "No Tasks",
                    systemImage: "checklist",
                    description: Text("Tidak ada task yang sesuai dengan filter.")
                )
            } else {
                ForEach(taskFilter.filteredTasks) { task in
                    NavigationLink {
                        EditTaskView(task: task)
                    } label: {
                        PriorityTaskRow(
                            task: task,
                            onDelete: { deleteTask(task) },
                            onArchive: { archiveTask(task) }
                        )
                    }
                }
                .onMove(perform: moveTasks)
            }
        }
        .navigationTitle("Set Priority")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") { dismiss() }
            }
            ToolbarItem(placement: .primaryAction) {
                EditButton()
            }
            ToolbarItem(placement: .topBarTrailing) {
               Menu {
                   Button {
                       exportTasks()
                   } label: {
                       Label("Export", systemImage: "square.and.arrow.up")
                   }
               } label: {
                   Image(systemName: "ellipsis.circle")
               }
           }
        }
    }
}

// MARK: - Actions
private extension PriorityView {
    func deleteTask(_ task: Task) {
        modelContext.delete(task)
    }
    
    func moveTasks(from source: IndexSet, to destination: Int) {
        var reordered = taskFilter.filteredTasks
        reordered.move(fromOffsets: source, toOffset: destination)
        for (idx, t) in reordered.enumerated() {
            t.priorityOrder = idx
        }
    }
    
    func archiveTask(_ task: Task) {
        task.status = .archive
        try? modelContext.save()
    }
    
    func exportTasks() {
        // TODO: Implement export.
    }
}

#Preview("Priority Tasks") {
    let current = Category(name: "Current", color: "blue")
    let alternative = Category(name: "Alternative", color: "green")
    let dream = Category(name: "Dream", color: "yellow")

    NavigationStack {
        PriorityView(tasks: [
            Task(title: "Learn SwiftData", notes: "Model, query, relationship", category: current),
            Task(title: "Build Flocus", notes: "Priority flow", category: alternative),
            Task(title: "Sketch UI", notes: "Explore glass style", category: dream)
        ])
    }
}
