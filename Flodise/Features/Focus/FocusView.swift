//
//  FocusView.swift
//  Flocus
//
//  Created by Yuhaya Lissera on 02/07/26.
//

import SwiftUI
import SwiftData
import UserNotifications
internal import Combine

struct FocusView: View {
    let task: Task
    let stopFocus: () -> Void
    
    @Environment(\.modelContext) private var modelContext
    @Environment(PomodoroManager.self) private var pomodoroManager
    @Query(sort: [SortDescriptor(\EventLog.occurredAt, order: .reverse)]) private var eventLogs: [EventLog]
    @State private var viewModel = FocusViewModel()
    @State private var hasLoggedFocusSessionStart = false
    @State private var isWorkMode = true

    private let focusTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 0) {
            FocusHeader(
                categoryName: task.category?.name,
                focusDurationText: viewModel.focusDurationText(for: task),
            )
            .padding(.top, 48)

            Spacer()

            FocusTaskInfo(task: task)

            Spacer()

            FocusTimerSection(
                task: task,
                pomodoroManager: pomodoroManager,
                viewModel: viewModel,
                isWorkMode: isWorkMode,
                onTimerStarted: recordEvent
            )
            .padding(.top, 24)

            Button {
                isWorkMode.toggle()
                recordEvent(isWorkMode ? .workModeSelected : .breakModeSelected)
            } label: {
                Label(isWorkMode ? "Work" : "Break", systemImage: "arrow.triangle.2.circlepath")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .glassEffect()
            .padding(.top, 16)

            FocusEventLogSection(eventLogs: taskEventLogs)
                .padding(.top, 20)

            Spacer()

            FocusActionButton(action: stopFocus)
                .padding(.bottom, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
        .background(viewModel.backgroundColor(for: task.category?.name))
        .foregroundStyle(viewModel.textColor(for: task.category?.name))
        .onAppear {
            guard !hasLoggedFocusSessionStart else { return }
            hasLoggedFocusSessionStart = true
            recordEvent(.focusSessionStarted)
        }
        .onReceive(focusTimer) { date in
            viewModel.now = date
        }
    }

    private func recordEvent(_ eventType: EventLogType) {
        modelContext.insert(EventLog(eventType: eventType, taskTitle: task.title))

        do {
            try modelContext.save()
        } catch {
            assertionFailure("Failed to save event log: \(error)")
        }
    }

    private var taskEventLogs: [EventLog] {
        eventLogs.filter { $0.taskTitle == task.title }
    }
}

private struct FocusEventLogSection: View {
    let eventLogs: [EventLog]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Event Log", systemImage: "list.bullet.rectangle")
                .font(.caption.weight(.bold))

            if eventLogs.isEmpty {
                Text("No events recorded yet")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(eventLogs.prefix(5)) { eventLog in
                    HStack {
                        Text(eventLabel(for: eventLog))
                        Spacer()
                        Text(eventLog.occurredAt.formatted(date: .omitted, time: .shortened))
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .font(.caption)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func eventLabel(for eventLog: EventLog) -> String {
        switch EventLogType(rawValue: eventLog.eventType) {
        case .focusSessionStarted:
            return "Focus session started"
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

#Preview {
    FocusView(task: Task(title: "Test", notes: "Test notes", category: nil), stopFocus: {})
        .modelContainer(for: [Category.self, Task.self, TaskIkigaiSelection.self, EventLog.self], inMemory: true)
}
