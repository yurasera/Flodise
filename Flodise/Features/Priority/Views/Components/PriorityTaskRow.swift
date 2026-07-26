//
//  PriorityTaskRow.swift
//  Flodise
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
                Circle()
                    .fill(categoryColor)
                    .frame(width: 24, height: 24)
                    .overlay {
                        Image(systemName: task.category?.icon ?? "circle.fill")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(task.category?.headerColor ?? .gray)
                    }
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
            
            if !ikigaiTypes.isEmpty {
                HStack(spacing: 8) {
                    ForEach(ikigaiTypes) { ikigai in
                        HStack(spacing: 4) {
                            Image(systemName: ikigai.icon)
                                .font(.system(size: 10, weight: .semibold))
                                .symbolRenderingMode(.hierarchical)
                        }
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.12))
                        .clipShape(Capsule())
                    }
                }
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
        case CategoryKind.current.title:
            return Color.brandPrimary
        case CategoryKind.alternative.title:
            return Color.brandSecondary
        case CategoryKind.dream.title:
            return Color.brandTertiary
        default:
            return .secondary
        }
    }

    private var ikigaiTypes: [IkigaiType] {
        IkigaiType.allCases.filter { type in
            task.ikigaiSelections.contains(where: { $0.type == type })
        }
    }
}
