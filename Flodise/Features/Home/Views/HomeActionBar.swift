//
//  HomeActionBar.swift
//  Flocus
//
//  Created by Yuhaya Lissera on 18/07/26.
//

import SwiftUI

struct HomeActionBar: View {
    @Binding var isPresentingPriorityTasks: Bool
    let startFocusAction: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            HomeActionButton(
                title: "Set Priority",
                systemImage: "flag.fill",
                foregroundColor: Color.brandTertiary,
                backgroundColor: Color.brandPrimary,
                tintColor: Color.brandPrimary
            ) {
                isPresentingPriorityTasks = true
            }
            
            HomeActionButton(
                title: "Start Focus",
                systemImage: "timer",
                foregroundColor: Color.brandPrimary,
                backgroundColor: Color.brandTertiary
            ) {
                startFocusAction()
            }
        }
        .frame(height: 96)
    }
}

private struct HomeActionButton: View {
    let title: String
    let systemImage: String
    let foregroundColor: Color
    let backgroundColor: Color
    var tintColor: Color?
    let action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: action) {
                HStack {
                    Image(systemName: systemImage)
                    Text(title)
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .foregroundStyle(foregroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .glassEffect()
            }
            .tint(tintColor ?? foregroundColor)

            Spacer()
        }
        .padding(16)
        .background(backgroundColor)
    }
}
