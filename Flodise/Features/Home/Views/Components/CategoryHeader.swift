//
//  CategoryHeader.swift
//  Flocus
//
//  Created by Yuhaya Lissera on 24/06/26.
//

import SwiftUI
import SwiftData

struct HomeCategoryHeader: View {
    let title: String
    let subtitle: String
    let color: Color
    let level: Int
    let exp: Int
    let editableCategory: Category?
    let action: () -> Void

    @Environment(\.modelContext) private var modelContext
    @State private var isPresentingSubtitleEditor = false
    @State private var draftSubtitle = ""

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(color)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(color)
                    .contextMenu {
                        if editableCategory != nil {
                            Button {
                                presentSubtitleEditor()
                            } label: {
                                Label("Edit Subtitle", systemImage: "pencil")
                            }

                            if hasCustomSubtitle {
                                Button(role: .destructive) {
                                    resetSubtitle()
                                } label: {
                                    Label("Reset Subtitle", systemImage: "arrow.counterclockwise")
                                }
                            }
                        }
                    }
                HStack(spacing: 8) {
                    Label("Lv \(level)", systemImage: "sparkles")
                    Text("EXP \(exp)/100")
                }
                .font(.caption2.weight(.semibold))
                .foregroundStyle(color.opacity(0.9))
            }
            
            Spacer()

            Button(action: action) {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                    .foregroundStyle(color)
                    .accessibilityLabel("Add \(title) Item")
            }
        }
        .sheet(isPresented: $isPresentingSubtitleEditor) {
            SubtitleEditorSheet(
                title: title,
                defaultSubtitle: defaultSubtitle,
                subtitle: $draftSubtitle,
                onSave: saveSubtitle,
                onReset: resetSubtitle
            )
        }
    }

    private var hasCustomSubtitle: Bool {
        guard let currentSubtitle = normalizedSubtitle(editableCategory?.subtitle) else {
            return false
        }

        return currentSubtitle != defaultSubtitle
    }

    private var defaultSubtitle: String {
        Category.defaultSubtitle(for: title)
    }

    private func presentSubtitleEditor() {
        if let storedSubtitle = normalizedSubtitle(editableCategory?.subtitle) {
            draftSubtitle = storedSubtitle
        } else {
            draftSubtitle = subtitle
        }
        isPresentingSubtitleEditor = true
    }

    private func saveSubtitle() {
        guard let editableCategory else { return }

        let trimmedSubtitle = draftSubtitle.trimmingCharacters(in: .whitespacesAndNewlines)
        editableCategory.subtitle = trimmedSubtitle.isEmpty ? nil : trimmedSubtitle

        do {
            try modelContext.save()
        } catch {
            print("Failed to save category subtitle: \(error)")
        }

        isPresentingSubtitleEditor = false
    }

    private func resetSubtitle() {
        guard let editableCategory else { return }

        editableCategory.subtitle = nil

        do {
            try modelContext.save()
        } catch {
            print("Failed to reset category subtitle: \(error)")
        }

        draftSubtitle = defaultSubtitle
        isPresentingSubtitleEditor = false
    }

    private func normalizedSubtitle(_ subtitle: String?) -> String? {
        let trimmed = subtitle?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let trimmed, !trimmed.isEmpty else {
            return nil
        }

        return trimmed
    }
}

private struct SubtitleEditorSheet: View {
    let title: String
    let defaultSubtitle: String
    @Binding var subtitle: String
    let onSave: () -> Void
    let onReset: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Subtitle") {
                    TextField("Enter subtitle", text: $subtitle)
                        .textInputAutocapitalization(.words)
                        .foregroundStyle(Color.adaptiveTextPrimary)
                }
                .foregroundStyle(Color.adaptiveTextPrimary)

                Section {
                    Button("Reset to Default", role: .destructive, action: onReset)
                        .disabled(
                            subtitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                            subtitle.trimmingCharacters(in: .whitespacesAndNewlines) == defaultSubtitle
                        )
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle("Edit \(title)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color.adaptiveTextPrimary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                        dismiss()
                    }
                    .foregroundStyle(Color.adaptiveTextPrimary)
                    .disabled(subtitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .background(Color.adaptiveBackground)
    }
}
