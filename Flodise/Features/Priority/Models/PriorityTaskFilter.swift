//
//  PriorityTaskFilter.swift
//  Flocus
//
//  Created by Yuhaya Lissera on 06/07/26.
//

import SwiftUI

struct PriorityTaskFilter {
    let tasks: [Task]
    let selectedCategory: CategoryFilter
    let selectedProgress: ProgressFilter
    
    var filteredTasks: [Task] {
        tasks.filter { task in
            let categoryMatch = filterByCategory(task)
            let progressMatch = filterByProgress(task)
            return categoryMatch && progressMatch
        }
    }
    
    private func filterByCategory(_ task: Task) -> Bool {
        switch selectedCategory {
        case .all:
            return true
        case .learn:
            return task.category?.name == CategoryKind.learn.title
        case .projects:
            return task.category?.name == CategoryKind.projects.title
        case .hobbies:
            return task.category?.name == CategoryKind.hobbies.title
        }
    }
    
    private func filterByProgress(_ task: Task) -> Bool {
        switch selectedProgress {
        case .active:
            return task.status == .backlog || task.status == .focus
        case .completed:
            return task.status == .completed
        case .archive:
            return task.status == .archive
        }
    }
}
