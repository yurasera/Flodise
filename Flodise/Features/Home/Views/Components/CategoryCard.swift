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
    @Binding var globalLevel: Int
    @Binding var globalExp: Int
    @Binding var categoryLevel: Int
    @Binding var categoryExp: Int
    
    @Environment(\.modelContext) private var modelContext
    
    private static let logger = Logger(subsystem: "com.yuhayalissera.Flocus", category: "CategoryCard")

    @State private var toggleTaskCompletionTrigger = 0
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: Spacing.small) {
                HStack {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.bold)
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

            if !isCompleted, let estimatedEffort = task?.estimatedEffort {
                HStack(spacing: 2) {
                    Image(systemName: "bolt.fill")
                    Text("\(estimatedEffort)")
                        .padding(.trailing, 4)
                        .padding(.vertical, 4)
                        
                }
                .font(.caption2.weight(.semibold))
                .foregroundStyle(foreground)
                .offset(x: 10, y: -6)
                .padding(.top, Spacing.small)
                .padding(.trailing, Spacing.medium)
            }else{
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption2.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .foregroundStyle(foreground)
            }
        }
    }
    
    private var isCompleted: Bool {
        task?.status == .completed
    }
    
    private func toggleTaskCompletion() {
        guard let task = task else { return }
        let effortMultiplier = max(1, task.estimatedEffort ?? 1)
        
        withAnimation(.spring) {
            if task.status == .completed {
                task.status = .backlog
                task.completedAt = nil
                energy = min(10, energy + effortMultiplier * 1)
                globalExp = max(0, globalExp - (effortMultiplier * 10))
                categoryExp = max(0, categoryExp - (effortMultiplier * 10))
            } else {
                task.status = .completed
                task.completedAt = .now
                energy = energy - (effortMultiplier * 1)
                globalExp += effortMultiplier * 10
                while globalExp >= 100 {
                    globalExp -= 100
                    globalLevel += 1
                }

                categoryExp += effortMultiplier * 10
                while categoryExp >= 100 {
                    categoryExp -= 100
                    categoryLevel += 1
                }
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
