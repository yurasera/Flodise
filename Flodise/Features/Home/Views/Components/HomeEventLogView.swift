//
//  HomeEventLogView.swift
//  Flodise
//
//  Created by Yuhaya Lissera on 06/08/26.
//

import SwiftUI

struct HomeEventLogView: View {
    @Environment(\.dismiss) private var dismiss
    let eventLogs: [EventLog]

    var body: some View {
        NavigationStack {
            List(eventLogs) { eventLog in
                VStack(alignment: .leading, spacing: 4) {
                    Text(eventTitle(for: eventLog))
                        .font(.headline)
                    Text(eventLog.taskTitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(eventLog.occurredAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .overlay {
                if eventLogs.isEmpty {
                    ContentUnavailableView(
                        "No Event Logs",
                        systemImage: "list.bullet.rectangle",
                        description: Text("Focus activity will appear here.")
                    )
                }
            }
            .navigationTitle("Event Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func eventTitle(for eventLog: EventLog) -> String {
        switch EventLogType(rawValue: eventLog.eventType) {
        case .focusSessionStarted:
            return "Focus session started"
        case .energyLevelSelected:
            if let rawValue = eventLog.energyLevelRawValue,
               let energyLevel = EnergyLevel(rawValue: rawValue) {
                return "Energy: \(energyLevel.title)"
            }
            return "Energy level selected"
        case .focusSessionEnded:
            return "Focus session ended"
        case .workModeSelected:
            return "Switched to Work"
        case .breakModeSelected:
            return "Switched to Break"
        case .workSessionStarted:
            return "Work timer started"
        case .breakSessionStarted:
            return "Break timer started"
        case nil:
            return eventLog.eventType
        }
    }
}

