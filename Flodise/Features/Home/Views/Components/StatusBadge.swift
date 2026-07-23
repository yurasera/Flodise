//
//  StatusBadge.swift
//  Flocus
//
//  Created by Yuhaya Lissera on 24/06/26.
//

import SwiftUI

struct HomeStatusBadge: View {

    let count: Int
    let category: CategoryKind

    init(count: Int = 1, category: CategoryKind) {
        self.count = count
        self.category = category
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            
            Circle()
                .fill(category.backgroundColor)
                .frame(width: 28, height: 28)
                .overlay {
                    Image(systemName: category.icon)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(category.headerColor)
                }
                .overlay {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                }

            if count > 1 {
                let displayText: String = count > 99 ? "99+" : String(count)
                Text(displayText)
                    .font(.caption2).bold()
                    .foregroundStyle(.white)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.8))
                    )
                    .overlay(
                        Capsule()
                            .stroke(.white.opacity(0.8), lineWidth: 1)
                    )
                    .offset(x: 6, y: -6)
                    .accessibilityLabel("Jumlah ceklis: \(displayText)")
            }
        }
        .accessibilityElement(children: .combine)
    }
}
