//
//  EventLog.swift
//  Flodise
//

import Foundation
import SwiftData

enum EventLogType: String {
    case focusSessionStarted
    case energyLevelSelected
    case workModeSelected
    case breakModeSelected
    case workSessionStarted
    case breakSessionStarted
    case focusSessionEnded
}

@Model
final class EventLog {
    var eventType: String
    var taskTitle: String
    /// The stable task identifier. Optional for compatibility with old logs.
    var taskIdentifier: UUID?
    var occurredAt: Date
    /// The energy answer, when this event records an energy-level selection.
    /// Optional so existing event logs remain compatible with SwiftData.
    var energyLevelRawValue: Int?
    /// Identifies the focus session this event belongs to.
    /// Optional so previously persisted logs can still be loaded.
    var focusSessionStartedAt: Date?

    init(
        eventType: EventLogType,
        taskTitle: String,
        taskIdentifier: UUID? = nil,
        occurredAt: Date = .now,
        energyLevelRawValue: Int? = nil,
        focusSessionStartedAt: Date? = nil
    ) {
        self.eventType = eventType.rawValue
        self.taskTitle = taskTitle
        self.taskIdentifier = taskIdentifier
        self.occurredAt = occurredAt
        self.energyLevelRawValue = energyLevelRawValue
        self.focusSessionStartedAt = focusSessionStartedAt
    }
}
