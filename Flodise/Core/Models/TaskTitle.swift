//
//  TaskTitle.swift
//  Flodise
//

import Foundation
import SwiftData

@Model
final class TaskTitle {
    var title: String
    var isSelected: Bool
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \TaskTitleIkigaiSelection.taskTitle)
    var ikigaiSelections: [TaskTitleIkigaiSelection]

    init(title: String, isSelected: Bool = false) {
        self.title = title
        self.isSelected = isSelected
        self.createdAt = .now
        self.ikigaiSelections = []
    }

}
