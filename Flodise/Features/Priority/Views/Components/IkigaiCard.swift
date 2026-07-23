//
//  IkigaiCard.swift
//  Flodise
//
//  Created by GitHub Copilot on 23/07/26.
//

import SwiftUI

struct IkigaiCard: View {
    let icon: String
    let title: String
    let description: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    HStack{
                        Image(systemName: icon)
                            .font(.system(size: 14, weight: .semibold))
                            .symbolRenderingMode(.hierarchical)
                        Text(title)
                            .font(.headline)
                    }

                    Spacer(minLength: 8)

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption.weight(.semibold))
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(isSelected ? Color.white.opacity(0.9) : .secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, minHeight: 20, alignment: .leading)
            .padding(16)
            .foregroundStyle(isSelected ? .white : .primary)
            .background {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(isSelected ? Color.brandPrimary : Color(uiColor: .secondarySystemBackground))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(isSelected ? Color.clear : Color.secondary.opacity(0.16), lineWidth: 1)
            }
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.snappy(duration: 0.22), value: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title), \(description)")
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
    }
}
