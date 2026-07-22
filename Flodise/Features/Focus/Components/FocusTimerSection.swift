//
//  FocusTimerSection.swift
//  Flocus
//

import SwiftUI

struct FocusTimerSection: View {
    let task: Task
    let pomodoroManager: PomodoroManager
    let viewModel: FocusViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            if pomodoroManager.isRunning {
                Text(pomodoroManager.currentTask?.title ?? "")
                    .font(.headline)
                    .multilineTextAlignment(.center)

                Text(viewModel.formatTime(pomodoroManager.remainingTime))
                    .font(.system(size: 48, weight: .bold, design: .monospaced))

                Button("Stop Pomodoro") {
                    pomodoroManager.stopPomodoro()
                }
                .font(.headline)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .glassEffect()
            } else {
                HStack(spacing: 8) {
                    FocusTimerButton(
                        label: "25 min",
                        duration: 25 * 60,
                        task: task,
                        pomodoroManager: pomodoroManager,
                        viewModel: viewModel
                    )
                    
                    FocusTimerButton(
                        label: "5 min",
                        duration: 5 * 60,
                        task: task,
                        pomodoroManager: pomodoroManager,
                        viewModel: viewModel
                    )
                    
                    FocusTimerButton(
                        label: "15 min",
                        duration: 15 * 60,
                        task: task,
                        pomodoroManager: pomodoroManager,
                        viewModel: viewModel
                    )
                }
            }
        }
    }
}
