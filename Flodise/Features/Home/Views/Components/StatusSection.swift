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

    @Binding var isCurrentVisible: Bool
    @Binding var isAlternativeVisible: Bool
    @Binding var isDreamVisible: Bool

    init(
        currentCount: Int = 0,
        alternativeCount: Int = 0,
        dreamCount: Int = 0,
        isCurrentVisible: Binding<Bool>,
        isAlternativeVisible: Binding<Bool>,
        isDreamVisible: Binding<Bool>
    ) {
        self.currentCount = currentCount
        self.alternativeCount = alternativeCount
        self.dreamCount = dreamCount
        _isCurrentVisible = isCurrentVisible
        _isAlternativeVisible = isAlternativeVisible
        _isDreamVisible = isDreamVisible
    }

    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: Spacing.medium) {
                HStack(spacing: Spacing.medium) {
                    // Current
                    Button {
                        withAnimation(.snappy) { isCurrentVisible.toggle() }
                    } label: {
                        HomeStatusBadge(color: Color.brandPrimary, count: currentCount)
                    }
                    .buttonStyle(.plain)

                    // Alternative
                    Button {
                        withAnimation(.snappy) { isAlternativeVisible.toggle() }
                    } label: {
                        HomeStatusBadge(color: Color.brandSecondary, count: alternativeCount)
                    }
                    .buttonStyle(.plain)

                    // Dream
                    Button {
                        withAnimation(.snappy) { isDreamVisible.toggle() }
                    } label: {
                        HomeStatusBadge(color: Color.brandTertiary, count: dreamCount)
                    }
                    .buttonStyle(.plain)
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.brandPrimary)
    }
}
