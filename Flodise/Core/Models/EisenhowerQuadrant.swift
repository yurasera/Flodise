//
//  EisenhowerQuadrant.swift
//  Flodise
//

import Foundation

/// A priority bucket derived from a task title's importance and urgency scores.
enum EisenhowerQuadrant: String, CaseIterable, Codable, Identifiable {
    /// Important work that needs immediate attention.
    case doNow
    /// Important work that can be planned for later.
    case schedule
    /// Urgent work that is not important enough to own personally.
    case delegate
    /// Work that is neither important nor urgent.
    case eliminate

    /// A stable identifier for use in SwiftUI collections.
    var id: Self { self }

    /// The user-facing name of the quadrant.
    var label: String {
        switch self {
        case .doNow: "Do Now"
        case .schedule: "Schedule"
        case .delegate: "Delegate"
        case .eliminate: "Eliminate"
        }
    }

    /// A short explanation of the quadrant's importance and urgency.
    var description: String {
        switch self {
        case .doNow: "Important and Urgent"
        case .schedule: "Important but Not Urgent"
        case .delegate: "Urgent but Not Important"
        case .eliminate: "Not Important and Not Urgent"
        }
    }
}
