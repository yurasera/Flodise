//
//  CategorySection.swift
//  Flocus
//
//  Created by Yuhaya Lissera on 06/07/26.
//

import SwiftUI

struct HomeCategorySection: View {
    let category: CategoryKind
    let tasks: [Task]
    @Binding var energy: Int
    @Binding var exp: Int
    @State private var isPresentingAddTask = false
    
    var body: some View {
        VStack {
            Spacer()
            VStack(alignment: .leading, spacing: Spacing.small) {
                HomeCategoryHeader(title: category.title, color: category.headerColor) {
                    isPresentingAddTask = true
                }
                category.cards(for: tasks, energy: $energy, exp: $exp)
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
