//
//  ContentView.swift
//  Flocus
//
//  Created by Yuhaya Lissera on 23/06/26.
//

import SwiftUI
import SwiftData
import Observation
import OSLog

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var categories: [Category]
    @Query(sort: \Task.priorityOrder) private var tasks: [Task]

    @State private var viewModel: HomeViewModel

    // Initialize ViewModel with modelContext
    init(modelContext: ModelContext) {
        _viewModel = State(wrappedValue: HomeViewModel(modelContext: modelContext))
    }

    // Preview initializer
    init() {
        // Provide a dummy ViewModel for previews
        _viewModel = State(wrappedValue: HomeViewModel())
    }

    var body: some View {
        VStack(spacing: 0) {
            if let focusTask = viewModel.focusTask(from: tasks) {
                FocusView(task: focusTask, stopFocus: stopFocus)
            } else {
                HomeDashboard(
                    categories: categories,
                    learnTasks: viewModel.learnTasks(from: tasks),
                    projectTasks: viewModel.projectTasks(from: tasks),
                    hobbyTasks: viewModel.hobbyTasks(from: tasks),
                    isLearnVisible: $viewModel.isLearnVisible,
                    isProjectsVisible: $viewModel.isProjectsVisible,
                    isHobbiesVisible: $viewModel.isHobbiesVisible
                )

                HomeActionBar(
                    isPresentingPriorityTasks: $viewModel.isPresentingPriorityTasks,
                    startFocusAction: { viewModel.startFocus(tasks: tasks) }
                )
            }
        }
        .ignoresSafeArea()
        .sheet(isPresented: $viewModel.isPresentingPriorityTasks) {
            PriorityView(tasks: tasks)
        }
        .onAppear {
            viewModel.setContext(modelContext)
        }
    }

    private func stopFocus() {
        viewModel.stopFocus(tasks: tasks)
    }
}

#Preview {
    // Provide a dummy modelContext for preview
    let previewContainer: ModelContainer
    do {
        previewContainer = try ModelContainer(for: Category.self, Task.self)
    } catch {
        fatalError("Failed to create preview container")
    }
    return HomeView(modelContext: ModelContext(previewContainer))
}
