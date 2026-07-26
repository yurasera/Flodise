//
//  TaskClipboardService.swift
//  Flodise
//
//  Created by Codex on 26/07/26.
//

import Foundation
import UIKit

@MainActor
struct TaskClipboardService {
    private let formatter: TaskClipboardFormatter
    private let pasteboard: UIPasteboard

    init(
        formatter: TaskClipboardFormatter = TaskClipboardFormatter(),
        pasteboard: UIPasteboard = .general
    ) {
        self.formatter = formatter
        self.pasteboard = pasteboard
    }

    func copy(_ tasks: [Task]) {
        pasteboard.string = formatter.string(from: tasks)
    }
}

struct TaskClipboardFormatter {
    struct Configuration {
        var header = "Flocus Tasks"
        var footer = "Please help me prioritize, organize, or improve these tasks."
        var dueDateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter
        }()
    }

    var configuration = Configuration()

    func string(from tasks: [Task]) -> String {
        let items = tasks.enumerated().map { offset, task in
            TaskClipboardItem(task: task, priority: offset + 1)
        }

        return string(from: items)
    }

    private func string(from items: [TaskClipboardItem]) -> String {
        var sections = [configuration.header]
        sections.append(contentsOf: items.enumerated().map {
            formattedTask(index: $0.offset, item: $0.element)
        })
        sections.append(configuration.footer)
        return sections.joined(separator: "\n\n")
    }

    private func formattedTask(index: Int, item: TaskClipboardItem) -> String {
        var lines = ["\(index + 1). \(item.title)"]

        append("Category", item.category, to: &lines)
        append("Status", item.status, to: &lines)
        append("Priority", item.priority, to: &lines)
        append("Due Date", formattedDueDate(item.dueDate), to: &lines)
        append("Tags", item.tags.joined(separator: ", "), to: &lines)

        if let notes = item.notes {
            lines.append("Notes:")
            lines.append(notes)
        }

        return lines.joined(separator: "\n")
    }

    private func append(_ label: String, _ value: String?, to lines: inout [String]) {
        guard let value, !value.isEmpty else { return }
        lines.append("\(label): \(value)")
    }

    private func formattedDueDate(_ dueDate: Date?) -> String? {
        guard let dueDate else { return nil }
        return configuration.dueDateFormatter.string(from: dueDate)
    }
}

private struct TaskClipboardItem {
    let title: String
    let notes: String?
    let category: String?
    let status: String?
    let priority: String?
    let dueDate: Date?
    let tags: [String]

    init(task: Task, priority: Int) {
        self.title = task.title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.notes = task.notes.nonEmptyClipboardValue
        self.category = task.category?.name.nonEmptyClipboardValue
        self.status = task.status.title.nonEmptyClipboardValue
        self.priority = String(priority)
        self.dueDate = nil
        self.tags = IkigaiType.allCases.compactMap { type in
            task.ikigaiSelections.contains(where: { $0.type == type }) ? type.title : nil
        }
    }
}

private extension String {
    var nonEmptyClipboardValue: String? {
        let value = trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }
}
