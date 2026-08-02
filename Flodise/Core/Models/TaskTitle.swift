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

    /// The persisted Eisenhower assessment for this title.
    @Relationship(deleteRule: .cascade, inverse: \TaskTitlePriorityAssessment.taskTitle)
    var priorityAssessment: TaskTitlePriorityAssessment?

    init(title: String, isSelected: Bool = false) {
        self.title = title
        self.isSelected = isSelected
        self.createdAt = .now
        self.ikigaiSelections = []
        self.priorityAssessment = nil
    }

}
