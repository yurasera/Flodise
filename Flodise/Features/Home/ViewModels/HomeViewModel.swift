//
//  HomeViewModel.swift
//  Flocus
//
//  Created by Yuhaya Lissera on 18/07/26.
//

import SwiftUI
import SwiftData
import Observation

@Observable
final class HomeViewModel {
    // MARK: - Properties
    var isPresentingPriorityTasks = false
    var isCurrentVisible = true
    var isAlternativeVisible = true
    var isDreamVisible = true
    
    private var modelContext: ModelContext?
    
    // MARK: - Initialization
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }
    
    func setContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    // MARK: - Task Filtering
    func currentTasks(from tasks: [Task]) -> [Task] {
        tasks.filter {
            $0.category?.name == CategoryKind.current.title &&
            $0.status != .archive
        }
    }

    func alternativeTasks(from tasks: [Task]) -> [Task] {
        tasks.filter {
            $0.category?.name == CategoryKind.alternative.title &&
            $0.status != .archive
        }
    }

    func dreamTasks(from tasks: [Task]) -> [Task] {
        tasks.filter {
            $0.category?.name == CategoryKind.dream.title &&
            $0.status != .archive
        }
    }
    
    func focusTask(from tasks: [Task]) -> Task? {
        tasks.first { $0.status == .focus }
    }
    
    // MARK: - Actions
    func startFocus(tasks: [Task]) {
        guard let priorityTask = tasks.first(where: { $0.status == .backlog }) else {
            return
        }

        for task in tasks {
            if task.status == .focus {
                task.status = .backlog
                task.focusStartedAt = nil
            }
        }

        priorityTask.status = .focus
        priorityTask.focusStartedAt = .now

        save()
    }

    func stopFocus(tasks: [Task]) {
        guard let focusTask = focusTask(from: tasks) else { return }
        focusTask.status = .backlog
        focusTask.focusStartedAt = nil
        save()
    }
    
    private func save() {
        do {
            try modelContext?.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}
