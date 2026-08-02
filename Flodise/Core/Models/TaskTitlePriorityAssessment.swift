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

    /// Whether another activity would contribute more to achieving the goal.
    var importantHasBetterAlternative: Bool?

    /// Whether this title needs to be done immediately.
    var urgentImmediate: Bool

    /// Whether delaying this title has near-term consequences.
    var urgentHasConsequence: Bool

    /// Whether this title can be postponed.
    var urgentCanBeDelayed: Bool?

    /// The title this assessment belongs to.
    var taskTitle: TaskTitle?

    /// The importance score after subtracting answers that reduce importance.
    var importantScore: Int {
        TaskTitlePriorityCalculator.dimensionScore(for: [
            importantGoalContribution,
            importantBlocksGoal
        ]) - TaskTitlePriorityCalculator.dimensionScore(for: [importantHasBetterAlternative == true])
    }

    /// The urgency score after subtracting answers that reduce urgency.
    var urgentScore: Int {
        TaskTitlePriorityCalculator.dimensionScore(for: [
            urgentImmediate,
            urgentHasConsequence
        ]) - TaskTitlePriorityCalculator.dimensionScore(for: [urgentCanBeDelayed == true])
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
        self.importantHasBetterAlternative = false
        self.urgentImmediate = false
        self.urgentHasConsequence = false
        self.urgentCanBeDelayed = false
        self.taskTitle = taskTitle
    }
}
