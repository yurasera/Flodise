//
//  HomeActionButton.swift
//  Flodise
//
//  Created by Yuhaya Lissera on 06/08/26.
//

import SwiftUI

struct HomeActionButton: View {
    let title: String
    let systemImage: String
    let foregroundColor: Color
    var tintColor: Color?
    let action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: action) {
                HStack {
                    Image(systemName: systemImage)
                    Text(title)
                        .multilineTextAlignment(.center)
                }
                .foregroundStyle(foregroundColor)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color.brandPrimary)
                )
                .glassEffect()
            }
            .padding(0)
            .buttonStyle(HomeCardButtonStyle())
            .tint(tintColor ?? foregroundColor)
        }
    }
}

