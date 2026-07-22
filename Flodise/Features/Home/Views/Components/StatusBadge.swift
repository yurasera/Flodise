//
//  StatusBadge.swift
//  Flocus
//
//  Created by Yuhaya Lissera on 24/06/26.
//

import SwiftUI

struct HomeStatusBadge: View {

    let color: Color
    let count: Int

    init(color: Color, count: Int = 1) {
        self.color = color
        self.count = count
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title)
                .foregroundStyle(color)
                .background(
                    Circle()
                        .fill(color)
                )
                .overlay(
                    Circle()
                        .stroke(.white, lineWidth: 2)
                )

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
