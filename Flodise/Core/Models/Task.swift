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

    var title: String
    var notes: String
    var status: TaskStatus
    var priorityOrder: Int
    var createdAt: Date
    var focusStartedAt: Date?
    var completedAt: Date?
    
    @Relationship(inverse: \Category.tasks)
    var category: Category?

    init(
        title: String,
        notes: String,
        category: Category?
    ) {
        self.title = title
        self.notes = notes
        self.category = category
        self.status = .backlog
        self.priorityOrder = Int(Date().timeIntervalSince1970)
        self.createdAt = .now
        self.focusStartedAt = nil
        self.completedAt = nil
    }

}
