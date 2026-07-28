//
//  CategoryHeader.swift
//  Flocus
//
//  Created by Yuhaya Lissera on 24/06/26.
//

import SwiftUI

struct HomeCategoryHeader: View {
    let title: String
    let color: Color
    let level: Int
    let exp: Int
    let action: () -> Void
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text(title == "Dream" ? "Dream" : title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(color)
                Text(title == "Current" ? "Engineer" : title == "Alternative" ? "Educator" : title == "Dream" ? "Builder" : title)
                    .font(.caption)
                    .foregroundStyle(color)
                HStack(spacing: 8) {
                    Label("Lv \(level)", systemImage: "sparkles")
                    Text("EXP \(exp)/100")
                }
                .font(.caption2.weight(.semibold))
                .foregroundStyle(color.opacity(0.9))
            }
            
            Spacer()

            Button(action: action) {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                    .foregroundStyle(color)
                    .accessibilityLabel("Add \(title) Item")
            }
        }
    }
}
