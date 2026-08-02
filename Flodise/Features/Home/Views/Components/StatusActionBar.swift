//
//  StatusActionBar.swift
//  Flodise
//
//  Created by Yuhaya Lissera on 31/07/26.
//
import SwiftUI
import SwiftData

struct StatusActionBar: View {
    @Binding var isPresentingPriorityTasks: Bool
    let startFocusAction: () -> Void

    @Query(sort: \Task.priorityOrder) private var tasks: [Task]
    @State private var isPresentingTaskTitles = false
    @State private var priorityPresentationTrigger = 0

    var body: some View {
        VStack(spacing: 0) {
            HomeActionButton(
                title: "Workflow",
                systemImage: "flag.fill",
                foregroundColor: Color.brandTertiary,
                tintColor: Color.brandPrimary
            ) {
                priorityPresentationTrigger += 1
                isPresentingPriorityTasks = true
            }

            HomeActionButton(
                title: "Priority",
                systemImage: "list.bullet",
                foregroundColor: Color.brandTertiary
            ) {
                priorityPresentationTrigger += 1
                isPresentingTaskTitles = true
            }

            HomeActionButton(
                title: "Start Focus",
                systemImage: "timer",
                foregroundColor: Color.brandTertiary,
            ) {
                priorityPresentationTrigger += 1
                startFocusAction()
            }
            Spacer()
        }
        .padding()
        .sensoryFeedback(.impact(weight: .heavy), trigger: priorityPresentationTrigger)
        .sheet(isPresented: $isPresentingTaskTitles) {
            NavigationStack {
                PriorityView(tasks: tasks)
            }
        }
    }
}

private struct HomeActionButton: View {
    let title: String
    let systemImage: String
    let foregroundColor: Color
    var tintColor: Color?
    let action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: action) {
                HStack {
                    Image(systemName: systemImage)
                    Text(title)
                }
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 14)
                .foregroundStyle(foregroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .glassEffect()
            }
            .background(Color.brandPrimary)
            .tint(tintColor ?? foregroundColor)
        }
        .padding(4)
    }
}
