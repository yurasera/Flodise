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
    @State private var isShowingEventLog = false

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
            
            if selectedEnergyLevel == nil {
                FocusEnergyLevel(
                    backgroundColor: viewModel.backgroundColor(for: task.category?.name),
                    foregroundColor: viewModel.textColor(for: task.category?.name),
                    selectedEnergy: nil,
                    onSelect: recordEnergyLevel
                )
            }

            FocusTimerSection(
                task: task,
                pomodoroManager: pomodoroManager,
                viewModel: viewModel,
                isWorkMode: isWorkMode,
                selectedEnergy: selectedEnergyLevel,
                onTimerStarted: recordEvent,
                backgroundColor: viewModel.backgroundColor(for: task.category?.name),
                foregroundColor: viewModel.textColor(for: task.category?.name)
            )
            .padding(.top, 24)

            HStack(spacing: 12) {
                Button {
                    isShowingEventLog = true
                } label: {
                    Image(systemName: "list.bullet.rectangle")
                        .font(.headline)
                        .frame(width: 48)
                }
                .padding(.vertical, 12)
                .background(viewModel.backgroundColor(for: task.category?.name))
                .foregroundStyle(viewModel.textColor(for: task.category?.name))
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .glassEffect()
                .accessibilityLabel("Show event log")

                Button {
                    isWorkMode.toggle()
                    recordEvent(isWorkMode ? .breakModeSelected : .workModeSelected)
                } label: {
                    Label(isWorkMode ? "Work" : "Break", systemImage: isWorkMode ? "play.fill": "pause.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(viewModel.backgroundColor(for: task.category?.name))
                .foregroundStyle(viewModel.textColor(for: task.category?.name))
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .glassEffect()
                
                FocusActionButton(
                    action: {
                        recordEvent(.focusSessionEnded)
                        stopFocus()
                    },
                    backgroundColor: viewModel.backgroundColor(for: task.category?.name),
                    foregroundColor: viewModel.textColor(for: task.category?.name)
                )
            }
            .padding(.top, 16)
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
        .sheet(isPresented: $isShowingEventLog) {
            FocusEventLogSheet(eventLogs: taskEventLogs)
        }
    }

    private func recordEvent(_ eventType: EventLogType) {
        modelContext.insert(
            EventLog(
                eventType: eventType,
                taskTitle: task.title,
                taskIdentifier: ensureTaskIdentifier(),
                focusSessionStartedAt: task.focusStartedAt
            )
        )

        do {
            try modelContext.save()
        } catch {
            assertionFailure("Failed to save event log: \(error)")
        }
    }

    private func recordEnergyLevel(_ energyLevel: EnergyLevel) {
        guard selectedEnergyLevel == nil else { return }

        modelContext.insert(
            EventLog(
                eventType: .energyLevelSelected,
                taskTitle: task.title,
                taskIdentifier: ensureTaskIdentifier(),
                energyLevelRawValue: energyLevel.rawValue,
                focusSessionStartedAt: task.focusStartedAt
            )
        )

        do {
            try modelContext.save()
        } catch {
            assertionFailure("Failed to save energy level: \(error)")
        }
    }

    private var taskEventLogs: [EventLog] {
        if let taskIdentifier = task.identifier {
            return eventLogs.filter { $0.taskIdentifier == taskIdentifier }
        }

        // Logs created before identifiers were introduced can still be displayed.
        return eventLogs.filter { $0.taskIdentifier == nil && $0.taskTitle == task.title }
    }

    private func ensureTaskIdentifier() -> UUID {
        if let identifier = task.identifier {
            return identifier
        }

        let identifier = UUID()
        task.identifier = identifier
        return identifier
    }

    private var selectedEnergyLevel: EnergyLevel? {
        guard let sessionStartedAt = task.focusStartedAt,
              let energyEvent = taskEventLogs.first(where: {
                  EventLogType(rawValue: $0.eventType) == .energyLevelSelected &&
                  $0.focusSessionStartedAt == sessionStartedAt
              }),
              let rawValue = energyEvent.energyLevelRawValue else {
            return nil
        }

        return EnergyLevel(rawValue: rawValue)
    }
}

private struct FocusEventLogSection: View {
    let eventLogs: [EventLog]
    var maximumEvents: Int? = 5

    private var displayedEventLogs: [EventLog] {
        guard let maximumEvents else { return eventLogs }
        return Array(eventLogs.prefix(maximumEvents))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Event Log", systemImage: "list.bullet.rectangle")
                .font(.caption.weight(.bold))

            if eventLogs.isEmpty {
                Text("No events recorded yet")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(displayedEventLogs) { eventLog in
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

private struct FocusEventLogSheet: View {
    @Environment(\.dismiss) private var dismiss
    let eventLogs: [EventLog]

    var body: some View {
        NavigationStack {
            ScrollView {
                FocusEventLogSection(eventLogs: eventLogs, maximumEvents: nil)
                    .padding()
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
}


enum EnergyLevel: Int, CaseIterable, Identifiable {
    case veryLow = 1
    case low
    case okay
    case high
    case full

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .veryLow: "Very Low"
        case .low: "Low"
        case .okay: "Okay"
        case .high: "High"
        case .full: "Full"
        }
    }

    var icon: String {
        switch self {
        case .veryLow: "battery.0"
        case .low: "battery.25"
        case .okay: "battery.50"
        case .high: "battery.75"
        case .full: "battery.100"
        }
    }
}

#Preview {
    FocusView(task: Task(title: "Test", notes: "Test notes", category: nil), stopFocus: {})
        .modelContainer(for: [Category.self, Task.self, TaskIkigaiSelection.self, EventLog.self], inMemory: true)
}
