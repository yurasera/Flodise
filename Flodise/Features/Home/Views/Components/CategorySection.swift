//
//  CategorySection.swift
//  Flocus
//
//  Created by Yuhaya Lissera on 06/07/26.
//

import SwiftUI

struct HomeCategorySection: View {
    let category: CategoryKind
    let categoryModel: Category?
    let tasks: [Task]
    @Binding var energy: Int
    @Binding var globalLevel: Int
    @Binding var globalExp: Int
    @Binding var categoryLevel: Int
    @Binding var categoryExp: Int
    @State private var isPresentingAddTask = false
    
    var body: some View {
        VStack {
            Spacer()
            VStack(alignment: .leading, spacing: Spacing.small) {
                HomeCategoryHeader(
                    title: category.title,
                    subtitle: categoryModel?.displaySubtitle ?? Category.defaultSubtitle(for: category.title),
                    color: category.headerColor,
                    level: categoryLevel,
                    exp: categoryExp,
                    editableCategory: categoryModel
                ) {
                    isPresentingAddTask = true
                }
                category.cards(
                    for: tasks,
                    energy: $energy,
                    globalLevel: $globalLevel,
                    globalExp: $globalExp,
                    categoryLevel: $categoryLevel,
                    categoryExp: $categoryExp
                )
            }
            .foregroundColor(.white)
            .padding()
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(category.backgroundColor)
        .sheet(isPresented: $isPresentingAddTask) {
            HomeAddTaskSheet(category: category)
        }
    }
}
