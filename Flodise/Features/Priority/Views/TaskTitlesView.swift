//
//  TaskTitlesView.swift
//  Flodise
//

import SwiftUI

struct TaskTitlesView: View {
    let tasks: [Task]

    var body: some View {
        List(tasks) { task in
            Text(task.title)
        }
        .navigationTitle("Task Titles")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let category = Category(name: "Current", color: "blue")

    NavigationStack {
        TaskTitlesView(tasks: [
            Task(title: "Learn SwiftData", notes: "", category: category),
            Task(title: "Build Flodise", notes: "", category: category)
        ])
    }
}
