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
    
    @Environment(\.modelContext) private var modelContext
    
    private static let logger = Logger(subsystem: "com.yuhayalissera.Flocus", category: "CategoryCard")

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
        .padding()
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
            } else {
                task.status = .completed
                task.completedAt = .now
            }
            
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
