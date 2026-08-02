//
//  WorkflowView.swift
//  Flodise
//
//  Created by Yuhaya Lissera on 02/07/26.
//

import SwiftUI
import SwiftData

@MainActor
struct WorkflowView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let tasks: [Task]
    
    @State private var selectedCategory: CategoryFilter = .all
    @State private var selectedProgress: ProgressFilter = .active
    @State private var isShowingCopyConfirmation = false
    @State private var copyConfirmationTrigger = 0
    
    private var taskFilter: WorkflowTaskFilter {
        WorkflowTaskFilter(
            tasks: tasks,
            selectedCategory: selectedCategory,
            selectedProgress: selectedProgress
        )
    }

    var body: some View {
        List {
            WorkflowFilterSection(
                tasks: tasks,
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
                        WorkflowTaskRow(
                            task: task,
                            onDelete: { deleteTask(task) },
                            onArchive: { archiveTask(task) }
                        )
                    }
                }
                .onMove(perform: moveTasks)
            }
        }
        .navigationTitle("Set Workflow")
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .bottom) {
            if isShowingCopyConfirmation {
                Label("Copied", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.regularMaterial, in: Capsule())
                    .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
                    .padding(.bottom, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .sensoryFeedback(.success, trigger: copyConfirmationTrigger)
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
                        copyTasks()
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                    .disabled(taskFilter.filteredTasks.isEmpty)

                    NavigationLink {
                        PriorityView(tasks: tasks)
                    } label: {
                        Label("All Task Titles", systemImage: "list.bullet")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
}

// MARK: - Actions
private extension WorkflowView {
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
    
    func copyTasks() {
        TaskClipboardService().copy(taskFilter.filteredTasks)
        showCopyConfirmation()
    }

    func showCopyConfirmation() {
        copyConfirmationTrigger += 1

        withAnimation(.snappy) {
            isShowingCopyConfirmation = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            withAnimation(.snappy) {
                isShowingCopyConfirmation = false
            }
        }
    }
}

#Preview("Workflow Tasks") {
    let current = Category(name: "Current", color: "blue")
    let alternative = Category(name: "Alternative", color: "green")
    let dream = Category(name: "Dream", color: "yellow")

    NavigationStack {
        WorkflowView(tasks: [
            Task(title: "Learn SwiftData", notes: "Model, query, relationship", category: current),
            Task(title: "Build Flocus", notes: "Priority flow", category: alternative),
            Task(title: "Sketch UI", notes: "Explore glass style", category: dream)
        ])
    }
}
