//
//  TaskTitlePriorityCalculator.swift
//  Flodise
//

import Foundation

/// Pure calculation rules for an Eisenhower priority assessment.
enum TaskTitlePriorityCalculator {
    /// The score contributed by an affirmative answer.
    static let affirmativeAnswerScore = 1

    /// The score that represents no affirmative answers.
    static let noAffirmativeAnswersScore = 0

    /// The relative weight of the importance dimension in the final score.
    static let importanceWeight = 2

    /// Calculates a dimension score from its affirmative answers.
    static func dimensionScore(for answers: [Bool]) -> Int {
        answers.reduce(noAffirmativeAnswersScore) { score, answer in
            score + (answer ? affirmativeAnswerScore : noAffirmativeAnswersScore)
        }
    }

    /// Calculates the final priority score from importance and urgency scores.
    static func priorityScore(important: Int, urgent: Int) -> Int {
        (important * importanceWeight) + urgent
    }

    /// Classifies the scores into an Eisenhower quadrant.
    static func quadrant(important: Int, urgent: Int) -> EisenhowerQuadrant {
        switch (important > noAffirmativeAnswersScore, urgent > noAffirmativeAnswersScore) {
        case (true, true): .doNow
        case (true, false): .schedule
        case (false, true): .delegate
        case (false, false): .eliminate
        }
    }
}
