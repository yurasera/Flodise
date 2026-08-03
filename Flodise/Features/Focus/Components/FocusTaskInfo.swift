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
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            if !task.notes.isEmpty {
                Text(task.notes)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
            }
        }
    }
}
