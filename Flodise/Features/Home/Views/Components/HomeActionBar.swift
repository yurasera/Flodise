//
//  HomeActionBar.swift
//  Flodise
//
//  Created by Yuhaya Lissera on 31/07/26.
//
import SwiftUI

struct HomeActionBar: View {
    @Binding var isPresentingPriorityTasks: Bool
    let startFocusAction: () -> Void

    @State private var priorityPresentationTrigger = 0

    var body: some View {
        VStack(spacing: 0) {
            HomeActionButton(
                title: "Set Priority",
                systemImage: "flag.fill",
                foregroundColor: Color.brandTertiary,
                tintColor: Color.brandPrimary
            ) {
                priorityPresentationTrigger += 1
                isPresentingPriorityTasks = true
            }

            HomeActionButton(
                title: "Start Focus",
                systemImage: "timer",
                foregroundColor: Color.brandTertiary,
            ) {
                priorityPresentationTrigger += 1
                startFocusAction()
            }
            Spacer()
        }
        .padding()
        .sensoryFeedback(.impact(weight: .heavy), trigger: priorityPresentationTrigger)
    }
}

private struct HomeActionButton: View {
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
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .foregroundStyle(foregroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .glassEffect()
            }
            .background(Color.brandPrimary)
            .tint(tintColor ?? foregroundColor)
        }
        .padding(4)
    }
}
