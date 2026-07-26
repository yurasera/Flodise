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
            if task.status != .idea && task.status != .planned {
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
            if selectedStatus == .planned {
                Section("Task Estimator") {
                    VStack(alignment: .leading, spacing: 12) {
                        estimatorToggle("Perlu Belajar?", isOn: $needToLearn)
                        estimatorToggle("Belum Tahu Cara?", isOn: $dontKnowHow)
                        estimatorToggle("Perlu Banyak Berpikir?", isOn: $needThinking)
                        estimatorToggle("Perlu Banyak Langkah?", isOn: $manySteps)
                        estimatorToggle("Butuh Fokus Penuh?", isOn: $needFullFocus)

                        Divider()

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
                    .padding(.vertical, 4)
                }
            }
            if task.status == .idea {
                Button {
                    updateTaskStatus(to: .planned)
                } label: {
                    Text("Move to Planned")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            } else if task.status == .planned {
                Button {
                    updateTaskStatus(to: .backlog)
                } label: {
                    Text("Move to Active")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            
            HStack {
                Text("\(dueDate)")
                    .font(.caption)
            }
            .padding(.vertical, 4)
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
        }
    }
}

private extension EditTaskView {
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

    func estimatorToggle(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(title, isOn: isOn)
    }

    func saveChanges() {
        task.title = title
        task.notes = notes
        task.status = selectedStatus
        task.priorityOrder = priorityOrder
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
        task.status = newStatus

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to update task status: \(error)")
        }
    }

}

#Preview {
    let category = Category(name: "Current", color: "blue")

    NavigationStack {
        EditTaskView(task: Task(title: "Refine Priority Flow", notes: "Make the task row tappable.", category: category))
    }
}
