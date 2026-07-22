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
    
    var body: some View {
        Button(label) {
            viewModel.requestNotificationPermission()
            pomodoroManager.startPomodoro(for: task, duration: TimeInterval(duration))
            viewModel.playStartHaptic()
            viewModel.playStartSound()
        }
        .font(.caption)
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .glassEffect()
    }
}
