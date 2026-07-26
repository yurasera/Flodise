//
//  CategoryCard.swift
//  Flocus
//
//  Created by Yuhaya Lissera on 24/06/26.
//

import SwiftUI
import SwiftData
import OSLog

struct HomeCategoryCard: View {
    let title: String
    let description: String
    let background: Color
    let foreground: Color
    var task: Task?
    @Binding var energy: Int
    @Binding var exp: Int
    
    @Environment(\.modelContext) private var modelContext
    
    private static let logger = Logger(subsystem: "com.yuhayalissera.Flocus", category: "CategoryCard")

    @State private var toggleTaskCompletionTrigger = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {

            HStack {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)

                Spacer()

                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                }
            }

            Text(description)
                .font(.caption)
        }
        .frame(
            maxWidth: .infinity,
            minHeight: Metrics.cardHeight,
            alignment: .leading
        )
        .padding(.horizontal, Spacing.medium)
        .padding(.vertical, Spacing.small)
        .background(
            RoundedRectangle(cornerRadius: Spacing.medium)
                .fill(
                    isCompleted
                    ? background.opacity(0.5)
                    : background
                )
        )
        .foregroundStyle(foreground)
        .onTapGesture {
            toggleTaskCompletion()
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: toggleTaskCompletionTrigger)
    }
    
    private var isCompleted: Bool {
        task?.status == .completed
    }
    
    private func toggleTaskCompletion() {
        guard let task = task else { return }
        
        withAnimation(.spring) {
            if task.status == .completed {
                task.status = .backlog
                task.completedAt = nil
                energy = max(0, energy + 1)
                exp = min(100, exp - 10)
            } else {
                task.status = .completed
                task.completedAt = .now
                energy = max(0, energy - 1)
                exp = min(100, exp + 10)
            }
            toggleTaskCompletionTrigger += 1
            saveChanges()
        }
    }
    
    private func saveChanges() {
        do {
            try modelContext.save()
        } catch {
            Self.logger.error("Failed to save task completion: \(error.localizedDescription)")
        }
    }
}
