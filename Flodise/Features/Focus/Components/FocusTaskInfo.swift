//
//  FocusTaskInfo.swift
//  Flocus
//

import SwiftUI

struct FocusTaskInfo: View {
    let task: Task
    
    var body: some View {
        VStack(spacing: 12) {
            Text(task.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            if !task.notes.isEmpty {
                Text(task.notes)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}
