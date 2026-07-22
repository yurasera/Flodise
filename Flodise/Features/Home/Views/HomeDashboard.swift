//
//  HomeDashboard.swift
//  Flocus
//
//  Created by Yuhaya Lissera on 18/07/26.
//

import SwiftUI
import SwiftData

struct HomeDashboard: View {
    let categories: [Category]
    let currentTasks: [Task]
    let alternativeTasks: [Task]
    let dreamTasks: [Task]
    
    @Binding var isCurrentVisible: Bool
    @Binding var isAlternativeVisible: Bool
    @Binding var isDreamVisible: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            // Left side: 3 vertical sections
            VStack(spacing: 0) {
                HomeHeroSection(categories: categories)
                if isCurrentVisible {
                    HomeCategorySection(category: .current, tasks: currentTasks)
                }
                HomeStatusSection(
                    currentCount: currentTasks.count,
                    alternativeCount: alternativeTasks.count,
                    dreamCount: dreamTasks.count,
                    isCurrentVisible: $isCurrentVisible,
                    isAlternativeVisible: $isAlternativeVisible,
                    isDreamVisible: $isDreamVisible
                )
            }
            
            // Right side: 2 vertical sections
            VStack(spacing: 0) {
                if isAlternativeVisible {
                    HomeCategorySection(category: .alternative, tasks: alternativeTasks)
                }
                if isDreamVisible {
                    HomeCategorySection(category: .dream, tasks: dreamTasks)
                }
            }
        }
    }
}
