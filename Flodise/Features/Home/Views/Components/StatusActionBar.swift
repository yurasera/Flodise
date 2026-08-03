//
//  StatusActionBar.swift
//  Flodise
//
//  Created by Yuhaya Lissera on 31/07/26.
//
import SwiftUI
import SwiftData

struct StatusActionBar: View {
    @Binding var isPresentingPriorityTasks: Bool
    let startFocusAction: () -> Void

    @Query(sort: \Task.priorityOrder) private var tasks: [Task]
    @Query(sort: [SortDescriptor(\EventLog.occurredAt, order: .reverse)]) private var eventLogs: [EventLog]
    @State private var isPresentingTaskTitles = false
    @State private var isPresentingEventLogs = false
    @State private var priorityPresentationTrigger = 0

    var body: some View {
        VStack(spacing: 0) {
            HomeActionButton(
                title: "Workflow",
                systemImage: "flag.fill",
                foregroundColor: Color.brandTertiary,
                tintColor: Color.brandPrimary
            ) {
                priorityPresentationTrigger += 1
                isPresentingPriorityTasks = true
            }

            HomeActionButton(
                title: "Priority",
                systemImage: "list.bullet",
                foregroundColor: Color.brandTertiary
            ) {
                priorityPresentationTrigger += 1
                isPresentingTaskTitles = true
            }

            HomeActionButton(
                title: "Start Focus",
                systemImage: "timer",
                foregroundColor: Color.brandTertiary,
            ) {
                priorityPresentationTrigger += 1
                startFocusAction()
            }

            HomeActionButton(
                title: "Event Log",
                systemImage: "list.bullet.rectangle",
                foregroundColor: Color.brandTertiary
            ) {
                priorityPresentationTrigger += 1
                isPresentingEventLogs = true
            }
            Spacer()
        }
        .padding()
        .sensoryFeedback(.impact(weight: .heavy), trigger: priorityPresentationTrigger)
        .sheet(isPresented: $isPresentingTaskTitles) {
            NavigationStack {
                PriorityView(tasks: tasks)
            }
        }
        .sheet(isPresented: $isPresentingEventLogs) {
            HomeEventLogView(eventLogs: eventLogs)
        }
    }
}

private struct HomeEventLogView: View {
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

private struct HomeActionButton: View {
    let title: String
    let systemImage: String
    let foregroundColor: Color
    var tintColor: Color?
    let action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: action) {
                HStack {
                    Image(systemName: systemImage)
                    Text(title)
                }
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 14)
                .foregroundStyle(foregroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .glassEffect()
            }
            .background(Color.brandPrimary)
            .tint(tintColor ?? foregroundColor)
        }
        .padding(4)
    }
}
