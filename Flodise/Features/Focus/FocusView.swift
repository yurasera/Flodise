//
//  FocusView.swift
//  Flocus
//
//  Created by Yuhaya Lissera on 02/07/26.
//

import SwiftUI
import UserNotifications
internal import Combine

struct FocusView: View {
    let task: Task
    let stopFocus: () -> Void
    
    @Environment(PomodoroManager.self) private var pomodoroManager
    @State private var viewModel = FocusViewModel()

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
                viewModel: viewModel
            )
            .padding(.top, 24)

            Spacer()

            FocusActionButton(action: stopFocus)
                .padding(.bottom, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
        .background(viewModel.backgroundColor(for: task.category?.name))
        .foregroundStyle(viewModel.textColor(for: task.category?.name))
        .onAppear {
            // ViewModel initializes haptics in init
        }
        .onReceive(focusTimer) { date in
            viewModel.now = date
        }
    }
}

#Preview {
    FocusView(task: Task(title: "Test", notes: "Test notes", category: nil), stopFocus: {})
}
