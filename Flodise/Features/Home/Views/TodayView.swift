//
//  TodayView.swift
//  Flodise
//

import SwiftUI

struct TodayView: View {
    var body: some View {
        ContentUnavailableView(
            "No Tasks for Today",
            systemImage: "calendar",
            description: Text("Your tasks for today will appear here.")
        )
        .navigationTitle("Today")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        TodayView()
    }
}
