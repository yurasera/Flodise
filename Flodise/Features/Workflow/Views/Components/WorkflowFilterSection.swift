//
//  WorkflowFilterSection.swift
//  Flocus
//
//  Created by Yuhaya Lissera on 06/07/26.
//

import SwiftUI
import SwiftData

struct WorkflowFilterSection: View {
    let tasks: [Task]
    @Binding var selectedCategory: CategoryFilter
    @Binding var selectedProgress: ProgressFilter
    @Query(sort: \TaskTitle.title) private var taskTitles: [TaskTitle]
    @State private var usesSegmentedProgressPicker = false

    private let visibleProgressFilters: [ProgressFilter] = [.idea, .planned, .active]

    private var selectedTaskTitles: [TaskTitle] {
        taskTitles.filter(\.isSelected)
    }

    private func taskCount(for category: CategoryFilter) -> Int {
        WorkflowTaskFilter(
            tasks: tasks,
            selectedCategory: category,
            selectedProgress: selectedProgress
        )
        .filteredTasks
        .count
    }

    private func taskCount(for progress: ProgressFilter) -> Int {
        WorkflowTaskFilter(
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
                        if !usesSegmentedProgressPicker {
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

                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                usesSegmentedProgressPicker.toggle()
                            }
                        } label: {
                            Image(systemName: usesSegmentedProgressPicker ? "chevron.up" : "slider.horizontal.3")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.primary)
                                .frame(width: 32, height: 32)
                                .background(.thinMaterial, in: Circle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(usesSegmentedProgressPicker ? "Use progress menu" : "Use segmented progress picker")
                    }

                    if usesSegmentedProgressPicker {
                        Picker("Progress", selection: $selectedProgress) {
                            ForEach(visibleProgressFilters) { progress in
                                Text("\(progress.rawValue) (\(taskCount(for: progress)))")
                                    .tag(progress)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(CategoryFilter.allCases) { category in
                            Text("\(category.rawValue == "Alternative" ? "Alter" : category.rawValue ) (\(taskCount(for: category)))")
                                .tag(category)
                        }
                    }
                    .pickerStyle(.segmented)

                    if !selectedTaskTitles.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(selectedTaskTitles) { taskTitle in
                                    Label(taskTitle.title, systemImage: "checkmark.circle.fill")
                                        .font(.caption.weight(.medium))
                                        .foregroundStyle(Color.brandPrimary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color.brandPrimary.opacity(0.12), in: Capsule())
                                }
                            }
                        }
                        .accessibilityLabel("Selected task titles")
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
}
