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
    @Binding var energy: Int
    @Binding var level: Int
    @Binding var exp: Int
    @Binding var currentLevel: Int
    @Binding var currentExp: Int
    @Binding var alternativeLevel: Int
    @Binding var alternativeExp: Int
    @Binding var dreamLevel: Int
    @Binding var dreamExp: Int
    
    @Binding var isCurrentVisible: Bool
    @Binding var isAlternativeVisible: Bool
    @Binding var isDreamVisible: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            // Left side: 3 vertical sections
            VStack(spacing: 0) {
                HomeHeroSection(categories: categories, energy: energy, level: level, exp: exp)
                if isCurrentVisible {
                    HomeCategorySection(
                        category: .current,
                        categoryModel: categoryModel(for: .current),
                        tasks: currentTasks,
                        energy: $energy,
                        globalLevel: $level,
                        globalExp: $exp,
                        categoryLevel: $currentLevel,
                        categoryExp: $currentExp
                    )
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
                    Spacer()
                    HomeCategorySection(
                        category: .alternative,
                        categoryModel: categoryModel(for: .alternative),
                        tasks: alternativeTasks,
                        energy: $energy,
                        globalLevel: $level,
                        globalExp: $exp,
                        categoryLevel: $alternativeLevel,
                        categoryExp: $alternativeExp
                    )
                }
                if isDreamVisible {
                    HomeCategorySection(
                        category: .dream,
                        categoryModel: categoryModel(for: .dream),
                        tasks: dreamTasks,
                        energy: $energy,
                        globalLevel: $level,
                        globalExp: $exp,
                        categoryLevel: $dreamLevel,
                        categoryExp: $dreamExp
                    )
                }
            }
        }
    }
    
    private func categoryModel(for kind: CategoryKind) -> Category? {
        categories.first { $0.name == kind.title }
    }
}
