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
    @State private var navigationPath: [HomeMenuDestination] = []

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
        NavigationStack(path: $navigationPath) {
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
            .navigationDestination(for: HomeMenuDestination.self) { destination in
                switch destination {
                case .odyssey:
                    StopPathView()
                case .discovery:
                    DiscoveryView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Menu {
                        Button {
                            navigationPath.append(.odyssey)
                        } label: {
                            Label("Odyssey", systemImage: "triangle.fill")
                        }

                        Button {
                            navigationPath.append(.discovery)
                        } label: {
                            Label("Discovery", systemImage: "sparkles")
                        }
                    } label: {
                        Label("Navigate", systemImage: "square.grid.2x2")
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.isPresentingPriorityTasks) {
            NavigationStack {
                PriorityView(tasks: tasks)
            }
        }
        .onAppear {
            viewModel.setContext(modelContext)
            viewModel.ensureDailyEnergyReset()
        }
    }

    private func stopFocus() {
        viewModel.stopFocus(tasks: tasks)
    }
}

private enum HomeMenuDestination: Hashable {
    case odyssey
    case discovery
}

#Preview {
    // Provide a dummy modelContext for preview
    let previewContainer: ModelContainer
    do {
        previewContainer = try ModelContainer(for: Category.self, Task.self, TaskIkigaiSelection.self)
    } catch {
        fatalError("Failed to create preview container")
    }
    return HomeView(modelContext: ModelContext(previewContainer))
}
