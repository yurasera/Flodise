//
//  TodayView.swift
//  Flodise
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Task.priorityOrder) private var tasks: [Task]
    @State private var draggedTask: Task?
    @State private var dropTarget: TimePeriod?
    @State private var isDropTargetingUnscheduled = false

    var body: some View {
        List {
            Section("Unscheduled") {
                if unscheduledTasks.isEmpty {
                    Text("Drag a task here to remove its scheduled time.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(unscheduledTasks) { task in
                        taskRow(for: task)
                    }
                }
            }
            .onDrop(of: [UTType.text], isTargeted: $isDropTargetingUnscheduled) { _ in
                handleDrop(to: nil)
            }
            .listRowBackground(isDropTargetingUnscheduled ? Color.accentColor.opacity(0.14) : Color.clear)

            ForEach(TimePeriod.allCases) { period in
                Section {
                    if tasks(in: period).isEmpty {
                        Text("No tasks")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(tasks(in: period)) { task in
                            taskRow(for: task)
                        }
                    }
                } header: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(period.title)
                        Text(period.timeRange)
                            .font(.caption)
                            .textCase(nil)
                        Text(period.description)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .textCase(nil)
                    }
                }
                .onDrop(of: [UTType.text], isTargeted: dropTargetBinding(for: period)) { _ in
                    handleDrop(to: period)
                }
                .listRowBackground(dropTarget == period ? Color.accentColor.opacity(0.14) : Color.clear)
            }
        }
        .overlay {
            if displayedTasks.isEmpty {
                ContentUnavailableView(
                    "No Tasks for Today",
                    systemImage: "calendar",
                    description: Text("Backlog and completed tasks will appear here.")
                )
            }
        }
        .navigationTitle("Today")
        .navigationBarTitleDisplayMode(.inline)
        .presentationDetents([.large])
    }

    private var displayedTasks: [Task] {
        tasks.filter { $0.status == .backlog || $0.status == .completed }
    }

    private var unscheduledTasks: [Task] {
        displayedTasks.filter { $0.todayTime == nil }
    }

    private func tasks(in period: TimePeriod) -> [Task] {
        displayedTasks.filter { task in
            guard let todayTime = task.todayTime else { return false }
            return period.contains(todayTime)
        }
    }

    @ViewBuilder
    private func taskRow(for task: Task) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text(task.title)
                    .font(.body.weight(.medium))

                Spacer()

                Text(task.status.title)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(task.status == .completed ? .green : .orange)
            }

            if !task.notes.isEmpty {
                Text(task.notes)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            if let todayTime = task.todayTime {
                Text(todayTime.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
        .onDrag {
            draggedTask = task
            return NSItemProvider(object: task.title as NSString)
        }
    }

    private func dropTargetBinding(for period: TimePeriod) -> Binding<Bool> {
        Binding(
            get: { dropTarget == period },
            set: { isTargeted in
                dropTarget = isTargeted ? period : nil
            }
        )
    }

    private func handleDrop(to period: TimePeriod?) -> Bool {
        guard let draggedTask else { return false }

        draggedTask.todayTime = period?.scheduledTime
        self.draggedTask = nil
        dropTarget = nil
        isDropTargetingUnscheduled = false

        do {
            try modelContext.save()
        } catch {
            assertionFailure("Could not save task time: \(error)")
        }

        return true
    }
}

private enum TimePeriod: CaseIterable, Identifiable {
    case midnight
    case lateNight
    case dawn
    case morning
    case noon
    case afternoon
    case twilight
    case dusk
    case evening
    case night

    var id: Self { self }

    var title: String {
        switch self {
        case .dawn: return "Dawn"
        case .morning: return "Morning"
        case .noon: return "Noon / Midday"
        case .afternoon: return "Afternoon"
        case .twilight: return "Twilight"
        case .dusk: return "Dusk"
        case .evening: return "Evening"
        case .night: return "Night"
        case .midnight: return "Midnight"
        case .lateNight: return "Late Night / Wee Hours"
        }
    }

    var timeRange: String {
        switch self {
        case .dawn: return "Pukul 04.00 – 06.00"
        case .morning: return "Pukul 06.01 – 11.59"
        case .noon: return "Pukul 12.00"
        case .afternoon: return "Pukul 12.01 – 17.30"
        case .twilight: return "Pukul 17.31 – 18.00"
        case .dusk: return "Pukul 18.01 – 18.30"
        case .evening: return "Pukul 18.31 – 21.00"
        case .night: return "Pukul 21.01 – 23.59"
        case .midnight: return "Pukul 00.00"
        case .lateNight: return "Pukul 00.01 – 03.59"
        }
    }

    var description: String {
        switch self {
        case .dawn: return "Fajar/subuh sebelum matahari terbit"
        case .morning: return "Pagi hari"
        case .noon: return "Tepat siang"
        case .afternoon: return "Siang menuju sore"
        case .twilight: return "Transisi cahaya menjelang matahari terbenam"
        case .dusk: return "Senja setelah matahari tenggelam"
        case .evening: return "Petang/malam awal"
        case .night: return "Malam hari sebelum tengah malam"
        case .midnight: return "Tengah malam"
        case .lateNight: return "Dini hari"
        }
    }

    var scheduledTime: Date {
        let calendar = Calendar.current
        let hour: Int
        let minute: Int

        switch self {
        case .midnight: (hour, minute) = (0, 0)
        case .lateNight: (hour, minute) = (0, 1)
        case .dawn: (hour, minute) = (4, 0)
        case .morning: (hour, minute) = (6, 1)
        case .noon: (hour, minute) = (12, 0)
        case .afternoon: (hour, minute) = (12, 1)
        case .twilight: (hour, minute) = (17, 31)
        case .dusk: (hour, minute) = (18, 1)
        case .evening: (hour, minute) = (18, 31)
        case .night: (hour, minute) = (21, 1)
        }

        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: .now) ?? .now
    }

    func contains(_ date: Date) -> Bool {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let minuteOfDay = (components.hour ?? 0) * 60 + (components.minute ?? 0)

        switch minuteOfDay {
        case 0:
            return self == .midnight
        case 1...239:
            return self == .lateNight
        case 240...360:
            return self == .dawn
        case 361...719:
            return self == .morning
        case 720:
            return self == .noon
        case 721...1050:
            return self == .afternoon
        case 1051...1080:
            return self == .twilight
        case 1081...1110:
            return self == .dusk
        case 1111...1260:
            return self == .evening
        default:
            return self == .night
        }
    }
}
