//
//  AddTaskSheet.swift
//  Flocus
//
//  Created by Yuhaya Lissera on 06/07/26.
//

import SwiftUI
import SwiftData

struct HomeAddTaskSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let category: CategoryKind
    @State private var title: String = ""
    @State private var notes: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    TextField("Enter title", text: $title)
                }
                Section("Notes") {
                    TextField("Enter notes", text: $notes, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }
            }
            .navigationTitle("Add \(category.title == "Hobbies" ? "Creative" : category.title) Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func save() {
        let categoryName = category.title

        // Fetch Category seeded by SeedData matching the name
        let descriptor = FetchDescriptor<Category>(predicate: #Predicate { $0.name == categoryName })
        let matchedCategory = try? modelContext.fetch(descriptor).first

        let newTask = Task(title: title, notes: notes, category: matchedCategory)
        modelContext.insert(newTask)
        dismiss()
    }
}
