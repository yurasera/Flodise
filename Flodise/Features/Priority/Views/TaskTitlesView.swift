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
    @State private var expandedIkigaiTitles: Set<String> = []
    var body: some View {
        VStack(spacing: 0) {
            Picker("Titles", selection: $selectedSegment) {
                ForEach(TitleSegment.allCases) { segment in
                    Text(segment.rawValue).tag(segment)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            List {
                ForEach(displayedTasks) { task in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Button {
                                toggleSelection(for: task)
                            } label: {
                                HStack {
                                    Text("\(task.title) (\(titleUsageCount(for: task.title)))")
                                        .foregroundStyle(.primary)

                                    if selectedSegment == .selected,
                                       let title = persistedTitles.first(where: { $0.title == task.title }) {
                                        ForEach(selectedIkigaiTypes(for: title)) { type in
                                            Image(systemName: type.icon)
                                                .font(.system(size: 11, weight: .semibold))
                                                .symbolRenderingMode(.hierarchical)
                                                .foregroundStyle(.secondary)
                                                .accessibilityLabel(type.title)
                                        }
                                    }

                                    Spacer()
                                    Image(systemName: isSelected(task) ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(isSelected(task) ? Color.accentColor : Color.secondary)
                                }
                            }
                            .buttonStyle(.plain)

                            Spacer()

                            if selectedSegment == .selected {
                                Button {
                                    toggleIkigaiExpansion(for: task.title)
                                } label: {
                                    Image(systemName: expandedIkigaiTitles.contains(task.title) ? "chevron.up" : "chevron.down")
                                        .foregroundStyle(.secondary)
                                        .frame(width: 32, height: 32)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(expandedIkigaiTitles.contains(task.title) ? "Hide Ikigai" : "Show Ikigai")
                            }
                        }
                        if selectedSegment == .selected,
                           expandedIkigaiTitles.contains(task.title),
                           let title = persistedTitles.first(where: { $0.title == task.title }) {
                            ikigaiCards(for: title)
                        }
                    }
                    .padding(.vertical, 4)
                }
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

    private func selectedIkigaiTypes(for title: TaskTitle) -> [IkigaiType] {
        IkigaiType.allCases.filter { type in
            title.ikigaiSelections.contains { $0.type == type }
        }
    }

    private func toggleIkigaiExpansion(for title: String) {
        if expandedIkigaiTitles.contains(title) {
            expandedIkigaiTitles.remove(title)
        } else {
            expandedIkigaiTitles.insert(title)
        }
    }

    @ViewBuilder
    private func ikigaiCards(for title: TaskTitle) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(IkigaiType.allCases) { type in
                IkigaiCard(
                    icon: type.icon,
                    title: type.title,
                    description: type.description,
                    isSelected: title.ikigaiSelections.contains { $0.type == type }
                ) {
                    if let selection = title.ikigaiSelections.first(where: { $0.type == type }) {
                        modelContext.delete(selection)
                    } else {
                        let selection = TaskTitleIkigaiSelection(type: type, taskTitle: title)
                        title.ikigaiSelections.append(selection)
                    }
                    saveChanges()
                }
            }
        }
    }

    private func saveChanges() {
        do {
            try modelContext.save()
        } catch {
            assertionFailure("Failed to save task title changes: \(error)")
        }
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
    .modelContainer(for: [Category.self, Task.self, TaskIkigaiSelection.self, TaskTitle.self, TaskTitleIkigaiSelection.self], inMemory: true)
}
