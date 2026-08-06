//
//  TodayView.swift
//  Flodise
//

import SwiftUI
import SwiftData

struct TodayView: View {
    @Query(sort: \Task.priorityOrder) private var tasks: [Task]

    var body: some View {
        List {
            if !backlogTasks.isEmpty {
                Section("Backlog") {
                    ForEach(backlogTasks) { task in
                        taskRow(for: task)
                    }
                }
            }

            if !completedTasks.isEmpty {
                Section("Completed") {
                    ForEach(completedTasks) { task in
                        taskRow(for: task)
                    }
                }
            }
        }
        .overlay {
            if displayedTasks.isEmpty {
                ContentUnavailableView(
                    "No Tasks for Today",
                    systemImage: "calendar",
                    description: Text("Backlog and completed tasks will appear here.")
                )
            }
        }
        .navigationTitle("Today")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var backlogTasks: [Task] {
        tasks.filter { $0.status == .backlog }
    }

    private var completedTasks: [Task] {
        tasks.filter { $0.status == .completed }
    }

    private var displayedTasks: [Task] {
        backlogTasks + completedTasks
    }

    @ViewBuilder
    private func taskRow(for task: Task) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(task.title)
                .font(.body.weight(.medium))

            if !task.notes.isEmpty {
                Text(task.notes)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 2)
    }
}
