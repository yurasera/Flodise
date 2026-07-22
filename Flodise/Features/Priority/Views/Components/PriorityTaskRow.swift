//
//  PriorityTaskRow.swift
//  Flocus
//
//  Created by Yuhaya Lissera on 06/07/26.
//

import SwiftUI

struct PriorityTaskRow: View {
    let task: Task
    let onDelete: () -> Void
    let onArchive: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "circle.fill")
                    .foregroundStyle(categoryColor)
                Text(task.title)
                    .font(.headline)
                Spacer()
                Text(task.category?.name ?? "")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.12))
                    .clipShape(Capsule())
            }

            if !task.notes.isEmpty {
                Text(task.notes)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive, action: onDelete) {
                Image(systemName: "trash.fill")
                Text("Delete")
            }
            
            Button(action: onArchive) {
                Image(systemName: "archivebox.fill")
                Text("Archive")
            }
            .tint(.orange)
        }
    }
    
    private var categoryColor: Color {
        switch task.category?.name {
        case CategoryKind.learn.title:
            return Color.brandPrimary
        case CategoryKind.projects.title:
            return Color.brandSecondary
        case CategoryKind.hobbies.title:
            return Color.brandTertiary
        default:
            return .secondary
        }
    }
}
