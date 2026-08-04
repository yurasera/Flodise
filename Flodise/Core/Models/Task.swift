//
//  Task.swift
//  Flocus
//
//  Created by Yuhaya Lissera on 01/07/26.
//

import SwiftUI
import SwiftData

@Model
final class Task {

    /// Stable identifier used by logs so tasks with the same title stay separate.
    /// Optional to keep existing SwiftData stores migration-compatible.
    var identifier: UUID?
    var title: String
    var notes: String
    var status: TaskStatus
    var priorityOrder: Int
    var estimatedScore: Int?
    var estimatedSize: String?
    var estimatedEffort: Int?
    var createdAt: Date
    var focusStartedAt: Date?
    var completedAt: Date?
    
    @Relationship(inverse: \Category.tasks)
    var category: Category?

    @Relationship(deleteRule: .cascade, inverse: \TaskIkigaiSelection.task)
    var ikigaiSelections: [TaskIkigaiSelection]

    init(
        title: String,
        notes: String,
        category: Category?
    ) {
        self.identifier = UUID()
        self.title = title
        self.notes = notes
        self.category = category
        self.status = .idea
        self.priorityOrder = Int(Date().timeIntervalSince1970)
        self.estimatedScore = nil
        self.estimatedSize = nil
        self.estimatedEffort = nil
        self.createdAt = .now
        self.focusStartedAt = nil
        self.completedAt = nil
        self.ikigaiSelections = []
    }

}
