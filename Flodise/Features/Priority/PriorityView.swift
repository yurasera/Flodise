//
//  PriorityView.swift
//  Flodise
//

import SwiftUI
import SwiftData

@MainActor
struct PriorityView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\TaskTitle.title)])
    private var persistedTitles: [TaskTitle]

    let tasks: [Task]

    private enum TitleSegment: String, CaseIterable, Identifiable {
        case all = "All Titles"
        case selected = "Selected"

        var id: Self { self }
    }

    @State private var selectedSegment: TitleSegment = .all
    @State private var presentedTitle: TaskTitle?
    var body: some View {
        VStack(spacing: 0) {
            Picker("Titles", selection: $selectedSegment) {
                ForEach(TitleSegment.allCases) { segment in
                    Text(segment.rawValue).tag(segment)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            List {
                switch selectedSegment {
                case .all:
                    ForEach(displayedTasks) { task in
                        taskTitleRow(for: task)
                    }
                case .selected:
                    ForEach(EisenhowerQuadrant.allCases) { quadrant in
                        if !selectedTasks(in: quadrant).isEmpty {
                            Section(quadrant.label) {
                                ForEach(selectedTasks(in: quadrant)) { task in
                                    taskTitleRow(for: task)
                                }
                            }
                        }
                    }

                    if !selectedTasksWithoutAssessment.isEmpty {
                        Section("Not Assessed") {
                            ForEach(selectedTasksWithoutAssessment) { task in
                                taskTitleRow(for: task)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Priority")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $presentedTitle) { title in
            NavigationStack {
                titleDetailSheet(for: title)
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }

    @ViewBuilder
    private func taskTitleRow(for task: Task) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button {
                    toggleSelection(for: task)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(task.title)
                                .foregroundStyle(.primary)
                            HStack(spacing: 6) {
                                Text(titleMetadata(for: task))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                if selectedSegment == .selected,
                                   let title = persistedTitles.first(where: { $0.title == task.title }) {
                                    ForEach(selectedIkigaiTypes(for: title)) { type in
                                        Image(systemName: type.icon)
                                            .font(.system(size: 11, weight: .semibold))
                                            .symbolRenderingMode(.hierarchical)
                                            .foregroundStyle(.secondary)
                                            .accessibilityLabel(type.title)
                                    }
                                }
                            }
                        }
                        Spacer()
                        Image(systemName: isSelected(task) ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(isSelected(task) ? Color.accentColor : Color.secondary)
                    }
                }
                .buttonStyle(.plain)

                if selectedSegment == .selected {
                    Button {
                        presentedTitle = persistedTitles.first(where: { $0.title == task.title })
                    } label: {
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                            .frame(width: 32, height: 32)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Show title details")
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var displayedTasks: [Task] {
        let filteredTasks: [Task]

        switch selectedSegment {
        case .all:
            filteredTasks = tasks
        case .selected:
            filteredTasks = tasks.filter { isSelectedTitle($0.title) }
        }

        var uniqueTasksByTitle: [String: Task] = [:]
        for task in filteredTasks {
            uniqueTasksByTitle[task.title] = task
        }

        return uniqueTasksByTitle.values.sorted {
            $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
        }
    }

    private var selectedTasksWithoutAssessment: [Task] {
        displayedTasks.filter { task in
            guard let title = persistedTitles.first(where: { $0.title == task.title }) else {
                return false
            }
            return title.priorityAssessment == nil
        }
    }

    private func selectedTasks(in quadrant: EisenhowerQuadrant) -> [Task] {
        displayedTasks.filter { task in
            persistedTitles.first(where: { $0.title == task.title })?.priorityAssessment?.quadrant == quadrant
        }
    }

    private func isSelected(_ task: Task) -> Bool {
        isSelectedTitle(task.title)
    }

    private func titleUsageCount(for title: String) -> Int {
        tasks.filter { $0.title == title }.count
    }

    private func titleMetadata(for task: Task) -> String {
        let usageCount = titleUsageCount(for: task.title)

        guard selectedSegment == .selected,
              let title = persistedTitles.first(where: { $0.title == task.title }),
              let assessment = title.priorityAssessment else {
            return "Used by \(usageCount) task\(usageCount == 1 ? "" : "s")"
        }

        return "Used by \(usageCount) task\(usageCount == 1 ? "" : "s") · Score: \(assessment.priorityScore)"
    }

    private func toggleSelection(for task: Task) {
        if let persistedTitle = persistedTitles.first(where: { $0.title == task.title }) {
            persistedTitle.isSelected.toggle()
            if persistedTitle.isSelected {
                ensurePriorityAssessment(for: persistedTitle)
            }
        } else {
            let title = TaskTitle(title: task.title, isSelected: true)
            modelContext.insert(title)
            ensurePriorityAssessment(for: title)
        }

        do {
            try modelContext.save()
        } catch {
            assertionFailure("Failed to save task title selection: \(error)")
        }
    }

    private func isSelectedTitle(_ title: String) -> Bool {
        persistedTitles.first(where: { $0.title == title })?.isSelected == true
    }

    private func selectedIkigaiTypes(for title: TaskTitle) -> [IkigaiType] {
        IkigaiType.allCases.filter { type in
            title.ikigaiSelections.contains { $0.type == type }
        }
    }

    private func ensurePriorityAssessment(for title: TaskTitle) {
        guard title.priorityAssessment == nil else {
            return
        }
        let assessment = TaskTitlePriorityAssessment(taskTitle: title)
        title.priorityAssessment = assessment
        modelContext.insert(assessment)
    }

    @ViewBuilder
    private func titleDetailSheet(for title: TaskTitle) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Ikigai")
                    .font(.headline)
                ikigaiCards(for: title)

                Divider()

                Text("Eisenhower Matrix")
                    .font(.headline)
                if let assessment = title.priorityAssessment {
                    priorityQuestions(for: assessment)
                } else {
                    Button("Start Priority Assessment") {
                        ensurePriorityAssessment(for: title)
                        saveChanges()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
        .navigationTitle(title.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    presentedTitle = nil
                }
            }
        }
    }

    @ViewBuilder
    private func ikigaiCards(for title: TaskTitle) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(IkigaiType.allCases) { type in
                IkigaiCard(
                    icon: type.icon,
                    title: type.title,
                    description: type.description,
                    isSelected: title.ikigaiSelections.contains { $0.type == type }
                ) {
                    if let selection = title.ikigaiSelections.first(where: { $0.type == type }) {
                        modelContext.delete(selection)
                    } else {
                        let selection = TaskTitleIkigaiSelection(type: type, taskTitle: title)
                        title.ikigaiSelections.append(selection)
                    }
                    saveChanges()
                }
            }
        }
    }

    @ViewBuilder
    private func priorityQuestions(for assessment: TaskTitlePriorityAssessment) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Important")
                    .font(.subheadline.weight(.semibold))

                priorityQuestionGrid {
                    priorityQuestionCard(
                        icon: "target",
                        title: "Goal",
                        description: "Apakah aktivitas ini harus ada untuk mencapai tujuan?",
                        isSelected: assessment.importantGoalContribution
                    ) {
                        assessment.importantGoalContribution.toggle()
                    }
                    priorityQuestionCard(
                        icon: "arrow.triangle.branch",
                        title: "Blocker",
                        description: "Jika tidak dikerjakan, apakah tujuan akan tertunda atau lebih sulit tercapai?",
                        isSelected: assessment.importantBlocksGoal
                    ) {
                        assessment.importantBlocksGoal.toggle()
                    }
                    priorityQuestionCard(
                        icon: "arrow.triangle.swap",
                        title: "Alternative",
                        description: "Apakah ada aktivitas lain yang lebih membantu mencapai tujuan?",
                        isSelected: assessment.importantHasBetterAlternative == true
                    ) {
                        assessment.importantHasBetterAlternative = !(assessment.importantHasBetterAlternative ?? false)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Urgent")
                    .font(.subheadline.weight(.semibold))

                priorityQuestionGrid {
                    priorityQuestionCard(
                        icon: "clock.fill",
                        title: "Immediate",
                        description: "Apakah aktivitas ini harus segera dikerjakan 3 hari kedepan?",
                        isSelected: assessment.urgentImmediate
                    ) {
                        assessment.urgentImmediate.toggle()
                    }
                    priorityQuestionCard(
                        icon: "exclamationmark.triangle.fill",
                        title: "Risk",
                        description: "Jika ditunda, apakah akan ada konsekuensi atau masalah dalam 3 hari kedepan?",
                        isSelected: assessment.urgentHasConsequence
                    ) {
                        assessment.urgentHasConsequence.toggle()
                    }
                    priorityQuestionCard(
                        icon: "calendar.badge.clock",
                        title: "Can Wait",
                        description: "Apakah tugas ini boleh ditunda?",
                        isSelected: assessment.urgentCanBeDelayed == true
                    ) {
                        assessment.urgentCanBeDelayed = !(assessment.urgentCanBeDelayed ?? false)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(assessment.quadrant.label)
                    .font(.subheadline.weight(.semibold))
                Text(assessment.quadrant.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("Priority Score: \(assessment.priorityScore) · Important: \(assessment.importantScore) · Urgent: \(assessment.urgentScore)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    @ViewBuilder
    private func priorityQuestionGrid<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        LazyVStack(alignment: .leading, spacing: 12) {
            content()
        }
    }

    private func priorityQuestionCard(
        icon: String,
        title: String,
        description: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        IkigaiCard(
            icon: icon,
            title: title,
            description: description,
            isSelected: isSelected
        ) {
            action()
            saveChanges()
        }
    }

    private func saveChanges() {
        do {
            try modelContext.save()
        } catch {
            assertionFailure("Failed to save task title changes: \(error)")
        }
    }
}

#Preview {
    let category = Category(name: "Current", color: "blue")

    NavigationStack {
        PriorityView(tasks: [
            Task(title: "Learn SwiftData", notes: "", category: category),
            Task(title: "Build Flodise", notes: "", category: category)
        ])
    }
    .modelContainer(for: [Category.self, Task.self, TaskIkigaiSelection.self, TaskTitle.self, TaskTitleIkigaiSelection.self, TaskTitlePriorityAssessment.self], inMemory: true)
}
