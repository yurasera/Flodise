//
//  EditTaskView.swift
//  Flodise
//
//  Created by GitHub Copilot on 23/07/26.
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
                    .lineLimit(3...6)

                Stepper("Priority: \(priorityOrder)", value: $priorityOrder, in: 0...9999)

                DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
            }

            Section("Ikigai") {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Why are you doing this task?")
                        .font(.caption)
                        .foregroundStyle(.secondary)

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

            Section {
                Button("Save") {
                    saveChanges()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .fontWeight(.semibold)

                Button("Cancel", role: .cancel) {
                    dismiss()
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .navigationTitle("Edit Task")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            title = task.title
            notes = task.notes
            priorityOrder = task.priorityOrder
        }
    }
}

private extension EditTaskView {
    func saveChanges() {
        task.title = title
        task.notes = notes
        task.priorityOrder = priorityOrder

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save task: \(error)")
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