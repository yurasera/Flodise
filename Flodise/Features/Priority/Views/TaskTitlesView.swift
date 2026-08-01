//
//  TaskTitlesView.swift
//  Flodise
//

import SwiftUI

@MainActor
struct TaskTitlesView: View {
    @AppStorage("priority.selectedTaskTitles") private var selectedTitleData = "[]"

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
            filteredTasks = tasks.filter { selectedTitles.contains($0.title) }
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
        selectedTitles.contains(task.title)
    }

    private func titleUsageCount(for title: String) -> Int {
        tasks.filter { $0.title == title }.count
    }

    private func toggleSelection(for task: Task) {
        var titles = selectedTitles
        if titles.contains(task.title) {
            titles.remove(task.title)
        } else {
            titles.insert(task.title)
        }
        selectedTitleData = encode(titles)
    }

    private var selectedTitles: Set<String> {
        guard let data = selectedTitleData.data(using: .utf8),
              let titles = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return Set(titles)
    }

    private func encode(_ titles: Set<String>) -> String {
        guard let data = try? JSONEncoder().encode(Array(titles).sorted()) else {
            return "[]"
        }
        return String(decoding: data, as: UTF8.self)
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
}
