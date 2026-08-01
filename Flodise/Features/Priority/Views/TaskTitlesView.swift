//
//  TaskTitlesView.swift
//  Flodise
//

import SwiftUI
import SwiftData

@MainActor
struct TaskTitlesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\TaskTitle.title)])
    private var persistedTitles: [TaskTitle]

    let tasks: [Task]

    private enum TitleSegment: String, CaseIterable, Identifiable {
        case all = "All Titles"
        case selected = "Selected"

        var id: Self { self }
    }

    @State private var selectedSegment: TitleSegment = .all
    var body: some View {
        VStack(spacing: 0) {
            Picker("Titles", selection: $selectedSegment) {
                ForEach(TitleSegment.allCases) { segment in
                    Text(segment.rawValue).tag(segment)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            List(displayedTasks) { task in
                Button {
                    toggleSelection(for: task)
                } label: {
                    HStack {
                        Text("\(task.title) (\(titleUsageCount(for: task.title)))")
                            .foregroundStyle(.primary)

                        Spacer()

                        Image(systemName: isSelected(task) ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(isSelected(task) ? Color.accentColor : Color.secondary)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle("Task Titles")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var displayedTasks: [Task] {
        let filteredTasks: [Task]

        switch selectedSegment {
        case .all:
            filteredTasks = tasks
        case .selected:
            filteredTasks = tasks.filter { isSelectedTitle($0.title) }
        }

        var uniqueTasksByTitle: [String: Task] = [:]
        for task in filteredTasks {
            uniqueTasksByTitle[task.title] = task
        }

        return uniqueTasksByTitle.values.sorted {
            $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
        }
    }

    private func isSelected(_ task: Task) -> Bool {
        isSelectedTitle(task.title)
    }

    private func titleUsageCount(for title: String) -> Int {
        tasks.filter { $0.title == title }.count
    }

    private func toggleSelection(for task: Task) {
        if let persistedTitle = persistedTitles.first(where: { $0.title == task.title }) {
            persistedTitle.isSelected.toggle()
        } else {
            modelContext.insert(TaskTitle(title: task.title, isSelected: true))
        }

        do {
            try modelContext.save()
        } catch {
            assertionFailure("Failed to save task title selection: \(error)")
        }
    }

    private func isSelectedTitle(_ title: String) -> Bool {
        persistedTitles.first(where: { $0.title == title })?.isSelected == true
    }
}

#Preview {
    let category = Category(name: "Current", color: "blue")

    NavigationStack {
        TaskTitlesView(tasks: [
            Task(title: "Learn SwiftData", notes: "", category: category),
            Task(title: "Build Flodise", notes: "", category: category)
        ])
    }
    .modelContainer(for: [Category.self, Task.self, TaskIkigaiSelection.self, TaskTitle.self], inMemory: true)
}
