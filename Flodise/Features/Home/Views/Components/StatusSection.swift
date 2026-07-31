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
