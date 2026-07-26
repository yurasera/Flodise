//
//  CategoryKind.swift
//  Flocus
//
//  Created by Yuhaya Lissera on 06/07/26.
//

import SwiftUI

enum CategoryKind {
    case current
    case alternative
    case dream

    var title: String {
        switch self {
        case .current: return "Current"
        case .alternative: return "Alternative"
        case .dream: return "Dream"
        }
    }

    // Header title color for SectionHeader
    var headerColor: Color {
        switch self {
        case .current: return Color.brandTertiary
        case .alternative: return Color.brandTertiary
        case .dream: return Color.brandSecondary
        }
    }

    // Background color of the section container
    var backgroundColor: Color {
        switch self {
        case .current: return Color.brandPrimary
        case .alternative: return Color.brandSecondary
        case .dream: return Color.brandTertiary
        }
    }
    
    var icon: String {
        switch self {
        case .current:
            return "location.fill"
        case .alternative:
            return "arrow.trianglehead.branch"
        case .dream:
            return "star.fill"
        }
    }

    // Cards to display for each category from model tasks.
    @ViewBuilder
    func cards(for tasks: [Task], energy: Binding<Int>, level: Binding<Int>, exp: Binding<Int>) -> some View {
        let limited = Array(tasks.prefix(2))
        if limited.isEmpty {
            // Show two empty placeholder cards when there is no data
                HomeCategoryCard(
                title: "",
                description: "",
                background: headerColor,
                foreground: backgroundColor,
                task: nil,
                energy: energy,
                level: level,
                exp: exp
            )
                HomeCategoryCard(
                title: "",
                description: "",
                background: headerColor,
                foreground: backgroundColor,
                task: nil,
                energy: energy,
                level: level,
                exp: exp
            )
        } else {
            ForEach(limited) { task in
                    HomeCategoryCard(
                    title: task.title,
                    description: task.notes,
                    background: headerColor,
                    foreground: backgroundColor,
                    task: task,
                    energy: energy,
                    level: level,
                    exp: exp
                )
            }
        }
    }
}
