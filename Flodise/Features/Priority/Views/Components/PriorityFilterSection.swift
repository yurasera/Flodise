//
//  PriorityFilterSection.swift
//  Flocus
//
//  Created by Yuhaya Lissera on 06/07/26.
//

import SwiftUI

struct PriorityFilterSection: View {
    let tasks: [Task]
    @Binding var selectedCategory: CategoryFilter
    @Binding var selectedProgress: ProgressFilter

    private func taskCount(for category: CategoryFilter) -> Int {
        PriorityTaskFilter(
            tasks: tasks,
            selectedCategory: category,
            selectedProgress: selectedProgress
        )
        .filteredTasks
        .count
    }

    private func taskCount(for progress: ProgressFilter) -> Int {
        PriorityTaskFilter(
            tasks: tasks,
            selectedCategory: selectedCategory,
            selectedProgress: progress
        )
        .filteredTasks
        .count
    }
    
    var body: some View {
        Section {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Path")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Menu {
                            ForEach(ProgressFilter.allCases) { progress in
                                Button {
                                    selectedProgress = progress
                                } label: {
                                    Label("\(progress.rawValue) (\(taskCount(for: progress)))", systemImage: selectedProgress == progress ? "checkmark" : "")
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Text("\(selectedProgress.rawValue) (\(taskCount(for: selectedProgress)))")
                                Image(systemName: "chevron.down")
                                    .font(.caption2)
                            }
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 8)
                            .background(.thinMaterial, in: Capsule())
                        }
                    }

                    Picker("Category", selection: $selectedCategory) {
                        ForEach(CategoryFilter.allCases) { category in
                            Text("\(category.rawValue == "Alternative" ? "Alter" : category.rawValue ) (\(taskCount(for: category)))")
                                .tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .padding(.vertical, 8)
        }
    }
}
