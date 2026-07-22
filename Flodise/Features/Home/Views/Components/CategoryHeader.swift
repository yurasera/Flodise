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
    let action: () -> Void
    
    var body: some View {
        HStack {
            Text(title == "Hobbies" ? "Creative" : title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(color)
            
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
