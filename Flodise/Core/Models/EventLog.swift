//
//  EventLog.swift
//  Flodise
//

import Foundation
import SwiftData

enum EventLogType: String {
    case focusSessionStarted
    case workModeSelected
    case breakModeSelected
    case workSessionStarted
    case breakSessionStarted
}

@Model
final class EventLog {
    var eventType: String
    var taskTitle: String
    var occurredAt: Date

    init(eventType: EventLogType, taskTitle: String, occurredAt: Date = .now) {
        self.eventType = eventType.rawValue
        self.taskTitle = taskTitle
        self.occurredAt = occurredAt
    }
}
