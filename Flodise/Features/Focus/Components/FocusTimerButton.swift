//
//  FocusTimerButton.swift
//  Flocus
//

import SwiftUI

struct FocusTimerButton: View {
    let label: String
    let duration: Int
    let task: Task
    let pomodoroManager: PomodoroManager
    let viewModel: FocusViewModel
    let eventType: EventLogType
    let onTimerStarted: (EventLogType) -> Void
    let backgroundColor: Color
    let foregroundColor: Color
    
    var body: some View {
        Button(label) {
            viewModel.requestNotificationPermission()
            pomodoroManager.startPomodoro(for: task, duration: TimeInterval(duration))
            onTimerStarted(eventType)
            viewModel.playStartHaptic()
            viewModel.playStartSound()
        }
        .font(.caption)
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(backgroundColor)
        .foregroundColor(foregroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}
