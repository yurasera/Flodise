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
    @Query(sort: [SortDescriptor(\EventLog.occurredAt, order: .reverse)]) private var eventLogs: [EventLog]
    @State private var isPresentingActions = false
    @State private var pendingAction: (() -> Void)?
    @State private var isPresentingTaskTitles = false
    @State private var isPresentingEventLogs = false
    @State private var priorityPresentationTrigger = 0
    private let columns = [
        GridItem(.flexible(), spacing: 6),
        GridItem(.flexible(), spacing: 6)
    ]

    var body: some View {
        HomeActionButton(
            title: "Actions",
            systemImage: "ellipsis.circle",
            foregroundColor: Color.brandTertiary,
            tintColor: Color.brandPrimary
        ) {
            isPresentingActions = true
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .sensoryFeedback(.impact(weight: .heavy), trigger: priorityPresentationTrigger)
        .sheet(isPresented: $isPresentingActions, onDismiss: performPendingAction) {
            actionSheet
                .presentationDetents([.height(250)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isPresentingTaskTitles) {
            NavigationStack {
                PriorityView(tasks: tasks)
            }
        }
        .sheet(isPresented: $isPresentingEventLogs) {
            HomeEventLogView(eventLogs: eventLogs)
        }
    }

    private var actionSheet: some View {
        LazyVGrid(columns: columns, spacing: 6) {
            HomeActionButton(
                title: "Workflow",
                systemImage: "flag.fill",
                foregroundColor: Color.brandTertiary,
                tintColor: Color.brandPrimary
            ) {
                dismissActionsThen {
                    priorityPresentationTrigger += 1
                    isPresentingPriorityTasks = true
                }
            }
            .frame(maxWidth: .infinity)

            HomeActionButton(
                title: "Priority",
                systemImage: "list.bullet",
                foregroundColor: Color.brandTertiary
            ) {
                dismissActionsThen {
                    priorityPresentationTrigger += 1
                    isPresentingTaskTitles = true
                }
            }
            .frame(maxWidth: .infinity)

            HomeActionButton(
                title: "Event Log",
                systemImage: "list.bullet.rectangle",
                foregroundColor: Color.brandTertiary
            ) {
                dismissActionsThen {
                    priorityPresentationTrigger += 1
                    isPresentingEventLogs = true
                }
            }
            .frame(maxWidth: .infinity)
            
            HomeActionButton(
                title: "Start Focus",
                systemImage: "timer",
                foregroundColor: Color.brandTertiary,
            ) {
                dismissActionsThen {
                    priorityPresentationTrigger += 1
                    startFocusAction()
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(6)
    }

    private func dismissActionsThen(_ action: @escaping () -> Void) {
        pendingAction = action
        isPresentingActions = false
    }

    private func performPendingAction() {
        let action = pendingAction
        pendingAction = nil
        action?()
    }
}
