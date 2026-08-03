//
//  EditTaskView.swift
//  Flodise
//
//  Created by Yuhaya Lissera on 23/07/26.
//
    
import SwiftUI
import SwiftData

struct EditTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [Task]

    let task: Task

    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var selectedStatus: TaskStatus = .idea
    @State private var priorityOrder: Int = 0
    @State private var dueDate: Date = .now
    @State private var selectedIkigai: Set<IkigaiType> = []
    @State private var needToLearn = false
    @State private var dontKnowHow = false
    @State private var needThinking = false
    @State private var manySteps = false
    @State private var needFullFocus = false
    @State private var showInfo = false
    @State private var showEstimatorInfo = false

    var body: some View {
        Form {
            Section("Task Details") {
                TextField("Task Title", text: $title)

                if task.status == .archive {
                    Picker("Status", selection: $selectedStatus) {
                        ForEach(TaskStatus.allCases, id: \.self) { status in
                            Text(status.title == "Backlog" ? "Active" : status.title).tag(status)
                        }
                    }
                }

                TextField("Notes", text: $notes, axis: .vertical)
                    .lineLimit(2...4)
            }
            if selectedStatus != .idea && hasEstimatorValues {
                Section("Task Estimator") {
                    DisclosureGroup("Effort Score : \(estimatorEffort)", isExpanded: $showEstimatorInfo) {
                        VStack(spacing: 12) {
                            HStack {
                                Label(estimatorSize, systemImage: "square.stack.3d.up")
                                
                                Spacer()
                                
                                Label("\(estimatorEffort)", systemImage: "bolt.fill")
                                
                                Spacer()
                                
                                Label("\(estimatorScore)", systemImage: "star.fill")
                            }
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.secondary.opacity(0.12))
                            )
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Size menunjukkan tingkat kompleksitas task (Extra Small, Small, Medium, Large atau Extra Large).", systemImage: "square.stack.3d.up")
                                
                                Divider()
                                
                                Label("Effort adalah jumlah poin dari lima indikator: Perlu Belajar, Belum Tahu Cara, Perlu Banyak Berpikir, Perlu Banyak Langkah, dan Butuh Fokus Penuh.", systemImage: "bolt.fill")
                                
                                Divider()
                                
                                Label("Score merupakan nilai keseluruhan yang membantu menentukan prioritas pengerjaan task.", systemImage: "star.fill")
                            }
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        }
                    }
                    .tint(.primary)
                }
            }
            if task.status == .archive{
                Section("Why are you doing this task?") {
                    VStack(alignment: .leading, spacing: 16) {
                        
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ],
                            spacing: 12
                        ) {
                            ForEach(IkigaiType.allCases) { ikigai in
                                IkigaiCard(
                                    icon: ikigai.icon,
                                    title: ikigai.title,
                                    description: ikigai.description,
                                    isSelected: selectedIkigai.contains(ikigai)
                                ) {
                                    withAnimation(.snappy) {
                                        toggleIkigai(ikigai)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            if selectedStatus == .idea || selectedStatus == .backlog {
                Section("Task Estimator") {
                    VStack(alignment: .leading, spacing: 12) {
                        estimatorToggle(
                            title: "Perlu Belajar?",
                            subtitle: "Membutuhkan pengetahuan atau keterampilan baru.",
                            isOn: $needToLearn
                        )
                        Divider()
                        estimatorToggle(
                            title: "Belum Tahu Cara?",
                            subtitle: "Belum mengetahui langkah untuk menyelesaikannya.",
                            isOn: $dontKnowHow
                        )
                        Divider()
                        estimatorToggle(
                            title: "Perlu Banyak Berpikir?",
                            subtitle: "Memerlukan analisis atau pengambilan keputusan.",
                            isOn: $needThinking
                        )
                        Divider()
                        estimatorToggle(
                            title: "Perlu Banyak Langkah?",
                            subtitle: "Terdiri dari beberapa langkah atau subtask.",
                            isOn: $manySteps
                        )
                        Divider()
                        estimatorToggle(
                            title: "Butuh Fokus Penuh?",
                            subtitle: "Sulit dikerjakan sambil terdistraksi.",
                            isOn: $needFullFocus
                        )

                    }
                    .padding(.vertical, 4)
                }
            }
            if task.status == .idea {
                Button {
                    updateTaskStatus(to: .planned)
                } label: {
                    Text("Move to Planned")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 6)
                    HStack(spacing: 4) {
                        Text("Size: \(estimatorSize)")

                        Button {
                            showInfo = true
                        } label: {
                            Image(systemName: "questionmark.circle")
                        }
                        .buttonStyle(.plain)
                    }
                    .alert("Task Size", isPresented: $showInfo) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text("""
                        Total Skor: \(estimatorScore)/5
                        Effort: \(estimatorEffort)
                        """)
                    }
                }
            }else if task.status == .planned {
                
                    Button {
                        updateTaskStatus(to: .backlog)
                    } label: {
                        VStack(spacing: 4) {
                            Text("Move to Active")
                            if backlogEstimatedEffortTotal > 0 {
                                Text("Active Effort Total: \(backlogEstimatedEffortTotal)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .alignmentGuide(.listRowSeparatorLeading) { _ in
                        return 0 // Memaksa garis pemisah ditarik dari titik paling kiri (0)
                    }
                
                    Button {
                        updateTaskStatus(to: .idea)
                    } label: {
                        VStack(spacing: 4) {
                            Text("Back to Idea")
                                .foregroundStyle(.red)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                
            }else if task.status == .backlog {
                Button {
                    updateTaskStatus(to: .planned)
                } label: {
                    VStack(spacing: 4) {
                        Text("Back to Planned")
                            .foregroundStyle(.red)
                        if backlogEstimatedEffortTotal > 0 {
                            Text("Active Effort Total: \(backlogEstimatedEffortTotal)")
                                .font(.caption)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle("Edit Task")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    saveChanges()
                }
            }
        }
        .onAppear {
            title = task.title
            notes = task.notes
            selectedStatus = task.status
            priorityOrder = task.priorityOrder
            selectedIkigai = Set(task.ikigaiSelections.compactMap { $0.type })
            applyEstimatorState()
        }
    }
}

private extension EditTaskView {
    var hasEstimatorValues: Bool {
        task.estimatedScore != nil || task.estimatedSize != nil || task.estimatedEffort != nil
    }

    var backlogEstimatedEffortTotal: Int {
        tasks
            .filter { $0.status == .backlog }
            .compactMap(\.estimatedEffort)
            .reduce(0, +)
    }

    func applyEstimatorState() {
        let score = task.estimatedScore ?? 0
        needToLearn = score >= 1
        dontKnowHow = score >= 2
        needThinking = score >= 3
        manySteps = score >= 4
        needFullFocus = score >= 5
    }

    var estimatorScore: Int {
        [
            needToLearn,
            dontKnowHow,
            needThinking,
            manySteps,
            needFullFocus
        ].filter { $0 }.count
    }

    var estimatorSize: String {
        switch estimatorScore {
        case 0...1:
            return "XS"
        case 2:
            return "S"
        case 3:
            return "M"
        case 4:
            return "L"
        default:
            return "XL"
        }
    }

    var estimatorEffort: Int {
        switch estimatorScore {
        case 0...1:
            return 1
        case 2:
            return 2
        case 3:
            return 3
        case 4:
            return 5
        default:
            return 8
        }
    }

    func estimatorToggle(title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Toggle(title, isOn: isOn)

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    func saveChanges() {
        task.title = title
        task.notes = notes
        task.status = selectedStatus
        task.priorityOrder = priorityOrder
        persistEstimatorScoreIfNeeded(for: selectedStatus)
        syncIkigaiSelections()

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save task: \(error)")
        }
    }

    func syncIkigaiSelections() {
        let currentSelections = task.ikigaiSelections
        for selection in currentSelections {
            modelContext.delete(selection)
        }

        task.ikigaiSelections.removeAll()

        for ikigai in selectedIkigai.sorted(by: { $0.rawValue < $1.rawValue }) {
            let selection = TaskIkigaiSelection(type: ikigai, task: task)
            task.ikigaiSelections.append(selection)
            modelContext.insert(selection)
        }
    }

    func toggleIkigai(_ ikigai: IkigaiType) {
        if selectedIkigai.contains(ikigai) {
            selectedIkigai.remove(ikigai)
        } else {
            selectedIkigai.insert(ikigai)
        }
    }
    
    func updateTaskStatus(to newStatus: TaskStatus) {
        persistEstimatorScoreIfNeeded(for: newStatus)

        task.status = newStatus

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to update task status: \(error)")
        }
    }

    func persistEstimatorScoreIfNeeded(for status: TaskStatus) {
        task.estimatedScore = estimatorScore
        task.estimatedSize = estimatorSize
        task.estimatedEffort = estimatorEffort
    }

}

#Preview {
    let category = Category(name: "Current", color: "blue")

    NavigationStack {
        EditTaskView(task: Task(title: "Refine Priority Flow", notes: "Make the task row tappable.", category: category))
    }
}
