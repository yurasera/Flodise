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
    @State private var priorityOrder: Int = 0
    @State private var dueDate: Date = .now
    @State private var selectedIkigai: Set<IkigaiType> = []

    var body: some View {
        Form {
            Section("Task Details") {
                TextField("Task Title", text: $title)

                TextField("Notes", text: $notes, axis: .vertical)
                    .lineLimit(2...4)
            }

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

            if task.status == .idea {
                Button {
                    task.status = .planned

                    do {
                        try modelContext.save()
                    } catch {
                        print("Failed to update task status: \(error)")
                    }
                } label: {
                    Text("Move to Planned")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }else if task.status == .planned {
                Button {
                    task.status = .backlog

                    do {
                        try modelContext.save()
                    } catch {
                        print("Failed to update task status: \(error)")
                    }
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
            priorityOrder = task.priorityOrder
            selectedIkigai = Set(task.ikigaiSelections.compactMap { $0.type })
        }
    }
}

private extension EditTaskView {
    func saveChanges() {
        task.title = title
        task.notes = notes
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
}

#Preview {
    let category = Category(name: "Current", color: "blue")

    NavigationStack {
        EditTaskView(task: Task(title: "Refine Priority Flow", notes: "Make the task row tappable.", category: category))
    }
}
