//
//  TaskTitlePriorityAssessment.swift
//  Flodise
//

import SwiftData

/// Persisted answers for a task title's Eisenhower priority assessment.
@Model
final class TaskTitlePriorityAssessment {
    /// Whether this title directly contributes to a goal.
    var importantGoalContribution: Bool

    /// Whether not doing this title would delay or make a goal harder to achieve.
    var importantBlocksGoal: Bool

    /// Whether this title needs to be done immediately.
    var urgentImmediate: Bool

    /// Whether delaying this title has near-term consequences.
    var urgentHasConsequence: Bool

    /// The title this assessment belongs to.
    var taskTitle: TaskTitle?

    /// The number of affirmative importance answers.
    var importantScore: Int {
        TaskTitlePriorityCalculator.dimensionScore(
            for: [importantGoalContribution, importantBlocksGoal]
        )
    }

    /// The number of affirmative urgency answers.
    var urgentScore: Int {
        TaskTitlePriorityCalculator.dimensionScore(
            for: [urgentImmediate, urgentHasConsequence]
        )
    }

    /// The weighted priority score calculated from importance and urgency.
    var priorityScore: Int {
        TaskTitlePriorityCalculator.priorityScore(important: importantScore, urgent: urgentScore)
    }

    /// The Eisenhower quadrant calculated from importance and urgency.
    var quadrant: EisenhowerQuadrant {
        TaskTitlePriorityCalculator.quadrant(important: importantScore, urgent: urgentScore)
    }

    /// Creates an empty assessment whose answers default to `false`.
    init(taskTitle: TaskTitle? = nil) {
        self.importantGoalContribution = false
        self.importantBlocksGoal = false
        self.urgentImmediate = false
        self.urgentHasConsequence = false
        self.taskTitle = taskTitle
    }
}
