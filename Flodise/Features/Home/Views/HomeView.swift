//
//  HomeView.swift
//  Flodisi
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
    private let onFocusStateChange: (Bool) -> Void

    // Initialize ViewModel with modelContext
    init(modelContext: ModelContext, onFocusStateChange: @escaping (Bool) -> Void = { _ in }) {
        _viewModel = State(wrappedValue: HomeViewModel(modelContext: modelContext))
        self.onFocusStateChange = onFocusStateChange
    }

    // Preview initializer
    init(onFocusStateChange: @escaping (Bool) -> Void = { _ in }) {
        // Provide a dummy ViewModel for previews
        _viewModel = State(wrappedValue: HomeViewModel())
        self.onFocusStateChange = onFocusStateChange
    }

    var body: some View {
        VStack(spacing: 0) {
            if let focusTask = viewModel.focusTask(from: tasks) {
                FocusView(task: focusTask, stopFocus: stopFocus)
            } else {
                HomeDashboard(
                    categories: categories,
                    currentTasks: viewModel.currentTasks(from: tasks),
                    alternativeTasks: viewModel.alternativeTasks(from: tasks),
                    dreamTasks: viewModel.dreamTasks(from: tasks),
                    energy: $viewModel.energy,
                    level: $viewModel.level,
                    exp: $viewModel.exp,
                    currentLevel: $viewModel.currentLevel,
                    currentExp: $viewModel.currentExp,
                    alternativeLevel: $viewModel.alternativeLevel,
                    alternativeExp: $viewModel.alternativeExp,
                    dreamLevel: $viewModel.dreamLevel,
                    dreamExp: $viewModel.dreamExp,
                    isPresentingPriorityTasks: $viewModel.isPresentingPriorityTasks,
                    startFocusAction: { viewModel.startFocus(tasks: tasks) },
                    isCurrentVisible: $viewModel.isCurrentVisible,
                    isAlternativeVisible: $viewModel.isAlternativeVisible,
                    isDreamVisible: $viewModel.isDreamVisible
                )
            }
        }
        .ignoresSafeArea()
        .sheet(isPresented: $viewModel.isPresentingPriorityTasks) {
            NavigationStack {
                WorkflowView(tasks: tasks)
            }
        }
        .onAppear {
            viewModel.setContext(modelContext)
            viewModel.ensureDailyEnergyReset()
            onFocusStateChange(isFocusActive)
        }
        .onChange(of: isFocusActive) { isFocusActive in
            onFocusStateChange(isFocusActive)
        }
        .onDisappear {
            onFocusStateChange(false)
        }
    }

    private var isFocusActive: Bool {
        viewModel.focusTask(from: tasks) != nil
    }

    private func stopFocus() {
        viewModel.stopFocus(tasks: tasks)
    }
}

#Preview {
    // Provide a dummy modelContext for preview
    let previewContainer: ModelContainer
    do {
        previewContainer = try ModelContainer(for: Category.self, Task.self, TaskIkigaiSelection.self, TaskTitle.self, TaskTitleIkigaiSelection.self, TaskTitlePriorityAssessment.self)
    } catch {
        fatalError("Failed to create preview container")
    }
    return HomeView(modelContext: ModelContext(previewContainer))
}
