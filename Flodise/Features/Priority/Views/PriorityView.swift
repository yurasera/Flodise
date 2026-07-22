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
        NavigationStack {
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
                        PriorityTaskRow(
                            task: task,
                            onDelete: { deleteTask(task) },
                            onArchive: { archiveTask(task) }
                        )
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
}

#Preview("Priority Tasks") {
    let learn = Category(name: "Learn", color: "blue")
    let projects = Category(name: "Projects", color: "green")
    let hobbies = Category(name: "Hobbies", color: "yellow")

    PriorityView(tasks: [
        Task(title: "Learn SwiftData", notes: "Model, query, relationship", category: learn),
        Task(title: "Build Flocus", notes: "Priority flow", category: projects),
        Task(title: "Sketch UI", notes: "Explore glass style", category: hobbies)
    ])
}
