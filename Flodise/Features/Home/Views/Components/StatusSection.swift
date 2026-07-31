//
//  StatusSection.swift
//  Flocus
//
//  Created by Yuhaya Lissera on 06/07/26.
//
import SwiftUI

struct HomeStatusSection: View {
    let currentCount: Int
    let alternativeCount: Int
    let dreamCount: Int
    @Binding var isPresentingPriorityTasks: Bool
    let startFocusAction: () -> Void

    @Binding var isCurrentVisible: Bool
    @Binding var isAlternativeVisible: Bool
    @Binding var isDreamVisible: Bool

    init(
        currentCount: Int = 0,
        alternativeCount: Int = 0,
        dreamCount: Int = 0,
        isPresentingPriorityTasks: Binding<Bool>,
        startFocusAction: @escaping () -> Void,
        isCurrentVisible: Binding<Bool>,
        isAlternativeVisible: Binding<Bool>,
        isDreamVisible: Binding<Bool>
    ) {
        self.currentCount = currentCount
        self.alternativeCount = alternativeCount
        self.dreamCount = dreamCount
        _isPresentingPriorityTasks = isPresentingPriorityTasks
        self.startFocusAction = startFocusAction
        _isCurrentVisible = isCurrentVisible
        _isAlternativeVisible = isAlternativeVisible
        _isDreamVisible = isDreamVisible
    }

    var body: some View {
        VStack {
            Divider()
                .padding(.bottom, Spacing.small)
            Spacer()
            VStack(spacing: Spacing.medium) {
                HStack(spacing: Spacing.large) {
                    // Current
                    Button {
                        withAnimation(.snappy) { isCurrentVisible.toggle() }
                    } label: {
                        HomeStatusBadge(count: currentCount, category: .current)
                    }
                    .buttonStyle(.plain)

                    // Alternative
                    Button {
                        withAnimation(.snappy) { isAlternativeVisible.toggle() }
                    } label: {
                        HomeStatusBadge(count: alternativeCount, category: .alternative)
                    }
                    .buttonStyle(.plain)

                    // Dream
                    Button {
                        withAnimation(.snappy) { isDreamVisible.toggle() }
                    } label: {
                        HomeStatusBadge(count: dreamCount, category: .dream)
                    }
                    .buttonStyle(.plain)
                }

                HomeActionBar(
                    isPresentingPriorityTasks: $isPresentingPriorityTasks,
                    startFocusAction: startFocusAction
                )
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.brandPrimary)
    }
}

struct HomeActionBar: View {
    @Binding var isPresentingPriorityTasks: Bool
    let startFocusAction: () -> Void

    @State private var priorityPresentationTrigger = 0

    var body: some View {
        VStack(spacing: 0) {
            HomeActionButton(
                title: "Set Priority",
                systemImage: "flag.fill",
                foregroundColor: .black,
                tintColor: Color.brandPrimary
            ) {
                priorityPresentationTrigger += 1
                isPresentingPriorityTasks = true
            }

            HomeActionButton(
                title: "Start Focus",
                systemImage: "timer",
                foregroundColor: .black,
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
            .tint(tintColor ?? foregroundColor)
        }
        .padding(4)
    }
}
